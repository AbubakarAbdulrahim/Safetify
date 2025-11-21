import 'package:cloud_firestore/cloud_firestore.dart';

class Incident {
  final String id;
  final String category;
  final String description;
  final double lat;
  final double lon;
  final String locationName;
  final String photoUrl;
  final String userId;
  final bool verified;
  final DateTime createdAt;

  Incident({
    required this.id,
    required this.category,
    required this.description,
    required this.lat,
    required this.lon,
    required this.locationName,
    required this.photoUrl,
    required this.userId,
    this.verified = false,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      "id": id,
      "category": category,
      "description": description,
      "lat": lat,
      "lon": lon,
      "locationName": locationName,
      "photoUrl": photoUrl,
      "userId": userId,
      "verified": verified,
      "createdAt": createdAt.toIso8601String(),
    };
  }

  factory Incident.fromDoc(
      QueryDocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data();

    return Incident(
      id: doc.id,
      category: data["category"] ?? "",
      description: data["description"] ?? "",
      lat: (data["lat"] ?? 0).toDouble(),
      lon: (data["lon"] ?? 0).toDouble(),
      locationName: data["locationName"] ?? "",
      photoUrl: data["photoUrl"] ?? "",
      userId: data["userId"] ?? "",
      verified: data["verified"] ?? false,
      createdAt: DateTime.tryParse(data["createdAt"] ?? "") ??
          DateTime.now(),
    );
  }
}
