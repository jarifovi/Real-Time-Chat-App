import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/chat_provider.dart';
import '../../providers/user_provider.dart';
import '../../models/chat_room_model.dart';
import '../../models/user_model.dart';
import '../../theme/app_theme.dart';
import '../../widgets/gravity_3d_card.dart';
import '../../widgets/panda_avatar_widget.dart';
import '../../utils/date_formatter.dart';
import '../chat_room_screen.dart';

class ChatsTab extends StatefulWidget {
  const ChatsTab({super.key});

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
        username: 'user_${peerUid.substring(0, 4)}',
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
      backgroundColor: AppTheme.darkBackground,
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                gradient: AppTheme.primaryGradient,
                shape: BoxShape.circle,
                boxShadow: AppTheme.glowingOrbShadows,
              ),
              child: const Icon(
                Icons.pets_rounded,
                size: 20,
                color: Colors.white,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              'BAO CHAT',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 24,
                fontWeight: FontWeight.w900,
                color: Colors.white,
                letterSpacing: -0.8,
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: AppTheme.primaryColor.withValues(alpha: 0.5),
                ),
              ),
              child: Text(
                'LIVE',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  color: AppTheme.primaryColor,
                  letterSpacing: 1.0,
                ),
              ),
            ),
          ],
        ),
        elevation: 0,
        backgroundColor: AppTheme.darkBackground,
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
                          color: AppTheme.primaryColor.withValues(alpha: 0.15),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.forum_outlined,
                          size: 56,
                          color: AppTheme.neonCyan,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No active conversations yet',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Go to Users tab to start a new chat',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 14,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  physics: const UltraSmoothGravityScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  itemCount: chatProvider.chats.length,
                  itemBuilder: (context, index) {
                    final chatRoom = chatProvider.chats[index];
                    final peerUser = _getPeerUser(
                      chatRoom,
                      currentUid,
                      userProvider.users,
                    );

                    return Gravity3DCard(
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
                      padding: const EdgeInsets.symmetric(
                        horizontal: 18,
                        vertical: 10,
                      ),
                      child: Row(
                        children: [
                          PandaAvatarWidget(
                            name: peerUser?.name ?? 'Chat',
                            photoUrl: peerUser?.photoUrl,
                            size: 54,
                            showOnlineBadge: true,
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  peerUser?.name ?? 'Chat',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontWeight: FontWeight.w800,
                                    fontSize: 16,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  chatRoom.lastMessage.isNotEmpty
                                      ? chatRoom.lastMessage
                                      : 'Tap to send a message...',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: GoogleFonts.plusJakartaSans(
                                    color: chatRoom.lastMessage.isNotEmpty
                                        ? AppTheme.textSecondary
                                        : AppTheme.neonCyan,
                                    fontSize: 14,
                                    fontWeight: chatRoom.lastMessage.isNotEmpty
                                        ? FontWeight.w400
                                        : FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                DateFormatter.formatTimestamp(chatRoom.lastMessageAt),
                                style: GoogleFonts.plusJakartaSans(
                                  color: AppTheme.textSecondary,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Container(
                                width: 8,
                                height: 8,
                                decoration: const BoxDecoration(
                                  color: AppTheme.primaryColor,
                                  shape: BoxShape.circle,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                ),
    );
  }
}
