import 'dart:math';
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

  Future<void> updateIncident(String id, Map<String, dynamic> updates) async {
    await _db.collection('incidents').doc(id).update({
      ...updates,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  //uplate image
  

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

  // GET INCIDENTS FOR SPECIFIC USER
  // Stream<List<Incident>> getUserIncidents(String userId) {
  //   return _db
  //       .collection("incidents")
  //       .where("userId", isEqualTo: userId)
  //       .orderBy("createdAt", descending: true)
  //       .snapshots()
  //       .map((snap) =>
  //           snap.docs.map((doc) => Incident.fromDoc(doc)).toList());
  // }

  // Add this to services/firestore_service.dart
Stream<List<Incident>> getUserIncidents(String uid) {
  return _db
      .collection('incidents')
      .where('UserId', isEqualTo: uid) // Filter by specific user
      .orderBy('createdAt', descending: true)
      .snapshots()
      .map((snapshot) => snapshot.docs
          .map((doc) => Incident.fromDoc(doc))
          .toList());
}


  // Future<String> createIncident(Incident incident) async {
  //   final doc = await _db.collection('incidents').add(incident.toMap());
  //   return doc.id;
  // }

  // Future<void> updateIncident(String id, Map<String, dynamic> updates) async {
  //   await _db.collection('incidents').doc(id).update({
  //     ...updates,
  //     'updatedAt': FieldValue.serverTimestamp(),
  //   });
  // }

  // Stream<List<Incident>> getUserIncidents() {
  //   final uid = _auth.currentUser!.uid;

  //   return _db
  //       .collection('incidents')
  //       .where('userId', isEqualTo: uid)
  //       .orderBy('timestamp', descending: true)
  //       .snapshots()
  //       .map((snap) =>
  //           snap.docs.map((doc) => Incident.fromDoc(doc)).toList().cast<Incident>());
  // }

  // Stream<List<Incident>> getAllIncidents({required int limit}) {
  //   return _db
  //       .collection('incidents')
  //       .orderBy('timestamp', descending: true)
  //       .snapshots()
  //       .map((snap) =>
  //           snap.docs.map((doc) => Incident.fromDoc(doc)).toList().cast<Incident>());
  // }

  //2 Stream<List<Incident>> getAllIncidents({int limit = 20}) {
  // return _db
  //     .collection("incidents")
  //     .orderBy("createdAt", descending: true)
  //     .limit(limit)
  //     .snapshots()
  //     .map((snapshot) =>
  //         snapshot.docs.map((doc) => Incident.fromDoc(doc)).toList());



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

  // =====================================================
  // Note: sending FCM messages to arbitrary device tokens from client SDKs
  // isn't supported; implement server-side push sending (HTTP v1 API) or
  // a Cloud Function. This method is a safe placeholder.
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

  double _deg(double deg) => deg * (pi / 180);
}

  // =====================================================
