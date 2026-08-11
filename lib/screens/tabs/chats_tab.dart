import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/chat_provider.dart';
import '../../providers/user_provider.dart';
import '../../models/chat_room_model.dart';
import '../../models/user_model.dart';
import '../../theme/app_theme.dart';
import '../../utils/date_formatter.dart';
import '../chat_room_screen.dart';

class ChatsTab extends StatefulWidget {
  const ChatsTab({Key? key}) : super(key: key);

  @override
  State<ChatsTab> createState() => _ChatsTabState();
}

class _ChatsTabState extends State<ChatsTab> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      if (authProvider.currentUser != null) {
        Provider.of<ChatProvider>(context, listen: false)
            .listenToUserChats(authProvider.currentUser!.uid);
        Provider.of<UserProvider>(context, listen: false)
            .listenToUsers(authProvider.currentUser!.uid);
      }
    });
  }

  UserModel? _getPeerUser(ChatRoomModel room, String currentUid, List<UserModel> users) {
    String peerUid = room.participants.firstWhere(
      (uid) => uid != currentUid,
      orElse: () => '',
    );
    if (peerUid.isEmpty) return null;

    try {
      return users.firstWhere((u) => u.uid == peerUid);
    } catch (_) {
      return UserModel(
        uid: peerUid,
        name: 'User (${peerUid.substring(0, 4)})',
        email: '',
        createdAt: DateTime.now(),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final chatProvider = Provider.of<ChatProvider>(context);
    final userProvider = Provider.of<UserProvider>(context);

    final currentUid = authProvider.currentUser?.uid ?? '';

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text(
          'Messages',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            letterSpacing: -0.5,
          ),
        ),
        elevation: 0,
        backgroundColor: AppTheme.backgroundColor,
      ),
      body: chatProvider.isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppTheme.primaryColor))
          : chatProvider.chats.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryColor.withValues(alpha: 0.08),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.forum_outlined,
                          size: 56,
                          color: AppTheme.primaryColor,
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'No active conversations yet',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        'Go to Users tab to start a new chat',
                        style: TextStyle(
                          fontSize: 14,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  physics: const BouncingScrollPhysics(
                    parent: AlwaysScrollableScrollPhysics(),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  itemCount: chatProvider.chats.length,
                  itemBuilder: (context, index) {
                    final chatRoom = chatProvider.chats[index];
                    final peerUser = _getPeerUser(
                      chatRoom,
                      currentUid,
                      userProvider.users,
                    );

                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.03),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        leading: Stack(
                          children: [
                            Container(
                              width: 54,
                              height: 54,
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: AppTheme.primaryGradient,
                              ),
                              child: Center(
                                child: Text(
                                  peerUser != null && peerUser.name.isNotEmpty
                                      ? peerUser.name[0].toUpperCase()
                                      : 'C',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                            Positioned(
                              right: 0,
                              bottom: 0,
                              child: Container(
                                width: 14,
                                height: 14,
                                decoration: BoxDecoration(
                                  color: AppTheme.secondaryColor,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: Colors.white,
                                    width: 2.5,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        title: Text(
                          peerUser?.name ?? 'Chat',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                        subtitle: Text(
                          chatRoom.lastMessage.isNotEmpty
                              ? chatRoom.lastMessage
                              : 'Tap to send a message...',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: chatRoom.lastMessage.isNotEmpty
                                ? AppTheme.textSecondary
                                : AppTheme.primaryColor,
                            fontSize: 14,
                            fontWeight: chatRoom.lastMessage.isNotEmpty
                                ? FontWeight.normal
                                : FontWeight.w500,
                          ),
                        ),
                        trailing: Text(
                          DateFormatter.formatTimestamp(chatRoom.lastMessageAt),
                          style: const TextStyle(
                            color: Color(0xFF94A3B8),
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        onTap: () {
                          if (peerUser != null) {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => ChatRoomScreen(
                                  chatRoom: chatRoom,
                                  peerUser: peerUser,
                                ),
                              ),
                            );
                          }
                        },
                      ),
                    );
                  },
                ),
    );
  }
}
