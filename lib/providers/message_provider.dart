import 'dart:async';
import 'package:flutter/material.dart';
import '../models/message_model.dart';
import '../services/firestore_service.dart';

class MessageProvider with ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();

  List<MessageModel> _messages = [];
  bool _isLoading = false;
  StreamSubscription<List<MessageModel>>? _messagesSubscription;

  List<MessageModel> get messages => _messages;
  bool get isLoading => _isLoading;

  /// Subscribe to real-time messages for an active chat room
  void listenToMessages(String chatRoomId) {
    _isLoading = true;
    notifyListeners();

    _messagesSubscription?.cancel();
    _messagesSubscription = _firestoreService
        .getMessagesStream(chatRoomId)
        .listen((messageList) {
      _messages = messageList;
      _isLoading = false;
      notifyListeners();
    });
  }

  /// Send message to chat room
  Future<void> sendMessage({
    required String chatRoomId,
    required String senderId,
    required String receiverId,
    required String messageText,
    String? replyToId,
    String? replyToText,
    String type = 'text',
    String? mediaUrl,
  }) async {
    try {
      await _firestoreService.sendMessage(
        chatRoomId: chatRoomId,
        senderId: senderId,
        receiverId: receiverId,
        messageText: messageText,
        replyToId: replyToId,
        replyToText: replyToText,
        type: type,
        mediaUrl: mediaUrl,
      );
    } catch (_) {}
  }

  Future<void> toggleReaction({
    required String chatRoomId,
    required String messageId,
    required String uid,
    required String emoji,
  }) async {
    await _firestoreService.toggleReaction(chatRoomId, messageId, uid, emoji);
  }

  Future<void> updateTypingStatus({
    required String chatRoomId,
    required String uid,
    required bool isTyping,
  }) async {
    await _firestoreService.updateTypingStatus(chatRoomId, uid, isTyping);
  }

  Future<void> deleteMessage({
    required String chatRoomId,
    required String messageId,
  }) async {
    await _firestoreService.deleteMessage(chatRoomId, messageId);
  }

  Future<void> editMessage({
    required String chatRoomId,
    required String messageId,
    required String newText,
  }) async {
    await _firestoreService.editMessage(chatRoomId, messageId, newText);
  }

  Future<void> pinMessage({
    required String chatRoomId,
    required String messageId,
    required String messageText,
  }) async {
    await _firestoreService.pinMessage(chatRoomId, messageId, messageText);
  }

  Future<void> unpinMessage({
    required String chatRoomId,
  }) async {
    await _firestoreService.unpinMessage(chatRoomId);
  }

  void clearMessages() {
    _messagesSubscription?.cancel();
    _messages = [];
    notifyListeners();
  }

  @override
  void dispose() {
    _messagesSubscription?.cancel();
    super.dispose();
  }
}
