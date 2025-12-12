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
  final bool resolved;
  final DateTime createdAt;
  final int upvotes;
  final int downvotes;
  final Map<String, dynamic> userVotes;

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
    this.resolved = false,
    required this.createdAt,
    this.upvotes = 0,
    this.downvotes = 0,
    this.userVotes = const {},
  });

  Map<String, dynamic> toMap() {
    return {
      "category": category,
      "description": description,
      "lat": lat,
      "lon": lon,
      "locationName": locationName,
      "photoUrl": photoUrl,
      "userId": userId,
      "verified": verified,
      "resolved": resolved,
      "createdAt": Timestamp.fromDate(createdAt),
      "upvotes": upvotes,
      "downvotes": downvotes,
      "userVotes": userVotes,
    };
  }

  factory Incident.fromDoc(
      DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};

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
      resolved: data["resolved"] ?? false,
      createdAt: _parseDateTime(data["createdAt"]),
      upvotes: data["upvotes"] ?? 0,
      downvotes: data["downvotes"] ?? 0,
      userVotes: data["userVotes"] ?? {},
    );
  }

  static DateTime _parseDateTime(dynamic value) {
    if (value == null) return DateTime.now();
    if (value is Timestamp) return value.toDate();
    if (value is String) return DateTime.tryParse(value) ?? DateTime.now();
    return DateTime.now();
  }

  void operator [](String other) {}
}
