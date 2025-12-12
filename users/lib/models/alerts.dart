import 'package:cloud_firestore/cloud_firestore.dart';

class Alert {
  final String id;
  final String incidentId;
  final String category;
  final String locationName;
  final String? photoUrl;
  final double lat;
  final double lon;
  final String description;
  final DateTime sentAt;

  Alert({
    required this.id,
    required this.incidentId,
    required this.category,
    required this.locationName,
    required this.photoUrl,
    required this.lat,
    required this.lon,
    required this.description,
    required this.sentAt,
  });

  factory Alert.fromDoc(QueryDocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data();
    return Alert(
      id: doc.id,
      incidentId: data["incidentId"],
      category: data["category"],
      locationName: data["locationName"],
      photoUrl: data["photoUrl"],
      lat: (data["lat"] as num).toDouble(),
      lon: (data["lon"] as num).toDouble(),
      description: data["description"],
      sentAt: (data["sentAt"] as Timestamp).toDate(),
    );
  }


  double? get latitude => null;

  double? get longitude => null;

  String? get title => null;

  Map<String, dynamic> toMap() {
    return {
      "incidentId": incidentId,
      "category": category,
      "locationName": locationName,
      "photoUrl": photoUrl,
      "lat": lat,
      "lon": lon,
      "description": description,
      "sentAt": sentAt,
    };
  }

  dynamic fromSnapshot(QueryDocumentSnapshot<Map<String, dynamic>> doc) {}
}
