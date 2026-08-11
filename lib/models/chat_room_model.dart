import 'package:cloud_firestore/cloud_firestore.dart';

class ChatRoomModel {
  final String chatRoomId;
  final List<String> participants;
  final DateTime createdAt;
  final String lastMessage;
  final DateTime? lastMessageAt;

  ChatRoomModel({
    required this.chatRoomId,
    required this.participants,
    required this.createdAt,
    this.lastMessage = '',
    this.lastMessageAt,
  });

  /// Helper to generate deterministic chatRoomId from two user IDs
  static String generateChatRoomId(String uid1, String uid2) {
    List<String> ids = [uid1, uid2]..sort();
    return ids.join('_');
  }

  factory ChatRoomModel.fromMap(Map<String, dynamic> map, String id) {
    return ChatRoomModel(
      chatRoomId: id,
      participants: List<String>.from(map['participants'] ?? []),
      createdAt: map['createdAt'] != null
          ? (map['createdAt'] as Timestamp).toDate()
          : DateTime.now(),
      lastMessage: map['lastMessage'] ?? '',
      lastMessageAt: map['lastMessageAt'] != null
          ? (map['lastMessageAt'] as Timestamp).toDate()
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'participants': participants,
      'createdAt': Timestamp.fromDate(createdAt),
      'lastMessage': lastMessage,
      'lastMessageAt': lastMessageAt != null ? Timestamp.fromDate(lastMessageAt!) : null,
    };
  }
}
