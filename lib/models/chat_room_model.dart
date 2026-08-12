import 'package:cloud_firestore/cloud_firestore.dart';

class ChatRoomModel {
  final String chatRoomId;
  final List<String> participants;
  final DateTime createdAt;
  final String lastMessage;
  final DateTime? lastMessageAt;
  final Map<String, bool> isTyping; // userId -> isTyping
  final String? pinnedMessageId;
  final String? pinnedMessageText;

  ChatRoomModel({
    required this.chatRoomId,
    required this.participants,
    required this.createdAt,
    this.lastMessage = '',
    this.lastMessageAt,
    this.isTyping = const {},
    this.pinnedMessageId,
    this.pinnedMessageText,
  });

  /// Helper to generate deterministic chatRoomId from two user IDs
  static String generateChatRoomId(String uid1, String uid2) {
    List<String> ids = [uid1, uid2]..sort();
    return ids.join('_');
  }

  factory ChatRoomModel.fromMap(Map<String, dynamic> map, String id) {
    Map<String, bool> parsedTyping = {};
    if (map['isTyping'] != null && map['isTyping'] is Map) {
      (map['isTyping'] as Map).forEach((k, v) {
        parsedTyping[k.toString()] = v == true;
      });
    }

    return ChatRoomModel(
      chatRoomId: id,
      participants: List<String>.from(map['participants'] ?? []),
      createdAt: map['createdAt'] != null
          ? (map['createdAt'] is Timestamp
              ? (map['createdAt'] as Timestamp).toDate()
              : DateTime.tryParse(map['createdAt'].toString()) ?? DateTime.now())
          : DateTime.now(),
      lastMessage: map['lastMessage'] ?? '',
      lastMessageAt: map['lastMessageAt'] != null
          ? (map['lastMessageAt'] is Timestamp
              ? (map['lastMessageAt'] as Timestamp).toDate()
              : DateTime.tryParse(map['lastMessageAt'].toString()))
          : null,
      isTyping: parsedTyping,
      pinnedMessageId: map['pinnedMessageId'],
      pinnedMessageText: map['pinnedMessageText'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'participants': participants,
      'createdAt': Timestamp.fromDate(createdAt),
      'lastMessage': lastMessage,
      'lastMessageAt': lastMessageAt != null ? Timestamp.fromDate(lastMessageAt!) : null,
      'isTyping': isTyping,
      'pinnedMessageId': pinnedMessageId,
      'pinnedMessageText': pinnedMessageText,
    };
  }
}
