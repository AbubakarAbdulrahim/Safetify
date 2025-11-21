import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:safetify/models/incidents.dart';

class IncidentService {
  final storage = FirebaseStorage.instance;
  final firestore = FirebaseFirestore.instance;
  final auth = FirebaseAuth.instance;

  Future<String> uploadPhoto(File file) async {
    final id = DateTime.now().millisecondsSinceEpoch.toString();

    final ref = storage.ref().child("incident_photos/$id.jpg");

    await ref.putFile(file);
    return await ref.getDownloadURL();
  }

  Future<void> createIncident(Incident incident) async {
    await firestore.collection("incidents").add(incident.toMap());
  }
}
