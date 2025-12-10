import 'package:cloud_firestore/cloud_firestore.dart';

class CommunityUpdate {
  final String id;
  final String title;
  final String description;
  final String category; // Safety, Event, Alert, Maintenance, Info
  final String priority; // Urgent, Important, Info
  final String? imageUrl;
  final DateTime createdAt;
  final String? location;
  final DateTime? eventDate;

  CommunityUpdate({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.priority,
    this.imageUrl,
    required this.createdAt,
    this.location,
    this.eventDate,
  });

  factory CommunityUpdate.fromDoc(QueryDocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data();
    return CommunityUpdate(
      id: doc.id,
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      category: data['category'] ?? 'Info',
      priority: data['priority'] ?? 'Info',
      imageUrl: data['imageUrl'],
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      location: data['location'],
      eventDate: data['eventDate'] != null ? (data['eventDate'] as Timestamp).toDate() : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'category': category,
      'priority': priority,
      'imageUrl': imageUrl,
      'createdAt': createdAt,
      'location': location,
      'eventDate': eventDate,
    };
  }
}
