import 'dart:async';
import 'package:firebase_core/firebase_core.dart';
import 'package:safetify/firebase_options.dart';
import 'package:safetify/services/notification_service.dart';

class AppInitialization {
  static Future<void>? initialization;

  static Future<void> init() async {
    initialization = _initFirebase();
    return initialization;
  }

  static Future<void> _initFirebase() async {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    NotificationService().init();
  }
}
