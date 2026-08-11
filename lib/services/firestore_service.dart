import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';
import '../models/chat_room_model.dart';
import '../models/message_model.dart';
import 'auth_service.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Local fallback storage for demo testing
  static final List<ChatRoomModel> _localChatRooms = [];
  static final Map<String, List<MessageModel>> _localMessages = {};
  static final StreamController<List<UserModel>> _usersStreamCtrl =
      StreamController<List<UserModel>>.broadcast();
  static final StreamController<List<ChatRoomModel>> _chatsStreamCtrl =
      StreamController<List<ChatRoomModel>>.broadcast();
  static final Map<String, StreamController<List<MessageModel>>>
      _roomMessageStreamCtrls = {};

  /// Stream of all registered users
  Stream<List<UserModel>> getUsersStream(String currentUid) {
    try {
      return _firestore.collection('users').snapshots().map((snapshot) {
        return snapshot.docs
            .map((doc) => UserModel.fromMap(doc.data(), doc.id))
            .where((user) => user.uid != currentUid)
            .toList();
      });
    } catch (_) {
      return _getLocalUsersStream(currentUid);
    }
  }

  Stream<List<UserModel>> _getLocalUsersStream(String currentUid) async* {
    yield AuthService.localUsers.where((u) => u.uid != currentUid).toList();
  }

  /// Get or create a unique chat room between two users
  Future<ChatRoomModel> getOrCreateChatRoom(
      String currentUid, String peerUid) async {
    String chatRoomId = ChatRoomModel.generateChatRoomId(currentUid, peerUid);

    try {
      DocumentReference roomRef =
          _firestore.collection('chats').doc(chatRoomId);
      DocumentSnapshot doc = await roomRef.get();

      if (!doc.exists) {
        ChatRoomModel newRoom = ChatRoomModel(
          chatRoomId: chatRoomId,
          participants: [currentUid, peerUid]..sort(),
          createdAt: DateTime.now(),
          lastMessage: '',
          lastMessageAt: null,
        );

        await roomRef.set(newRoom.toMap());
        return newRoom;
      } else {
        return ChatRoomModel.fromMap(
            doc.data() as Map<String, dynamic>, doc.id);
      }
    } catch (_) {
      // Local fallback
      int index =
          _localChatRooms.indexWhere((r) => r.chatRoomId == chatRoomId);
      if (index != -1) {
        return _localChatRooms[index];
      } else {
        ChatRoomModel newRoom = ChatRoomModel(
          chatRoomId: chatRoomId,
          participants: [currentUid, peerUid]..sort(),
          createdAt: DateTime.now(),
          lastMessage: '',
          lastMessageAt: null,
        );
        _localChatRooms.add(newRoom);
        _notifyLocalChats(currentUid);
        return newRoom;
      }
    }
  }

  /// Stream of active chat rooms for current user
  Stream<List<ChatRoomModel>> getUserChatsStream(String currentUid) {
    try {
      return _firestore
          .collection('chats')
          .where('participants', arrayContains: currentUid)
          .snapshots()
          .map((snapshot) {
        List<ChatRoomModel> rooms = snapshot.docs
            .map((doc) => ChatRoomModel.fromMap(doc.data(), doc.id))
            .toList();

        rooms.sort((a, b) {
          if (a.lastMessageAt == null && b.lastMessageAt == null) return 0;
          if (a.lastMessageAt == null) return 1;
          if (b.lastMessageAt == null) return -1;
          return b.lastMessageAt!.compareTo(a.lastMessageAt!);
        });

        return rooms;
      });
    } catch (_) {
      return _getLocalUserChatsStream(currentUid);
    }
  }

  Stream<List<ChatRoomModel>> _getLocalUserChatsStream(
      String currentUid) async* {
    yield _localChatRooms
        .where((r) => r.participants.contains(currentUid))
        .toList();
  }

  /// Send a message in a chat room and update room lastMessage info
  Future<void> sendMessage({
    required String chatRoomId,
    required String senderId,
    required String receiverId,
    required String messageText,
  }) async {
    if (messageText.trim().isEmpty) return;

    try {
      WriteBatch batch = _firestore.batch();

      DocumentReference messageRef = _firestore
          .collection('chats')
          .doc(chatRoomId)
          .collection('messages')
          .doc();

      MessageModel newMessage = MessageModel(
        messageId: messageRef.id,
        senderId: senderId,
        receiverId: receiverId,
        message: messageText.trim(),
        timestamp: DateTime.now(),
      );

      batch.set(messageRef, newMessage.toMap());

      DocumentReference roomRef =
          _firestore.collection('chats').doc(chatRoomId);
      batch.update(roomRef, {
        'lastMessage': messageText.trim(),
        'lastMessageAt': FieldValue.serverTimestamp(),
      });

      await batch.commit();
    } catch (_) {
      // Local fallback
      if (!_localMessages.containsKey(chatRoomId)) {
        _localMessages[chatRoomId] = [];
      }

      MessageModel newMessage = MessageModel(
        messageId: 'msg_${DateTime.now().millisecondsSinceEpoch}',
        senderId: senderId,
        receiverId: receiverId,
        message: messageText.trim(),
        timestamp: DateTime.now(),
      );

      _localMessages[chatRoomId]!.add(newMessage);

      int roomIdx =
          _localChatRooms.indexWhere((r) => r.chatRoomId == chatRoomId);
      if (roomIdx != -1) {
        ChatRoomModel old = _localChatRooms[roomIdx];
        _localChatRooms[roomIdx] = ChatRoomModel(
          chatRoomId: old.chatRoomId,
          participants: old.participants,
          createdAt: old.createdAt,
          lastMessage: messageText.trim(),
          lastMessageAt: DateTime.now(),
        );
      }

      _notifyLocalMessages(chatRoomId);
      _notifyLocalChats(senderId);
    }
  }

  /// Stream messages for a chat room ordered by timestamp ascending
  Stream<List<MessageModel>> getMessagesStream(String chatRoomId) {
    try {
      return _firestore
          .collection('chats')
          .doc(chatRoomId)
          .collection('messages')
          .orderBy('timestamp', descending: false)
          .snapshots()
          .map((snapshot) {
        return snapshot.docs
            .map((doc) => MessageModel.fromMap(doc.data(), doc.id))
            .toList();
      });
    } catch (_) {
      return _getLocalMessagesStream(chatRoomId);
    }
  }

  Stream<List<MessageModel>> _getLocalMessagesStream(
      String chatRoomId) async* {
    yield _localMessages[chatRoomId] ?? [];
  }

  void _notifyLocalMessages(String chatRoomId) {
    if (_roomMessageStreamCtrls.containsKey(chatRoomId)) {
      _roomMessageStreamCtrls[chatRoomId]!
          .add(_localMessages[chatRoomId] ?? []);
    }
  }

  void _notifyLocalChats(String uid) {
    _chatsStreamCtrl.add(
        _localChatRooms.where((r) => r.participants.contains(uid)).toList());
  }
}
