import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseMessaging _fcm = FirebaseMessaging.instance;

  // register
  Future<User?> register(
    String fullName,
    String email,
    String phoneNumber,
    String password,
  ) async {
    try {
      final cred = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final uid = cred.user!.uid;

      // Get FCM Token
      final token = await _fcm.getToken();

      await _db.collection('users').doc(uid).set({
        'name': fullName,
        'email': email,
        'phoneNumber': phoneNumber,
        'role': 'user',
        'profileImage': '',
        'joinedAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
        'latitude': null,
        'longitude': null,
        'fcmToken': token,
      });

      return cred.user;
    } on FirebaseAuthException catch (e) {
      throw Exception(_handleAuthError(e.code));
    }
  }

  // login
  Future<User?> login(String email, String password) async {
    try {
      final cred = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Refresh FCM token
      final token = await _fcm.getToken();

      await _db.collection('users').doc(cred.user!.uid).update({
        'fcmToken': token,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      return cred.user;
    } on FirebaseAuthException catch (e) {
      throw Exception(_handleAuthError(e.code));
    }
  }

  // logout
  Future<void> logout() async {
    try {
      // clear FCM token on logout
      final uid = _auth.currentUser?.uid;
      if (uid != null) {
        await _db.collection('users').doc(uid).update({
          'fcmToken': null,
        });
      }

      await _auth.signOut();
    } catch (e) {
      throw Exception("Failed to log out. Try again.");
    }
  }

  // reset password
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      throw Exception(e.message ?? "Failed to send reset email");
    }
  }

  // auth stream
  Stream<User?> get authState => _auth.authStateChanges();

  User? get currentUser => _auth.currentUser;

  // error handler
  String _handleAuthError(String code) {
    switch (code) {
      case 'email-already-in-use':
        return 'This email is already registered.';
      case 'invalid-email':
        return 'Invalid email format.';
      case 'weak-password':
        return 'Password is too weak.';
      case 'user-not-found':
        return 'No user found with this email.';
      case 'wrong-password':
        return 'Incorrect password.';
      case 'user-disabled':
        return 'Your account has been disabled.';
      default:
        return 'Authentication failed. Try again.';
    }
  }
}
