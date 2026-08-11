import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/chat_room_model.dart';
import '../../models/user_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/chat_provider.dart';
import '../../services/auth_service.dart';
import '../../utils/date_formatter.dart';
import '../chat_room_screen.dart';

class ChatsTab extends StatefulWidget {
  const ChatsTab({Key? key}) : super(key: key);

  @override
  State<ChatsTab> createState() => _ChatsTabState();
}

class _ChatsTabState extends State<ChatsTab> {
  final AuthService _authService = AuthService();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final currentUid =
          Provider.of<AuthProvider>(context, listen: false).currentUser?.uid;
      if (currentUid != null) {
        Provider.of<ChatProvider>(context, listen: false)
            .listenToUserChats(currentUid);
      }
    });
  }

  Future<UserModel?> _getPeerUser(
      List<String> participants, String currentUid) async {
    String peerUid = participants.firstWhere(
      (id) => id != currentUid,
      orElse: () => currentUid,
    );
    return await _authService.getUserProfile(peerUid);
  }

  void _openChatRoom(ChatRoomModel room, UserModel peerUser) {
    Provider.of<ChatProvider>(context, listen: false).setActiveRoom(room);
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ChatRoomScreen(
          chatRoom: room,
          peerUser: peerUser,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final chatProvider = Provider.of<ChatProvider>(context);
    final currentUid = authProvider.currentUser?.uid;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Chats'),
      ),
      body: chatProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : chatProvider.chats.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Icon(Icons.chat_outlined, size: 64, color: Colors.grey),
                      SizedBox(height: 12),
                      Text(
                        'No active conversations yet',
                        style: TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Go to Users tab to start a conversation',
                        style: TextStyle(fontSize: 13, color: Colors.grey),
                      ),
                    ],
                  ),
                )
              : ListView.separated(
                  itemCount: chatProvider.chats.length,
                  separatorBuilder: (context, index) =>
                      const Divider(height: 1, indent: 72),
                  itemBuilder: (context, index) {
                    final room = chatProvider.chats[index];

                    if (currentUid == null) return const SizedBox.shrink();

                    return FutureBuilder<UserModel?>(
                      future: _getPeerUser(room.participants, currentUid),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const ListTile(
                            leading: CircleAvatar(
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                            title: Text('Loading...'),
                          );
                        }

                        final peerUser = snapshot.data;
                        final peerName = peerUser?.name ?? 'Unknown User';
                        final formattedTime =
                            DateFormatter.formatTimestamp(room.lastMessageAt);

                        return ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          leading: CircleAvatar(
                            radius: 26,
                            backgroundColor: const Color(0xFF075E54),
                            child: Text(
                              peerName.isNotEmpty
                                  ? peerName[0].toUpperCase()
                                  : '?',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 20,
                              ),
                            ),
                          ),
                          title: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  peerName,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              if (formattedTime.isNotEmpty)
                                Text(
                                  formattedTime,
                                  style: const TextStyle(
                                    color: Color(0xFF128C7E),
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                            ],
                          ),
                          subtitle: Padding(
                            padding: const EdgeInsets.only(top: 4.0),
                            child: Text(
                              room.lastMessage.isNotEmpty
                                  ? room.lastMessage
                                  : 'Tap to send a message...',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: room.lastMessage.isNotEmpty
                                    ? const Color(0xFF65676B)
                                    : Colors.grey.shade400,
                                fontSize: 14,
                              ),
                            ),
                          ),
                          onTap: peerUser != null
                              ? () => _openChatRoom(room, peerUser)
                              : null,
                        );
                      },
                    );
                  },
                ),
    );
  }
}
