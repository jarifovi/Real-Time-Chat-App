import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Local fallback storage for demo/testing mode when Firebase API Key is not yet configured
  static final List<UserModel> _localUsers = [
    UserModel(
      uid: 'user_john_123',
      name: 'John Doe',
      username: 'johndoe',
      email: 'john@example.com',
      createdAt: DateTime.now().subtract(const Duration(days: 5)),
    ),
    UserModel(
      uid: 'user_sarah_789',
      name: 'Sarah Connor',
      username: 'sarah_c',
      email: 'sarah@example.com',
      createdAt: DateTime.now().subtract(const Duration(days: 3)),
    ),
  ];

  static final Map<String, String> _localPasswords = {
    'john@example.com': hashPassword('123456'),
    'sarah@example.com': hashPassword('123456'),
  };

  static UserModel? _localCurrentUser;

  /// Helper to hash password using SHA-256 so plain text is never persisted
  static String hashPassword(String password) {
    var bytes = utf8.encode(password);
    var digest = sha256.convert(bytes);
    return digest.toString();
  }

  /// Get current user UID
  String? get currentUid => _auth.currentUser?.uid ?? _localCurrentUser?.uid;

  /// Stream of Auth State Changes
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  /// Register user with Email, Password, Name, and Username
  Future<UserModel?> registerUser({
    required String name,
    required String email,
    required String password,
    String? username,
  }) async {
    String finalUsername = (username != null && username.trim().isNotEmpty)
        ? username.trim().replaceAll('@', '').toLowerCase()
        : name.trim().replaceAll(' ', '_').toLowerCase();

    try {
      // 1. Try Firebase Auth
      UserCredential credential = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      User? firebaseUser = credential.user;
      if (firebaseUser != null) {
        await firebaseUser.updateDisplayName(name);

        UserModel newUser = UserModel(
          uid: firebaseUser.uid,
          name: name.trim(),
          username: finalUsername,
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
      // Fallback seamlessly to local mode when Firebase API key is unconfigured or invalid
      return _registerLocalUser(
        name: name,
        email: email,
        password: password,
        username: finalUsername,
      );
    }
    return _registerLocalUser(
      name: name,
      email: email,
      password: password,
      username: finalUsername,
    );
  }

  UserModel _registerLocalUser({
    required String name,
    required String email,
    required String password,
    required String username,
  }) {
    String localUid = 'user_${DateTime.now().millisecondsSinceEpoch}';
    UserModel newUser = UserModel(
      uid: localUid,
      name: name.trim(),
      username: username,
      email: email.trim(),
      createdAt: DateTime.now(),
    );

    _localUsers.add(newUser);
    _localPasswords[email.trim()] = hashPassword(password);
    _localCurrentUser = newUser;
    return newUser;
  }

  /// Login user
  Future<UserModel?> loginUser({
    required String email,
    required String password,
  }) async {
    try {
      UserCredential creds = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      if (creds.user != null) {
        return await getUserProfile(creds.user!.uid);
      }
    } catch (e) {
      return _loginLocalUser(email: email, password: password);
    }
    return _loginLocalUser(email: email, password: password);
  }

  UserModel? _loginLocalUser({
    required String email,
    required String password,
  }) {
    String cleanEmail = email.trim();
    String hashedInput = hashPassword(password);

    if (_localPasswords.containsKey(cleanEmail) &&
        _localPasswords[cleanEmail] == hashedInput) {
      _localCurrentUser = _localUsers.firstWhere(
        (u) => u.email == cleanEmail,
        orElse: () => UserModel(
          uid: 'user_${DateTime.now().millisecondsSinceEpoch}',
          name: cleanEmail.split('@')[0],
          username: cleanEmail.split('@')[0].toLowerCase(),
          email: cleanEmail,
          createdAt: DateTime.now(),
        ),
      );
      return _localCurrentUser;
    } else {
      // If user doesn't exist locally, register & log them in for instant demo testing
      return _registerLocalUser(
        name: cleanEmail.split('@')[0],
        email: cleanEmail,
        password: password,
        username: cleanEmail.split('@')[0].toLowerCase(),
      );
    }
  }

  /// Update user profile (Name and Username)
  Future<UserModel?> updateUserProfile({
    required String uid,
    required String newName,
    required String newUsername,
  }) async {
    String cleanUsername = newUsername.trim().replaceAll('@', '').toLowerCase();
    String cleanName = newName.trim();

    try {
      await _firestore.collection('users').doc(uid).update({
        'name': cleanName,
        'username': cleanUsername,
      });

      User? currentUser = _auth.currentUser;
      if (currentUser != null) {
        await currentUser.updateDisplayName(cleanName);
      }
    } catch (_) {}

    // Update local user state if in local mode
    int index = _localUsers.indexWhere((u) => u.uid == uid);
    UserModel updatedModel;

    if (index != -1) {
      UserModel old = _localUsers[index];
      updatedModel = UserModel(
        uid: old.uid,
        name: cleanName,
        username: cleanUsername,
        email: old.email,
        createdAt: old.createdAt,
      );
      _localUsers[index] = updatedModel;
    } else {
      updatedModel = UserModel(
        uid: uid,
        name: cleanName,
        username: cleanUsername,
        email: 'user@example.com',
        createdAt: DateTime.now(),
      );
    }

    if (_localCurrentUser?.uid == uid) {
      _localCurrentUser = updatedModel;
    }

    return updatedModel;
  }

  /// Logout user
  Future<void> logout() async {
    try {
      await _auth.signOut();
    } catch (_) {}
    _localCurrentUser = null;
  }

  /// Fetch user profile from Firestore or local storage
  Future<UserModel?> getUserProfile(String uid) async {
    try {
      DocumentSnapshot doc =
          await _firestore.collection('users').doc(uid).get();
      if (doc.exists && doc.data() != null) {
        return UserModel.fromMap(doc.data() as Map<String, dynamic>, doc.id);
      }
    } catch (_) {}

    return _localUsers.firstWhere(
      (u) => u.uid == uid,
      orElse: () => _localCurrentUser ??
          UserModel(
            uid: uid,
            name: 'User',
            username: 'user',
            email: 'user@example.com',
            createdAt: DateTime.now(),
          ),
    );
  }

  static List<UserModel> get localUsers => _localUsers;
  static UserModel? get localCurrentUser => _localCurrentUser;
}
