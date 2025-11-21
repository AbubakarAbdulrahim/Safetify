import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class NotificationService {
  final FirebaseMessaging _fcm = FirebaseMessaging.instance;
  final _db = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  Future<void> init(BuildContext context) async {
    // Request notification permission
    await _fcm.requestPermission(alert: true, badge: true, sound: true);

    // Save user token
    final token = await _fcm.getToken();
    if (token != null && _auth.currentUser != null) {
      await _db.collection('users').doc(_auth.currentUser!.uid).update({'fcmToken': token});
    }

    // Listen for foreground messages
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      if (message.notification != null) {
        final title = message.notification!.title ?? 'Safetify Alert';
        final body = message.notification!.body ?? 'You have a new update.';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('$title\n$body')),
        );
      }
    });

    // Optional: handle tap to open alert
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      if (message.data['incidentId'] != null) {
        Navigator.pushNamed(context, '/details',
            arguments: {'incidentId': message.data['incidentId']});
      }
    });
  }
}

// import 'package:firebase_messaging/firebase_messaging.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';

// // 1. Background Handler (Must be top-level, outside the class)
// @pragma('vm:entry-point')
// Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
//   // You can initialize Firebase here if you need to save data to Firestore in bg
//   print("Handling a background message: ${message.messageId}");
// }

// class NotificationService {
//   // Singleton pattern
//   static final NotificationService _instance = NotificationService._internal();
//   factory NotificationService() => _instance;
//   NotificationService._internal();

//   final FirebaseMessaging _fcm = FirebaseMessaging.instance;
//   final FlutterLocalNotificationsPlugin _localNotifications = FlutterLocalNotificationsPlugin();
  
//   // Global Navigator Key (Assign this in your main.dart!)
//   static final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

//   bool _isInitialized = false;

//   Future<void> init() async {
//     if (_isInitialized) return; // Prevent double init

//     // 2. Setup Permission
//     NotificationSettings settings = await _fcm.requestPermission(
//       alert: true,
//       badge: true,
//       sound: true,
//       provisional: false,
//     );

//     if (settings.authorizationStatus == AuthorizationStatus.authorized) {
//       print('User granted permission');
      
//       // 3. Initialize Local Notifications (for foreground pop-ups)
//       await _setupLocalNotifications();
      
//       // 4. Setup Message Handlers
//       FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
      
//       // Foreground Handler
//       FirebaseMessaging.onMessage.listen((RemoteMessage message) {
//         _showForegroundNotification(message);
//       });

//       // App Opened from Background/Terminated
//       FirebaseMessaging.onMessageOpenedApp.listen(_handleMessageNavigation);
      
//       // Check if app was opened from a terminated state
//       final initialMessage = await _fcm.getInitialMessage();
//       if (initialMessage != null) {
//         _handleMessageNavigation(initialMessage);
//       }

//       // 5. Save/Refresh Token
//       await _saveToken();
//       _fcm.onTokenRefresh.listen(_saveTokenToDatabase);
      
//       _isInitialized = true;
//     }
//   }

//   Future<void> _setupLocalNotifications() async {
//     const AndroidInitializationSettings androidSettings = 
//         AndroidInitializationSettings('@mipmap/ic_launcher'); // Ensure icon exists
    
//     const DarwinInitializationSettings iosSettings = DarwinInitializationSettings();

//     const InitializationSettings initSettings = 
//         InitializationSettings(android: androidSettings, iOS: iosSettings);

//     await _localNotifications.initialize(
//       initSettings,
//       onDidReceiveNotificationResponse: (response) {
//         // Handle user tapping on the local notification
//         // You might need to parse the payload string back to JSON
//         if (response.payload != null) {
//            // Navigate based on payload
//         }
//       },
//     );

//     // Create High Importance Channel for Android
//     const AndroidNotificationChannel channel = AndroidNotificationChannel(
//       'safetify_high_importance', // id
//       'High Importance Notifications', // title
//       description: 'This channel is used for important notifications.',
//       importance: Importance.max,
//     );

//     await _localNotifications
//         .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
//         ?.createNotificationChannel(channel);
//   }

//   void _showForegroundNotification(RemoteMessage message) {
//     RemoteNotification? notification = message.notification;
//     AndroidNotification? android = message.notification?.android;

//     // If notification exists, show a local pop-up
//     if (notification != null && android != null) {
//       _localNotifications.show(
//         notification.hashCode,
//         notification.title,
//         notification.body,
//         NotificationDetails(
//           android: AndroidNotificationDetails(
//             'safetify_high_importance',
//             'High Importance Notifications',
//             channelDescription: 'Critical safety alerts',
//             icon: '@mipmap/ic_launcher',
//             importance: Importance.max,
//             priority: Priority.high,
//           ),
//         ),
//         payload: message.data['incidentId'], // Pass data to payload
//       );
//     }
//   }

//   void _handleMessageNavigation(RemoteMessage message) {
//     if (message.data['incidentId'] != null) {
//       // Use the GlobalKey to navigate without BuildContext
//       navigatorKey.currentState?.pushNamed(
//         '/details',
//         arguments: {'incidentId': message.data['incidentId']},
//       );
//     }
//   }

//   Future<void> _saveToken() async {
//     String? token = await _fcm.getToken();
//     await _saveTokenToDatabase(token);
//   }

//   Future<void> _saveTokenToDatabase(String? token) async {
//     final user = FirebaseAuth.instance.currentUser;
//     if (token != null && user != null) {
//       await FirebaseFirestore.instance
//           .collection('users')
//           .doc(user.uid)
//           .update({'fcmToken': token});
//     }
//   }
// }