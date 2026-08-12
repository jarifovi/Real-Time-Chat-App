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
    String? replyToId,
    String? replyToText,
    String type = 'text',
    String? mediaUrl,
  }) async {
    if (messageText.trim().isEmpty && mediaUrl == null) return;

    try {
      WriteBatch batch = _firestore.batch();

      DocumentReference messageRef = _firestore
          .collection('chats')
          .doc(chatRoomId)
          .collection('messages')
          .doc();

      String displaySnippet = type == 'image'
          ? '📷 Photo'
          : (type == 'audio' ? '🎙️ Voice Note' : messageText.trim());

      MessageModel newMessage = MessageModel(
        messageId: messageRef.id,
        senderId: senderId,
        receiverId: receiverId,
        message: messageText.trim(),
        timestamp: DateTime.now(),
        replyToId: replyToId,
        replyToText: replyToText,
        type: type,
        mediaUrl: mediaUrl,
      );

      batch.set(messageRef, newMessage.toMap());

      DocumentReference roomRef =
          _firestore.collection('chats').doc(chatRoomId);
      batch.update(roomRef, {
        'lastMessage': displaySnippet,
        'lastMessageAt': FieldValue.serverTimestamp(),
        'isTyping.$senderId': false,
      });

      await batch.commit();
    } catch (_) {
      // Local fallback
      if (!_localMessages.containsKey(chatRoomId)) {
        _localMessages[chatRoomId] = [];
      }

      String displaySnippet = type == 'image'
          ? '📷 Photo'
          : (type == 'audio' ? '🎙️ Voice Note' : messageText.trim());

      MessageModel newMessage = MessageModel(
        messageId: 'msg_${DateTime.now().millisecondsSinceEpoch}',
        senderId: senderId,
        receiverId: receiverId,
        message: messageText.trim(),
        timestamp: DateTime.now(),
        replyToId: replyToId,
        replyToText: replyToText,
        type: type,
        mediaUrl: mediaUrl,
      );

      _localMessages[chatRoomId]!.add(newMessage);

      int roomIdx =
          _localChatRooms.indexWhere((r) => r.chatRoomId == chatRoomId);
      if (roomIdx != -1) {
        ChatRoomModel old = _localChatRooms[roomIdx];
        Map<String, bool> updatedTyping = Map.from(old.isTyping)..[senderId] = false;

        _localChatRooms[roomIdx] = ChatRoomModel(
          chatRoomId: old.chatRoomId,
          participants: old.participants,
          createdAt: old.createdAt,
          lastMessage: displaySnippet,
          lastMessageAt: DateTime.now(),
          isTyping: updatedTyping,
          pinnedMessageId: old.pinnedMessageId,
          pinnedMessageText: old.pinnedMessageText,
        );
      }

      _notifyLocalMessages(chatRoomId);
      _notifyLocalChats(senderId);
    }
  }

  /// Update typing status for current user in chat room
  Future<void> updateTypingStatus(
      String chatRoomId, String uid, bool isTyping) async {
    try {
      await _firestore.collection('chats').doc(chatRoomId).update({
        'isTyping.$uid': isTyping,
      });
    } catch (_) {
      int roomIdx =
          _localChatRooms.indexWhere((r) => r.chatRoomId == chatRoomId);
      if (roomIdx != -1) {
        ChatRoomModel old = _localChatRooms[roomIdx];
        Map<String, bool> updatedTyping = Map.from(old.isTyping)..[uid] = isTyping;

        _localChatRooms[roomIdx] = ChatRoomModel(
          chatRoomId: old.chatRoomId,
          participants: old.participants,
          createdAt: old.createdAt,
          lastMessage: old.lastMessage,
          lastMessageAt: old.lastMessageAt,
          isTyping: updatedTyping,
          pinnedMessageId: old.pinnedMessageId,
          pinnedMessageText: old.pinnedMessageText,
        );
        _notifyLocalChats(uid);
      }
    }
  }

  /// Toggle emoji reaction on a message
  Future<void> toggleReaction(
      String chatRoomId, String messageId, String uid, String emoji) async {
    try {
      DocumentReference docRef = _firestore
          .collection('chats')
          .doc(chatRoomId)
          .collection('messages')
          .doc(messageId);

      DocumentSnapshot doc = await docRef.get();
      if (doc.exists) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        Map<String, dynamic> reactions =
            Map<String, dynamic>.from(data['reactions'] ?? {});

        if (reactions[uid] == emoji) {
          reactions.remove(uid);
        } else {
          reactions[uid] = emoji;
        }

        await docRef.update({'reactions': reactions});
      }
    } catch (_) {
      if (_localMessages.containsKey(chatRoomId)) {
        int msgIdx =
            _localMessages[chatRoomId]!.indexWhere((m) => m.messageId == messageId);
        if (msgIdx != -1) {
          MessageModel old = _localMessages[chatRoomId]![msgIdx];
          Map<String, String> updatedReactions = Map.from(old.reactions);
          if (updatedReactions[uid] == emoji) {
            updatedReactions.remove(uid);
          } else {
            updatedReactions[uid] = emoji;
          }

          _localMessages[chatRoomId]![msgIdx] = MessageModel(
            messageId: old.messageId,
            senderId: old.senderId,
            receiverId: old.receiverId,
            message: old.message,
            timestamp: old.timestamp,
            reactions: updatedReactions,
            replyToId: old.replyToId,
            replyToText: old.replyToText,
            isEdited: old.isEdited,
            type: old.type,
            mediaUrl: old.mediaUrl,
          );
          _notifyLocalMessages(chatRoomId);
        }
      }
    }
  }

  /// Pin message to chat room header
  Future<void> pinMessage(
      String chatRoomId, String messageId, String messageText) async {
    try {
      await _firestore.collection('chats').doc(chatRoomId).update({
        'pinnedMessageId': messageId,
        'pinnedMessageText': messageText,
      });
    } catch (_) {
      int roomIdx =
          _localChatRooms.indexWhere((r) => r.chatRoomId == chatRoomId);
      if (roomIdx != -1) {
        ChatRoomModel old = _localChatRooms[roomIdx];
        _localChatRooms[roomIdx] = ChatRoomModel(
          chatRoomId: old.chatRoomId,
          participants: old.participants,
          createdAt: old.createdAt,
          lastMessage: old.lastMessage,
          lastMessageAt: old.lastMessageAt,
          isTyping: old.isTyping,
          pinnedMessageId: messageId,
          pinnedMessageText: messageText,
        );
        _notifyLocalChats(old.participants.first);
      }
    }
  }

  /// Unpin message from chat room header
  Future<void> unpinMessage(String chatRoomId) async {
    try {
      await _firestore.collection('chats').doc(chatRoomId).update({
        'pinnedMessageId': FieldValue.delete(),
        'pinnedMessageText': FieldValue.delete(),
      });
    } catch (_) {
      int roomIdx =
          _localChatRooms.indexWhere((r) => r.chatRoomId == chatRoomId);
      if (roomIdx != -1) {
        ChatRoomModel old = _localChatRooms[roomIdx];
        _localChatRooms[roomIdx] = ChatRoomModel(
          chatRoomId: old.chatRoomId,
          participants: old.participants,
          createdAt: old.createdAt,
          lastMessage: old.lastMessage,
          lastMessageAt: old.lastMessageAt,
          isTyping: old.isTyping,
          pinnedMessageId: null,
          pinnedMessageText: null,
        );
        _notifyLocalChats(old.participants.first);
      }
    }
  }

  /// Delete message
  Future<void> deleteMessage(String chatRoomId, String messageId) async {
    try {
      await _firestore
          .collection('chats')
          .doc(chatRoomId)
          .collection('messages')
          .doc(messageId)
          .delete();
    } catch (_) {
      if (_localMessages.containsKey(chatRoomId)) {
        _localMessages[chatRoomId]!
            .removeWhere((m) => m.messageId == messageId);
        _notifyLocalMessages(chatRoomId);
      }
    }
  }

  /// Edit message text
  Future<void> editMessage(
      String chatRoomId, String messageId, String newText) async {
    try {
      await _firestore
          .collection('chats')
          .doc(chatRoomId)
          .collection('messages')
          .doc(messageId)
          .update({
        'message': newText.trim(),
        'isEdited': true,
      });
    } catch (_) {
      if (_localMessages.containsKey(chatRoomId)) {
        int msgIdx =
            _localMessages[chatRoomId]!.indexWhere((m) => m.messageId == messageId);
        if (msgIdx != -1) {
          MessageModel old = _localMessages[chatRoomId]![msgIdx];
          _localMessages[chatRoomId]![msgIdx] = MessageModel(
            messageId: old.messageId,
            senderId: old.senderId,
            receiverId: old.receiverId,
            message: newText.trim(),
            timestamp: old.timestamp,
            reactions: old.reactions,
            replyToId: old.replyToId,
            replyToText: old.replyToText,
            isEdited: true,
            type: old.type,
            mediaUrl: old.mediaUrl,
          );
          _notifyLocalMessages(chatRoomId);
        }
      }
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
