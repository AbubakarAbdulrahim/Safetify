import 'package:cloud_firestore/cloud_firestore.dart';

class User {
  final String uid;
  final String? name;
  final String? email;
  final String? phone;
  final double? lat;
  final double? lon;
  final String? fcmToken;
  final DateTime? lastUpdated;

  User({
    required this.uid,
    this.name,
    this.email,
    this.phone,
    this.lat,
    this.lon,
    this.fcmToken,
    this.lastUpdated,
  });

  factory User.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
  final data = doc.data()!; // Note: We add ! because we check exists later
  return User(
    uid: doc.id,
      name: data["name"],
      email: data["email"],
      phone: data["phone"],
      lat: data["lat"]?.toDouble(),
      lon: data["lon"]?.toDouble(),
      fcmToken: data["fcmToken"],
      lastUpdated: data["lastUpdated"] != null
          ? (data["lastUpdated"] as Timestamp).toDate()
          : null,
    );
  }

  static User fromDocument(QueryDocumentSnapshot<Map<String, dynamic>> doc) {
  return User.fromDoc(doc); // Redirects to your existing logic
}
}
