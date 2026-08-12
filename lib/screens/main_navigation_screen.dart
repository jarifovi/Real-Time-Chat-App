import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';
import 'tabs/users_tab.dart';
import 'tabs/chats_tab.dart';
import 'tabs/profile_tab.dart';

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _currentIndex = 1; // Default tab: Chats

  final List<Widget> _tabs = const [
    UsersTab(),
    ChatsTab(),
    ProfileTab(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.darkBackground,
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        switchInCurve: Curves.easeOutCubic,
        switchOutCurve: Curves.easeInCubic,
        child: _tabs[_currentIndex],
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.only(left: 20, right: 20, bottom: 18, top: 4),
        color: Colors.transparent,
        child: SafeArea(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: AppTheme.surfaceColor.withValues(alpha: 0.9),
              borderRadius: BorderRadius.circular(32),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.12),
                width: 1.2,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.5),
                  blurRadius: 28,
                  offset: const Offset(0, 8),
                ),
                BoxShadow(
                  color: AppTheme.primaryColor.withValues(alpha: 0.25),
                  blurRadius: 20,
                  spreadRadius: 1,
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildNavItem(
                  index: 0,
                  icon: Icons.people_outline_rounded,
                  activeIcon: Icons.people_rounded,
                  label: 'Users',
                ),
                _buildNavItem(
                  index: 1,
                  icon: Icons.chat_bubble_outline_rounded,
                  activeIcon: Icons.chat_bubble_rounded,
                  label: 'Chats',
                ),
                _buildNavItem(
                  index: 2,
                  icon: Icons.person_outline_rounded,
                  activeIcon: Icons.person_rounded,
                  label: 'Profile',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required int index,
    required IconData icon,
    required IconData activeIcon,
    required String label,
  }) {
    final isSelected = _currentIndex == index;

    return GestureDetector(
      onTap: () {
        setState(() {
          _currentIndex = index;
        });
      },
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected
              ? AppTheme.primaryColor.withValues(alpha: 0.2)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(24),
          border: isSelected
              ? Border.all(
                  color: AppTheme.primaryColor.withValues(alpha: 0.6),
                  width: 1.2,
                )
              : null,
        ),
        child: Row(
          children: [
            Icon(
              isSelected ? activeIcon : icon,
              color: isSelected ? AppTheme.primaryColor : AppTheme.textSecondary,
              size: 22,
            ),
            if (isSelected) ...[
              const SizedBox(width: 8),
              Text(
                label,
                style: GoogleFonts.plusJakartaSans(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                  fontSize: 14,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
