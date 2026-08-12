import 'package:cloud_firestore/cloud_firestore.dart';

class MessageModel {
  final String messageId;
  final String senderId;
  final String receiverId;
  final String message;
  final DateTime timestamp;
  final Map<String, String> reactions; // userId -> emoji
  final String? replyToId;
  final String? replyToText;
  final bool isEdited;
  final String type; // 'text' | 'image' | 'audio'
  final String? mediaUrl;

  MessageModel({
    required this.messageId,
    required this.senderId,
    required this.receiverId,
    required this.message,
    required this.timestamp,
    this.reactions = const {},
    this.replyToId,
    this.replyToText,
    this.isEdited = false,
    this.type = 'text',
    this.mediaUrl,
  });

  factory MessageModel.fromMap(Map<String, dynamic> map, String id) {
    Map<String, String> parsedReactions = {};
    if (map['reactions'] != null && map['reactions'] is Map) {
      (map['reactions'] as Map).forEach((k, v) {
        parsedReactions[k.toString()] = v.toString();
      });
    }

    return MessageModel(
      messageId: id,
      senderId: map['senderId'] ?? '',
      receiverId: map['receiverId'] ?? '',
      message: map['message'] ?? '',
      timestamp: map['timestamp'] != null
          ? (map['timestamp'] is Timestamp
              ? (map['timestamp'] as Timestamp).toDate()
              : DateTime.tryParse(map['timestamp'].toString()) ?? DateTime.now())
          : DateTime.now(),
      reactions: parsedReactions,
      replyToId: map['replyToId'],
      replyToText: map['replyToText'],
      isEdited: map['isEdited'] ?? false,
      type: map['type'] ?? 'text',
      mediaUrl: map['mediaUrl'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'senderId': senderId,
      'receiverId': receiverId,
      'message': message,
      'timestamp': Timestamp.fromDate(timestamp),
      'reactions': reactions,
      'replyToId': replyToId,
      'replyToText': replyToText,
      'isEdited': isEdited,
      'type': type,
      'mediaUrl': mediaUrl,
    };
  }
}
