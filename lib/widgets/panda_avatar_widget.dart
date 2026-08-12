import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';

class PandaAvatarWidget extends StatelessWidget {
  final String name;
  final String? photoUrl;
  final double size;
  final bool showOnlineBadge;
  final bool isOnline;

  const PandaAvatarWidget({
    super.key,
    required this.name,
    this.photoUrl,
    this.size = 54,
    this.showOnlineBadge = true,
    this.isOnline = true,
  });

  // Preset Panda Avatars List
  static const List<Map<String, String>> pandaPresets = [
    {
      'id': 'panpan_classic',
      'label': 'PanPan Classic 🐾',
      'url': 'https://images.unsplash.com/photo-1564349683136-77e08dba1ef9?auto=format&fit=crop&w=200&q=80',
    },
    {
      'id': 'tech_wiz',
      'label': 'Tech Wiz Panda 💻',
      'url': 'https://images.unsplash.com/photo-1527118732049-c88155f2107c?auto=format&fit=crop&w=200&q=80',
    },
    {
      'id': 'bamboo_chef',
      'label': 'Bao Chef Panda 🥟',
      'url': 'https://images.unsplash.com/photo-1546182990-dffeafbe841d?auto=format&fit=crop&w=200&q=80',
    },
    {
      'id': 'social_butterfly',
      'label': 'Social Butterfly 💬',
      'url': 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?auto=format&fit=crop&w=200&q=80',
    },
    {
      'id': 'global_explorer',
      'label': 'Global Explorer 🌍',
      'url': 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?auto=format&fit=crop&w=200&q=80',
    },
  ];

  @override
  Widget build(BuildContext context) {
    final bool hasValidPhoto = photoUrl != null && photoUrl!.trim().isNotEmpty;

    return Stack(
      children: [
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: AppTheme.avatarGradient,
            boxShadow: [
              BoxShadow(
                color: AppTheme.primaryColor.withValues(alpha: 0.35),
                blurRadius: 14,
                spreadRadius: 2,
              ),
            ],
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.3),
              width: size > 70 ? 2.5 : 1.5,
            ),
          ),
          child: ClipOval(
            child: hasValidPhoto
                ? Image.network(
                    photoUrl!,
                    width: size,
                    height: size,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => _buildFallback(),
                  )
                : _buildFallback(),
          ),
        ),
        if (showOnlineBadge)
          Positioned(
            right: 0,
            bottom: 0,
            child: Container(
              width: size * 0.28,
              height: size * 0.28,
              decoration: BoxDecoration(
                color: isOnline ? AppTheme.onlineEmerald : Colors.grey,
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppTheme.darkBackground,
                  width: 2.2,
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildFallback() {
    String initial = name.trim().isNotEmpty ? name.trim()[0].toUpperCase() : 'B';
    return Container(
      decoration: const BoxDecoration(
        gradient: AppTheme.primaryGradient,
      ),
      child: Center(
        child: Stack(
          alignment: Alignment.center,
          children: [
            Text(
              initial,
              style: GoogleFonts.plusJakartaSans(
                color: Colors.white,
                fontSize: size * 0.42,
                fontWeight: FontWeight.w900,
              ),
            ),
            Positioned(
              right: 2,
              bottom: 2,
              child: Icon(
                Icons.pets_rounded,
                size: size * 0.32,
                color: Colors.white.withValues(alpha: 0.35),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
