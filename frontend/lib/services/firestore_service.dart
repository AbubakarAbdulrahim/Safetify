import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:safetify/models/alerts.dart';
import 'package:safetify/models/incidents.dart';
import 'package:safetify/models/users.dart' as model;

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // incidents
  // CREATE INCIDENT
  Future<void> createIncident(Incident incident) async {
    await _db.collection("incidents").add(incident.toMap());
  }

  // SAVE INCIDENT
  Future<DocumentReference> saveIncident(Incident incident) async {
    return await _db.collection("incidents").add(incident.toMap());
  }

  Future<void> updateIncident(String id, Map<String, dynamic> updates) async {
    await _db.collection('incidents').doc(id).update({
      ...updates,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  // GET ALL INCIDENTS
  Stream<List<Incident>> getAllIncidents({int limit = 10}) {
    return _db
        .collection("incidents")
        .orderBy("createdAt", descending: true)
        .limit(limit)
        .snapshots()
        .map((snap) =>
            snap.docs.map((doc) => Incident.fromDoc(doc)).toList());
  }

  // GET USER INCIDENTS
  Stream<List<Incident>> getUserIncidents(String uid) {
    return _db
        .collection('incidents')
        .where('userId', isEqualTo: uid) 
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Incident.fromDoc(doc))
            .toList());
  }

  // GET ALL INCIDENTS FOR ANALYTICS
  Stream<List<Incident>> getAnalyticsIncidents() {
    return _db
        .collection("incidents")
        .orderBy("createdAt", descending: true)
        .limit(500)
        .snapshots()
        .map((snap) =>
            snap.docs.map((doc) => Incident.fromDoc(doc)).toList());
  }

// users
// Wrapper to get the currently logged-in user's profile
Future<model.User?> getCurrentUserProfile() async {
  final user = FirebaseAuth.instance.currentUser;
  if (user != null) {
    // Calls your existing method nicely
    return await getUser(user.uid);
  }
  return null;
}
//users original
  Future<model.User> getUser(String uid) async {
    final snapshot = await _db
        .collection('users')
        .where(FieldPath.documentId, isEqualTo: uid)
        .limit(1)
        .get();

    if (snapshot.docs.isEmpty) {
      throw Exception('User not found');
    }

    final doc = snapshot.docs.first;
    return model.User.fromDoc(doc);
  }

  Stream<model.User> getUserStream(String uid) {
    return _db
        .collection('users')
        .where(FieldPath.documentId, isEqualTo: uid)
        .limit(1)
        .snapshots()
        .map((snapshot) {
          if (snapshot.docs.isEmpty) {
            throw Exception('User not found');
          }
          return model.User.fromDoc(snapshot.docs.first);
        });
  }

  Future<void> updateUser(String uid, Map<String, dynamic> data) async {
    await _db.collection('users').doc(uid).update({
      ...data,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }
  // alerts

  Stream<List<Alert>> getUserAlerts(String uid) {
    return _db
        .collection('alerts')
        .where('recipients', arrayContains: uid)
        .orderBy('sentAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs.map((doc) => Alert.fromDoc(doc)).toList());
  }

  /// Save alert + auto-send to nearby users
  Future<void> createAlert(Alert alert) async {
    await _db.collection('alerts').add(alert.toMap());
    await sendAlertsToNearbyUsers(alert);
  }

  /// Save alert without auto-sending
  Future<void> saveAlert(Alert alert) async {
    await _db.collection('alerts').add(alert.toMap());
  }

  // Community Updates
  Stream<List<Map<String, dynamic>>> getCommunityUpdates() {
    return _db
        .collection('community_updates')
        .orderBy('createdAt', descending: true)
        .limit(10)
        .snapshots()
        .map((snap) => snap.docs.map((doc) {
              final data = doc.data();
              data['id'] = doc.id;
              return data;
            }).toList());
  }

  // near by detector (3 KM)

  Future<List<model.User>> _getNearbyUsers(double alertLat, double alertLng) async {
    final snapshot = await _db.collection('users').get();

    List<model.User> nearbyUsers = [];

    for (var doc in snapshot.docs) {
      final user = model.User.fromDoc(doc);

      if (user.lat == null || user.lon == null) continue;

      final distance = _calculateDistance(
        alertLat,
        alertLng,
        user.lat!,
        user.lon!,
      );

      if (distance <= 3.0) {
        nearbyUsers.add(user);
      }
    }

    return nearbyUsers;
  }
  // send push notification

  Future<void> sendAlertsToNearbyUsers(Alert alert) async {
    final users = await _getNearbyUsers(alert.lat, alert.lon);

    for (var user in users) {
      if (user.fcmToken == null) continue;

      await _sendPushNotification(
        token: user.fcmToken!,
        title: "⚠ Nearby Incident Alert",
        body: alert.description,
      );
    }
  }

  

  // PUSH NOTIFICATION
  Future<void> _sendPushNotification({
    required String token,
    required String title,
    required String body,
  }) async {
    // Placeholder: do not attempt to call client SDK methods for server push.
    // Implement a server-side solution for production.
    await Future<void>.value();
  }

  // 3 km distance calculation
  double _calculateDistance(
      double lat1, double lon1, double lat2, double lon2) {
    const earthRadius = 6371; // KM

    double dLat = _deg(lat2 - lat1);
    double dLon = _deg(lon2 - lon1);

    double a = sin(dLat / 2) * sin(dLat / 2) +
        cos(_deg(lat1)) *
            cos(_deg(lat2)) *
            sin(dLon / 2) *
            sin(dLon / 2);

    double c = 2 * atan2(sqrt(a), sqrt(1 - a));

    return earthRadius * c;
  }

  // Get single incident stream
  Stream<Incident> getIncidentStream(String id) {
    return _db.collection('incidents').doc(id).snapshots().map((doc) {
      return Incident.fromDoc(doc);
    });
  }

  // Vote on incident
  Future<void> voteIncident(String incidentId, String userId, String voteType) async {
    final docRef = _db.collection('incidents').doc(incidentId);

    await _db.runTransaction((transaction) async {
      final snapshot = await transaction.get(docRef);
      if (!snapshot.exists) {
        throw Exception("Incident does not exist!");
      }

      final data = snapshot.data() as Map<String, dynamic>;
      final userVotes = Map<String, dynamic>.from(data['userVotes'] ?? {});
      int upvotes = data['upvotes'] ?? 0;
      int downvotes = data['downvotes'] ?? 0;

      final currentVote = userVotes[userId];

      if (currentVote == voteType) {
        // Remove vote if clicking same type
        userVotes.remove(userId);
        if (voteType == 'up') upvotes--;
        if (voteType == 'down') downvotes--;
      } else {
        // Change vote or add new vote
        if (currentVote == 'up') upvotes--;
        if (currentVote == 'down') downvotes--;

        userVotes[userId] = voteType;
        if (voteType == 'up') upvotes++;
        if (voteType == 'down') downvotes++;
      }

      transaction.update(docRef, {
        'upvotes': upvotes,
        'downvotes': downvotes,
        'userVotes': userVotes,
      });
    });
  }

  // PERSONAL EMERGENCY CONTACTS

  Future<void> addEmergencyContact(String name, String phone) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final contact = {
      'name': name,
      'phone': phone,
      'id': DateTime.now().millisecondsSinceEpoch.toString(),
    };

    // Update Firestore
    await _db.collection('users').doc(user.uid).update({
      'emergencyContacts': FieldValue.arrayUnion([contact])
    });

    // Update Local Cache
    await _updateLocalContactsCache(user.uid);
  }

  Future<void> removeEmergencyContact(Map<String, dynamic> contact) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    await _db.collection('users').doc(user.uid).update({
      'emergencyContacts': FieldValue.arrayRemove([contact])
    });

    // Update Local Cache
    await _updateLocalContactsCache(user.uid);
  }

  Future<List<Map<String, dynamic>>> getEmergencyContacts() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return [];

    try {
      final doc = await _db.collection('users').doc(user.uid).get();
      if (doc.exists && doc.data()!.containsKey('emergencyContacts')) {
        final contacts = List<Map<String, dynamic>>.from(doc.data()!['emergencyContacts']);
        
        // Update cache
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('cached_contacts_${user.uid}', jsonEncode(contacts));
        
        return contacts;
      }
    } catch (e) {
      // Fallback to cache if offline/error
      final prefs = await SharedPreferences.getInstance();
      final cached = prefs.getString('cached_contacts_${user.uid}');
      if (cached != null) {
        return List<Map<String, dynamic>>.from(jsonDecode(cached));
      }
    }
    return [];
  }

  Future<void> _updateLocalContactsCache(String uid) async {
    try {
      final doc = await _db.collection('users').doc(uid).get();
      if (doc.exists && doc.data()!.containsKey('emergencyContacts')) {
        final contacts = List<Map<String, dynamic>>.from(doc.data()!['emergencyContacts']);
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('cached_contacts_$uid', jsonEncode(contacts));
      }
    } catch (e) {
      debugPrint("Error updating local cache: $e");
    }
  }

  double _deg(double deg) => deg * (pi / 180);
}