import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Helper to hash password using SHA-256 so plain text is never persisted
  static String hashPassword(String password) {
    var bytes = utf8.encode(password);
    var digest = sha256.convert(bytes);
    return digest.toString();
  }

  /// Get current user UID
  String? get currentUid => _auth.currentUser?.uid;

  /// Stream of Auth State Changes
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  /// Register user with Email and Password
  Future<UserModel?> registerUser({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      // Create user in Firebase Auth
      UserCredential credential = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      User? firebaseUser = credential.user;
      if (firebaseUser != null) {
        // Update display name
        await firebaseUser.updateDisplayName(name);

        UserModel newUser = UserModel(
          uid: firebaseUser.uid,
          name: name.trim(),
          email: email.trim(),
          createdAt: DateTime.now(),
        );

        // Store profile in Firestore without plain text password
        await _firestore
            .collection('users')
            .doc(firebaseUser.uid)
            .set(newUser.toMap());

        return newUser;
      }
    } catch (e) {
      rethrow;
    }
    return null;
  }

  /// Login user
  Future<UserCredential> loginUser({
    required String email,
    required String password,
  }) async {
    return await _auth.signInWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
  }

  /// Logout user
  Future<void> logout() async {
    await _auth.signOut();
  }

  /// Fetch user profile from Firestore
  Future<UserModel?> getUserProfile(String uid) async {
    try {
      DocumentSnapshot doc =
          await _firestore.collection('users').doc(uid).get();
      if (doc.exists && doc.data() != null) {
        return UserModel.fromMap(doc.data() as Map<String, dynamic>, doc.id);
      }
    } catch (e) {
      print('Error fetching user profile: $e');
    }
    return null;
  }
}
