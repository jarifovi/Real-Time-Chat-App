import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/chat_room_model.dart';
import '../models/user_model.dart';
import '../models/message_model.dart';
import '../providers/auth_provider.dart';
import '../providers/message_provider.dart';
import '../utils/date_formatter.dart';
import '../theme/app_theme.dart';

class ChatRoomScreen extends StatefulWidget {
  final ChatRoomModel chatRoom;
  final UserModel peerUser;

  const ChatRoomScreen({
    Key? key,
    required this.chatRoom,
    required this.peerUser,
  }) : super(key: key);

  @override
  State<ChatRoomScreen> createState() => _ChatRoomScreenState();
}

class _ChatRoomScreenState extends State<ChatRoomScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _isSending = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<MessageProvider>(context, listen: false)
          .listenToMessages(widget.chatRoom.chatRoomId);
    });
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  void _handleSendMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty || _isSending) return;

    final currentUid =
        Provider.of<AuthProvider>(context, listen: false).currentUser?.uid;
    if (currentUid == null) return;

    _messageController.clear();
    setState(() {
      _isSending = true;
    });

    try {
      await Provider.of<MessageProvider>(context, listen: false).sendMessage(
        chatRoomId: widget.chatRoom.chatRoomId,
        senderId: currentUid,
        receiverId: widget.peerUser.uid,
        messageText: text,
      );
      _scrollToBottom();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to send message: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSending = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentUid =
        Provider.of<AuthProvider>(context).currentUser?.uid ?? '';
    final messageProvider = Provider.of<MessageProvider>(context);

    // Auto-scroll when messages update
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());

    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        title: Row(
          children: [
            CircleAvatar(
              radius: 18,
              backgroundColor: Colors.white24,
              child: Text(
                widget.peerUser.name.isNotEmpty
                    ? widget.peerUser.name[0].toUpperCase()
                    : '?',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.peerUser.name,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    widget.peerUser.email,
                    style: const TextStyle(fontSize: 12, color: Colors.white70),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      body: Container(
        color: const Color(0xFFE5DDD5), // Classic subtle chat background pattern tint
        child: Column(
          children: [
            // Messages List
            Expanded(
              child: messageProvider.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : messageProvider.messages.isEmpty
                      ? Center(
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.8),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              'No messages yet. Say hi to ${widget.peerUser.name}!',
                              style: const TextStyle(color: Colors.grey),
                            ),
                          ),
                        )
                      : ListView.builder(
                          controller: _scrollController,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 16,
                          ),
                          itemCount: messageProvider.messages.length,
                          itemBuilder: (context, index) {
                            final msg = messageProvider.messages[index];
                            final isMe = msg.senderId == currentUid;

                            return _buildMessageBubble(msg, isMe);
                          },
                        ),
            ),

            // Message Input Bar
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              color: Colors.white,
              child: SafeArea(
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _messageController,
                        textCapitalization: TextCapitalization.sentences,
                        maxLines: null,
                        decoration: InputDecoration(
                          hintText: 'Type a message...',
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 10,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(24),
                            borderSide: BorderSide.none,
                          ),
                          fillColor: Colors.grey.shade100,
                          filled: true,
                        ),
                        onSubmitted: (_) => _handleSendMessage(),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Material(
                      color: AppTheme.primaryAccent,
                      shape: const CircleBorder(),
                      elevation: 2,
                      child: IconButton(
                        icon: _isSending
                            ? const SizedBox(
                                height: 18,
                                width: 18,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : const Icon(Icons.send_rounded, color: Colors.white),
                        onPressed: _handleSendMessage,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageBubble(MessageModel msg, bool isMe) {
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: isMe
              ? AppTheme.sentBubbleColor
              : AppTheme.receivedBubbleColor,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: Radius.circular(isMe ? 16 : 4),
            bottomRight: Radius.circular(isMe ? 4 : 16),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 3,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment:
              isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            Text(
              msg.message,
              style: TextStyle(
                fontSize: 15,
                color: isMe
                    ? AppTheme.sentBubbleText
                    : AppTheme.receivedBubbleText,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              DateFormatter.formatMessageTime(msg.timestamp),
              style: TextStyle(
                fontSize: 10,
                color: isMe ? Colors.green.shade900 : Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
