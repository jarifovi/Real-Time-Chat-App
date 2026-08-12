import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String uid;
  final String name;
  final String username;
  final String email;
  final DateTime createdAt;

  UserModel({
    required this.uid,
    required this.name,
    required this.username,
    required this.email,
    required this.createdAt,
  });

  String get formattedUsername =>
      username.startsWith('@') ? username : '@$username';

  factory UserModel.fromMap(Map<String, dynamic> map, String id) {
    String rawName = map['name'] ?? '';
    String fallbackUsername = map['username'] ??
        (rawName.isNotEmpty
            ? rawName.toLowerCase().replaceAll(' ', '_')
            : 'user_${id.substring(0, 4)}');

    return UserModel(
      uid: id,
      name: rawName,
      username: fallbackUsername,
      email: map['email'] ?? '',
      createdAt: map['createdAt'] != null
          ? (map['createdAt'] is Timestamp
              ? (map['createdAt'] as Timestamp).toDate()
              : DateTime.tryParse(map['createdAt'].toString()) ?? DateTime.now())
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'username': username,
      'email': email,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}
