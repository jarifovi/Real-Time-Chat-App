import 'dart:async';
import 'package:flutter/material.dart';
import '../models/chat_room_model.dart';
import '../models/user_model.dart';
import '../services/firestore_service.dart';

class ChatProvider with ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();

  List<ChatRoomModel> _chats = [];
  ChatRoomModel? _activeRoom;
  bool _isLoading = false;
  StreamSubscription<List<ChatRoomModel>>? _chatsSubscription;

  List<ChatRoomModel> get chats => _chats;
  ChatRoomModel? get activeRoom => _activeRoom;
  bool get isLoading => _isLoading;

  /// Listen to user active chats list
  void listenToUserChats(String currentUid) {
    _isLoading = true;
    notifyListeners();

    _chatsSubscription?.cancel();
    _chatsSubscription = _firestoreService
        .getUserChatsStream(currentUid)
        .listen((chatList) {
      _chats = chatList;
      _isLoading = false;
      notifyListeners();
    });
  }

  /// Get existing or create a unique chat room for the two users
  Future<ChatRoomModel> openOrCreateChatRoom({
    required String currentUid,
    required String peerUid,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      ChatRoomModel room = await _firestoreService.getOrCreateChatRoom(
          currentUid, peerUid);
      _activeRoom = room;
      _isLoading = false;
      notifyListeners();
      return room;
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  void setActiveRoom(ChatRoomModel room) {
    _activeRoom = room;
    notifyListeners();
  }

  void clearActiveRoom() {
    _activeRoom = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _chatsSubscription?.cancel();
    super.dispose();
  }
}
