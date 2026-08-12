import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../models/chat_room_model.dart';
import '../models/user_model.dart';
import '../models/message_model.dart';
import '../providers/auth_provider.dart';
import '../providers/message_provider.dart';
import '../providers/chat_provider.dart';
import '../theme/app_theme.dart';
import '../utils/date_formatter.dart';

class ChatRoomScreen extends StatefulWidget {
  final ChatRoomModel chatRoom;
  final UserModel peerUser;

  const ChatRoomScreen({
    super.key,
    required this.chatRoom,
    required this.peerUser,
  });

  @override
  State<ChatRoomScreen> createState() => _ChatRoomScreenState();
}

class _ChatRoomScreenState extends State<ChatRoomScreen> {
  final TextEditingController _messageController = TextEditingController();
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  bool _isSearching = false;
  String _searchQuery = '';
  MessageModel? _replyingToMessage;
  MessageModel? _editingMessage;
  bool _isRecordingVoice = false;
  Timer? _typingTimer;

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
    _searchController.dispose();
    _scrollController.dispose();
    _typingTimer?.cancel();
    super.dispose();
  }

  void _onTextChanged(String text) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final messageProvider = Provider.of<MessageProvider>(context, listen: false);
    if (authProvider.currentUser == null) return;

    messageProvider.updateTypingStatus(
      chatRoomId: widget.chatRoom.chatRoomId,
      uid: authProvider.currentUser!.uid,
      isTyping: text.isNotEmpty,
    );

    _typingTimer?.cancel();
    _typingTimer = Timer(const Duration(seconds: 3), () {
      if (mounted && authProvider.currentUser != null) {
        messageProvider.updateTypingStatus(
          chatRoomId: widget.chatRoom.chatRoomId,
          uid: authProvider.currentUser!.uid,
          isTyping: false,
        );
      }
    });
  }

  void _sendMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty && _editingMessage == null) return;

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final messageProvider = Provider.of<MessageProvider>(context, listen: false);
    if (authProvider.currentUser == null) return;

    if (_editingMessage != null) {
      // Edit existing message
      await messageProvider.editMessage(
        chatRoomId: widget.chatRoom.chatRoomId,
        messageId: _editingMessage!.messageId,
        newText: text,
      );
      setState(() {
        _editingMessage = null;
      });
      _messageController.clear();
      return;
    }

    _messageController.clear();

    await messageProvider.sendMessage(
      chatRoomId: widget.chatRoom.chatRoomId,
      senderId: authProvider.currentUser!.uid,
      receiverId: widget.peerUser.uid,
      messageText: text,
      replyToId: _replyingToMessage?.messageId,
      replyToText: _replyingToMessage?.message,
      type: 'text',
    );

    setState(() {
      _replyingToMessage = null;
    });

    _scrollToBottom();
  }

  void _sendDemoMedia(String type, String mediaUrl, String caption) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final messageProvider = Provider.of<MessageProvider>(context, listen: false);
    if (authProvider.currentUser == null) return;

    await messageProvider.sendMessage(
      chatRoomId: widget.chatRoom.chatRoomId,
      senderId: authProvider.currentUser!.uid,
      receiverId: widget.peerUser.uid,
      messageText: caption,
      type: type,
      mediaUrl: mediaUrl,
    );

    _scrollToBottom();
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent + 120,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutCubic,
      );
    }
  }

  void _showReactionSheet(MessageModel msg, String currentUid) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: AppTheme.surfaceColor.withValues(alpha: 0.95),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
          border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.5),
              blurRadius: 30,
              offset: const Offset(0, -8),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Emoji bar
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: ['❤️', '👍', '🔥', '😂', '🎉', '😮'].map((emoji) {
                final hasReacted = msg.reactions[currentUid] == emoji;
                return GestureDetector(
                  onTap: () {
                    Navigator.of(ctx).pop();
                    Provider.of<MessageProvider>(context, listen: false)
                        .toggleReaction(
                      chatRoomId: widget.chatRoom.chatRoomId,
                      messageId: msg.messageId,
                      uid: currentUid,
                      emoji: emoji,
                    );
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: hasReacted
                          ? AppTheme.primaryColor.withValues(alpha: 0.3)
                          : Colors.white.withValues(alpha: 0.05),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: hasReacted
                            ? AppTheme.primaryColor
                            : Colors.transparent,
                        width: 2,
                      ),
                    ),
                    child: Text(emoji, style: const TextStyle(fontSize: 26)),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 24),
            Divider(color: Colors.white.withValues(alpha: 0.08)),
            const SizedBox(height: 8),

            // Action options
            _buildSheetOption(
              icon: Icons.reply_rounded,
              color: AppTheme.neonCyan,
              title: 'Reply',
              onTap: () {
                Navigator.of(ctx).pop();
                setState(() {
                  _replyingToMessage = msg;
                });
              },
            ),
            _buildSheetOption(
              icon: Icons.copy_rounded,
              color: Colors.white,
              title: 'Copy Text',
              onTap: () {
                Navigator.of(ctx).pop();
                Clipboard.setData(ClipboardData(text: msg.message));
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Copied to clipboard',
                      style: GoogleFonts.plusJakartaSans(color: Colors.white),
                    ),
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                );
              },
            ),
            _buildSheetOption(
              icon: Icons.push_pin_rounded,
              color: const Color(0xFFF59E0B),
              title: 'Pin Message',
              onTap: () {
                Navigator.of(ctx).pop();
                Provider.of<MessageProvider>(context, listen: false).pinMessage(
                  chatRoomId: widget.chatRoom.chatRoomId,
                  messageId: msg.messageId,
                  messageText: msg.message,
                );
              },
            ),
            if (msg.senderId == currentUid) ...[
              _buildSheetOption(
                icon: Icons.edit_rounded,
                color: AppTheme.primaryColor,
                title: 'Edit Message',
                onTap: () {
                  Navigator.of(ctx).pop();
                  setState(() {
                    _editingMessage = msg;
                    _messageController.text = msg.message;
                  });
                },
              ),
              _buildSheetOption(
                icon: Icons.delete_outline_rounded,
                color: Colors.redAccent,
                title: 'Delete Message',
                onTap: () {
                  Navigator.of(ctx).pop();
                  Provider.of<MessageProvider>(context, listen: false)
                      .deleteMessage(
                    chatRoomId: widget.chatRoom.chatRoomId,
                    messageId: msg.messageId,
                  );
                },
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSheetOption({
    required IconData icon,
    required Color color,
    required String title,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: color, size: 22),
      title: Text(
        title,
        style: GoogleFonts.plusJakartaSans(
          color: Colors.white,
          fontWeight: FontWeight.w600,
          fontSize: 15,
        ),
      ),
      onTap: onTap,
    );
  }

  void _showMediaPicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: AppTheme.surfaceColor.withValues(alpha: 0.95),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
          border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Share Media',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildMediaTile(
                  icon: Icons.image_rounded,
                  color: AppTheme.neonCyan,
                  label: 'Photo',
                  onTap: () {
                    Navigator.of(ctx).pop();
                    _sendDemoMedia(
                      'image',
                      'https://images.unsplash.com/photo-1618005182384-a83a8bd57fbe?w=800',
                      'Check out this aesthetic UI wallpaper! 🎨',
                    );
                  },
                ),
                _buildMediaTile(
                  icon: Icons.mic_rounded,
                  color: const Color(0xFFEC4899),
                  label: 'Voice Note',
                  onTap: () {
                    Navigator.of(ctx).pop();
                    _sendDemoMedia(
                      'audio',
                      'audio_demo.mp3',
                      '🎙️ Voice message (0:14)',
                    );
                  },
                ),
                _buildMediaTile(
                  icon: Icons.insert_drive_file_rounded,
                  color: const Color(0xFFF59E0B),
                  label: 'Document',
                  onTap: () {
                    Navigator.of(ctx).pop();
                    _sendDemoMedia(
                      'text',
                      '',
                      '📄 Document_v1.0.pdf (2.4 MB)',
                    );
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildMediaTile({
    required IconData icon,
    required Color color,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              shape: BoxShape.circle,
              border: Border.all(color: color.withValues(alpha: 0.5)),
            ),
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: GoogleFonts.plusJakartaSans(
              color: Colors.white,
              fontWeight: FontWeight.w600,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final messageProvider = Provider.of<MessageProvider>(context);
    final chatProvider = Provider.of<ChatProvider>(context);
    final currentUid = authProvider.currentUser?.uid ?? '';

    // Find current room in chatProvider for live typing & pinned message updates
    ChatRoomModel activeRoom = widget.chatRoom;
    try {
      activeRoom = chatProvider.chats.firstWhere(
        (r) => r.chatRoomId == widget.chatRoom.chatRoomId,
        orElse: () => widget.chatRoom,
      );
    } catch (_) {}

    final bool isPeerTyping = activeRoom.isTyping[widget.peerUser.uid] == true;

    // Filter messages if search active
    final rawMessages = messageProvider.messages;
    final filteredMessages = _searchQuery.isEmpty
        ? rawMessages
        : rawMessages
            .where((m) =>
                m.message.toLowerCase().contains(_searchQuery.toLowerCase()))
            .toList();

    return Scaffold(
      backgroundColor: AppTheme.darkBackground,
      appBar: AppBar(
        backgroundColor: AppTheme.surfaceColor.withValues(alpha: 0.95),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: _isSearching
            ? TextField(
                controller: _searchController,
                autofocus: true,
                style: GoogleFonts.plusJakartaSans(color: Colors.white),
                onChanged: (val) {
                  setState(() {
                    _searchQuery = val;
                  });
                },
                decoration: InputDecoration(
                  hintText: 'Search in conversation...',
                  hintStyle: GoogleFonts.plusJakartaSans(
                    color: AppTheme.textSecondary,
                    fontSize: 14,
                  ),
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  fillColor: Colors.transparent,
                ),
              )
            : Row(
                children: [
                  Stack(
                    children: [
                      Container(
                        width: 42,
                        height: 42,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: AppTheme.avatarGradient,
                        ),
                        child: Center(
                          child: Text(
                            widget.peerUser.name.isNotEmpty
                                ? widget.peerUser.name[0].toUpperCase()
                                : 'P',
                            style: GoogleFonts.plusJakartaSans(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        right: 0,
                        bottom: 0,
                        child: Container(
                          width: 12,
                          height: 12,
                          decoration: BoxDecoration(
                            color: AppTheme.onlineEmerald,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: AppTheme.surfaceColor,
                              width: 2,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.peerUser.name,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        isPeerTyping ? 'typing...' : 'Active Now',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: isPeerTyping
                              ? AppTheme.neonCyan
                              : AppTheme.onlineEmerald,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
        actions: [
          IconButton(
            icon: Icon(
              _isSearching ? Icons.close_rounded : Icons.search_rounded,
              color: AppTheme.neonCyan,
            ),
            onPressed: () {
              setState(() {
                _isSearching = !_isSearching;
                if (!_isSearching) {
                  _searchController.clear();
                  _searchQuery = '';
                }
              });
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Pinned Message Banner
          if (activeRoom.pinnedMessageText != null &&
              activeRoom.pinnedMessageText!.isNotEmpty)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: const Color(0xFFF59E0B).withValues(alpha: 0.15),
                border: const Border(
                  bottom: BorderSide(color: Color(0x33F59E0B)),
                ),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.push_pin_rounded,
                    color: Color(0xFFF59E0B),
                    size: 18,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Pinned Message',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFFF59E0B),
                          ),
                        ),
                        Text(
                          activeRoom.pinnedMessageText!,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 13,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded,
                        size: 16, color: AppTheme.textSecondary),
                    onPressed: () {
                      messageProvider.unpinMessage(
                        chatRoomId: widget.chatRoom.chatRoomId,
                      );
                    },
                  ),
                ],
              ),
            ),

          // Messages ListView
          Expanded(
            child: messageProvider.isLoading
                ? const Center(
                    child: CircularProgressIndicator(
                      color: AppTheme.primaryColor,
                    ),
                  )
                : filteredMessages.isEmpty
                    ? Center(
                        child: Text(
                          _searchQuery.isNotEmpty
                              ? 'No messages matching "$_searchQuery"'
                              : 'Say Hello to ${widget.peerUser.name}!',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 15,
                            color: AppTheme.textSecondary,
                          ),
                        ),
                      )
                    : ListView.builder(
                        controller: _scrollController,
                        physics: const BouncingScrollPhysics(
                          parent: AlwaysScrollableScrollPhysics(),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 16,
                        ),
                        itemCount: filteredMessages.length,
                        itemBuilder: (context, index) {
                          final msg = filteredMessages[index];
                          final isMe = msg.senderId == currentUid;

                          return _buildMessageItem(msg, isMe, currentUid);
                        },
                      ),
          ),

          // Reply / Edit Banner Preview
          if (_replyingToMessage != null || _editingMessage != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: AppTheme.surfaceColor,
                border: const Border(
                  top: BorderSide(color: AppTheme.surfaceBorder),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    _editingMessage != null
                        ? Icons.edit_rounded
                        : Icons.reply_rounded,
                    color: AppTheme.neonCyan,
                    size: 20,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _editingMessage != null
                            ? 'Editing Message'
                            : 'Replying to ${_replyingToMessage!.senderId == currentUid ? "yourself" : widget.peerUser.name}',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.neonCyan,
                          ),
                        ),
                        Text(
                          _editingMessage != null
                              ? _editingMessage!.message
                              : _replyingToMessage!.message,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 13,
                            color: AppTheme.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded,
                        color: AppTheme.textSecondary, size: 18),
                    onPressed: () {
                      setState(() {
                        _replyingToMessage = null;
                        _editingMessage = null;
                        _messageController.clear();
                      });
                    },
                  ),
                ],
              ),
            ),

          // Cyber Message Input Bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: AppTheme.surfaceColor.withValues(alpha: 0.95),
              border: const Border(
                top: BorderSide(color: AppTheme.surfaceBorder),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.3),
                  blurRadius: 20,
                  offset: const Offset(0, -4),
                ),
              ],
            ),
            child: SafeArea(
              child: Row(
                children: [
                  // Attachment Icon
                  Container(
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      icon: const Icon(
                        Icons.add_rounded,
                        color: AppTheme.neonCyan,
                        size: 26,
                      ),
                      onPressed: _showMediaPicker,
                    ),
                  ),
                  const SizedBox(width: 10),

                  // Message Input Field
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFF1E293B).withValues(alpha: 0.8),
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.08),
                        ),
                      ),
                      child: TextField(
                        controller: _messageController,
                        style: GoogleFonts.plusJakartaSans(
                          color: Colors.white,
                          fontSize: 15,
                        ),
                        maxLines: 4,
                        minLines: 1,
                        onChanged: _onTextChanged,
                        textInputAction: TextInputAction.send,
                        onSubmitted: (_) => _sendMessage(),
                        decoration: InputDecoration(
                          hintText: _editingMessage != null
                              ? 'Edit message...'
                              : 'Type a message...',
                          hintStyle: GoogleFonts.plusJakartaSans(
                            color: AppTheme.textSecondary,
                            fontSize: 14,
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 14,
                          ),
                          border: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          focusedBorder: InputBorder.none,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),

                  // Send Button
                  GestureDetector(
                    onTap: _sendMessage,
                    child: Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        gradient: AppTheme.primaryGradient,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.primaryColor.withValues(alpha: 0.5),
                            blurRadius: 16,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Icon(
                          _editingMessage != null
                              ? Icons.check_rounded
                              : Icons.send_rounded,
                          color: Colors.white,
                          size: 22,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageItem(MessageModel msg, bool isMe, String currentUid) {
    return GestureDetector(
      onLongPress: () => _showReactionSheet(msg, currentUid),
      child: Padding(
        padding: const EdgeInsets.only(bottom: 14),
        child: Column(
          crossAxisAlignment:
              isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            // Quoted reply banner if applicable
            if (msg.replyToText != null && msg.replyToText!.isNotEmpty)
              Container(
                margin: const EdgeInsets.only(bottom: 4),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(12),
                  border: const Border(
                    left: BorderSide(color: AppTheme.neonCyan, width: 3),
                  ),
                ),
                child: Text(
                  msg.replyToText!,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12,
                    color: AppTheme.textSecondary,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),

            // Main Message Bubble
            Container(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.75,
              ),
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
              decoration: BoxDecoration(
                gradient: isMe ? AppTheme.sentBubbleGradient : null,
                color: isMe ? null : AppTheme.surfaceColor.withValues(alpha: 0.9),
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(22),
                  topRight: const Radius.circular(22),
                  bottomLeft: isMe
                      ? const Radius.circular(22)
                      : const Radius.circular(4),
                  bottomRight: isMe
                      ? const Radius.circular(4)
                      : const Radius.circular(22),
                ),
                border: isMe
                    ? null
                    : Border.all(
                        color: Colors.white.withValues(alpha: 0.08),
                      ),
                boxShadow: [
                  BoxShadow(
                    color: isMe
                        ? AppTheme.primaryColor.withValues(alpha: 0.25)
                        : Colors.black.withValues(alpha: 0.2),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Rich media attachment image preview
                  if (msg.type == 'image' && msg.mediaUrl != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(14),
                        child: Image.network(
                          msg.mediaUrl!,
                          fit: BoxFit.cover,
                          errorBuilder: (ctx, _, __) => Container(
                            height: 150,
                            color: Colors.white10,
                            child: const Icon(Icons.broken_image,
                                color: Colors.white30),
                          ),
                        ),
                      ),
                    ),

                  Text(
                    msg.message,
                    style: GoogleFonts.plusJakartaSans(
                      color: Colors.white,
                      fontSize: 15,
                      height: 1.4,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),

            // Emoji Reaction Pills
            if (msg.reactions.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Wrap(
                  spacing: 4,
                  children: msg.reactions.values.toSet().map((emoji) {
                    final count = msg.reactions.values
                        .where((e) => e == emoji)
                        .length;
                    return Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppTheme.surfaceColor,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.12),
                        ),
                      ),
                      child: Text(
                        '$emoji $count',
                        style: const TextStyle(fontSize: 11, color: Colors.white),
                      ),
                    );
                  }).toList(),
                ),
              ),

            const SizedBox(height: 4),

            // Timestamp + Edited Indicator
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (msg.isEdited) ...[
                    Text(
                      'edited • ',
                      style: GoogleFonts.plusJakartaSans(
                        color: AppTheme.textSecondary,
                        fontSize: 11,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                  Text(
                    DateFormatter.formatTimestamp(msg.timestamp),
                    style: GoogleFonts.plusJakartaSans(
                      color: AppTheme.textSecondary,
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  if (isMe) ...[
                    const SizedBox(width: 4),
                    const Icon(
                      Icons.done_all_rounded,
                      size: 14,
                      color: AppTheme.neonCyan,
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
