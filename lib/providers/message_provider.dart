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
  }) async {
    try {
      await _firestoreService.sendMessage(
        chatRoomId: chatRoomId,
        senderId: senderId,
        receiverId: receiverId,
        messageText: messageText,
      );
    } catch (e) {
      print('Error sending message: $e');
      rethrow;
    }
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
