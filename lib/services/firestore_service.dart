import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';
import '../models/chat_room_model.dart';
import '../models/message_model.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Stream of all registered users
  Stream<List<UserModel>> getUsersStream(String currentUid) {
    return _firestore.collection('users').snapshots().map((snapshot) {
      return snapshot.docs
          .map((doc) => UserModel.fromMap(doc.data(), doc.id))
          .where((user) => user.uid != currentUid)
          .toList();
    });
  }

  /// Get or create a unique chat room between two users
  Future<ChatRoomModel> getOrCreateChatRoom(
      String currentUid, String peerUid) async {
    String chatRoomId = ChatRoomModel.generateChatRoomId(currentUid, peerUid);
    DocumentReference roomRef = _firestore.collection('chats').doc(chatRoomId);

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
  }

  /// Stream of active chat rooms for current user
  Stream<List<ChatRoomModel>> getUserChatsStream(String currentUid) {
    return _firestore
        .collection('chats')
        .where('participants', arrayContains: currentUid)
        .snapshots()
        .map((snapshot) {
      List<ChatRoomModel> rooms = snapshot.docs
          .map((doc) => ChatRoomModel.fromMap(doc.data(), doc.id))
          .toList();

      // Sort by lastMessageAt descending (handling nulls)
      rooms.sort((a, b) {
        if (a.lastMessageAt == null && b.lastMessageAt == null) return 0;
        if (a.lastMessageAt == null) return 1;
        if (b.lastMessageAt == null) return -1;
        return b.lastMessageAt!.compareTo(a.lastMessageAt!);
      });

      return rooms;
    });
  }

  /// Send a message in a chat room and update room lastMessage info
  Future<void> sendMessage({
    required String chatRoomId,
    required String senderId,
    required String receiverId,
    required String messageText,
  }) async {
    if (messageText.trim().isEmpty) return;

    WriteBatch batch = _firestore.batch();

    // 1. Add message doc to subcollection
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

    // 2. Update chat room doc
    DocumentReference roomRef = _firestore.collection('chats').doc(chatRoomId);
    batch.update(roomRef, {
      'lastMessage': messageText.trim(),
      'lastMessageAt': FieldValue.serverTimestamp(),
    });

    await batch.commit();
  }

  /// Stream messages for a chat room ordered by timestamp ascending
  Stream<List<MessageModel>> getMessagesStream(String chatRoomId) {
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
  }
}
