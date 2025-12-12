import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/services.dart';
import 'dart:typed_data';

// Background Handler

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Iinitialize Firebase here if i need to save data to Firestore in bg later
  debugPrint("Handling a background message: ${message.messageId}");
}

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FirebaseMessaging _fcm = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications = FlutterLocalNotificationsPlugin();
  
  // Global Navigator Key 
  static final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  bool _isInitialized = false;

  Future<void> init() async {
    if (_isInitialized) return; // Prevent double init

    // Setup Permission
    NotificationSettings settings = await _fcm.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      debugPrint('User granted permission');
      
      // Initialize Local Notifications (for foreground pop-ups)
      await _setupLocalNotifications();
      
      // Setup Message Handlers
      FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
      
      // Foreground Handler
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        _showForegroundNotification(message);
      });

      // App Opened from Background/Terminated
      FirebaseMessaging.onMessageOpenedApp.listen(_handleMessageNavigation);
      
      // Check if app was opened from a terminated state
      final initialMessage = await _fcm.getInitialMessage();
      if (initialMessage != null) {
        _handleMessageNavigation(initialMessage);
      }

      // Save/Refresh Token
      await _saveToken();
      _fcm.onTokenRefresh.listen(_saveTokenToDatabase);
      
      _isInitialized = true;
    }
  }

  Future<void> _setupLocalNotifications() async {
    const AndroidInitializationSettings androidSettings = 
        AndroidInitializationSettings('@mipmap/ic_launcher'); // Ensure icon exists
    
    const DarwinInitializationSettings iosSettings = DarwinInitializationSettings();

    const InitializationSettings initSettings = 
        InitializationSettings(android: androidSettings, iOS: iosSettings);

    await _localNotifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (response) {
        // Handle user tapping on the local notification
        if (response.payload != null) {
           // Navigate based on payload
           // We can parse the payload if needed, but usually we rely on FCM data
           // Note: You might want to handle navigation here too if the payload contains the incidentId
           if (navigatorKey.currentState != null) {
             navigatorKey.currentState?.pushNamed(
               '/details',
               arguments: {'incidentId': response.payload},
             );
           }
        }
      },
    );

    // Create High Importance Channel for Android
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'safetify_high_importance', // id
      'High Importance Notifications', // title
      description: 'This channel is used for important notifications.',
      importance: Importance.max,
    );

    await _localNotifications
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);
  }

  Future<void> _showForegroundNotification(RemoteMessage message) async {
    RemoteNotification? notification = message.notification;
    AndroidNotification? android = message.notification?.android;

    // Check for image in notification or data
    // Backend sends image in 'largeIcon' or 'thumbnail' field of data payload
    String? largeIconUrl = message.data['largeIcon'] ?? message.data['thumbnail'];
    String? bigPictureUrl = message.data['image'] ?? android?.imageUrl;

    // If notification exists, show a local pop-up
    if (notification != null && android != null) {
      
      BigPictureStyleInformation? bigPictureStyleInformation;
      AndroidBitmap<Object>? largeIconBitmap;
      
      // Handle Big Picture (if explicitly sent as 'image')
      if (bigPictureUrl != null) {
         try {
           final ByteData data = await NetworkAssetBundle(Uri.parse(bigPictureUrl)).load("");
           final Uint8List bytes = data.buffer.asUint8List();
           
           bigPictureStyleInformation = BigPictureStyleInformation(
              ByteArrayAndroidBitmap(bytes),
              largeIcon: ByteArrayAndroidBitmap(bytes), 
              contentTitle: notification.title,
              summaryText: notification.body,
              hideExpandedLargeIcon: true,
           );
         } catch (e) {
           debugPrint('Error downloading big picture image: $e');
         }
      }

      // Handle Large Icon (image on right side)
      if (largeIconUrl != null) {
        try {
           final ByteData data = await NetworkAssetBundle(Uri.parse(largeIconUrl)).load("");
           final Uint8List bytes = data.buffer.asUint8List();
           largeIconBitmap = ByteArrayAndroidBitmap(bytes);
        } catch (e) {
           debugPrint('Error downloading large icon image: $e');
        }
      }

      _localNotifications.show(
        notification.hashCode,
        notification.title,
        notification.body,
        NotificationDetails(
          android: AndroidNotificationDetails(
            'safetify_high_importance',
            'High Importance Notifications',
            channelDescription: 'Critical safety alerts',
            icon: '@mipmap/ic_launcher',
            importance: Importance.max,
            priority: Priority.high,
            styleInformation: bigPictureStyleInformation, // Will be null if strictly largeIcon is used
            largeIcon: largeIconBitmap, // This puts the image on the right
          ),
        ),
        payload: message.data['incidentId'], // Pass data to payload
      );
    }
  }

  void _handleMessageNavigation(RemoteMessage message) {
    if (message.data['incidentId'] != null) {
      // Use the GlobalKey to navigate without BuildContext
      navigatorKey.currentState?.pushNamed(
        '/details',
        arguments: {'incidentId': message.data['incidentId']},
      );
    }
  }

  Future<void> _saveToken() async {
    String? token = await _fcm.getToken();
    await _saveTokenToDatabase(token);
  }

  Future<void> _saveTokenToDatabase(String? token) async {
    final user = FirebaseAuth.instance.currentUser;
    if (token != null && user != null) {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .update({'fcmToken': token});
    }
  }
}