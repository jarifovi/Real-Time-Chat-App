import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../theme/app_theme.dart';
import '../../utils/date_formatter.dart';
import '../../widgets/gravity_3d_card.dart';
import '../../widgets/panda_avatar_widget.dart';

class ProfileTab extends StatefulWidget {
  const ProfileTab({super.key});

  @override
  State<ProfileTab> createState() => _ProfileTabState();
}

class _ProfileTabState extends State<ProfileTab> {
  bool _notificationsEnabled = true;
  bool _biometricEnabled = true;
  String _disappearingTimer = 'Off';

  void _showEditProfileDialog(BuildContext context, AuthProvider authProvider) {
    final currentUser = authProvider.currentUser;
    if (currentUser == null) return;

    final nameController = TextEditingController(text: currentUser.name);
    final usernameController = TextEditingController(text: currentUser.username);
    final photoUrlController = TextEditingController(text: currentUser.photoUrl ?? '');
    String selectedPresetUrl = currentUser.photoUrl ?? PandaAvatarWidget.pandaPresets[0]['url']!;
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          backgroundColor: AppTheme.surfaceColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28),
            side: BorderSide(color: AppTheme.primaryColor.withValues(alpha: 0.3)),
          ),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.edit_rounded,
                  color: AppTheme.primaryColor,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Edit Profile',
                style: GoogleFonts.plusJakartaSans(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                  fontSize: 20,
                ),
              ),
            ],
          ),
          content: Form(
            key: formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 8),

                  // Avatar Picker Title
                  Text(
                    'Choose Panda Avatar 🐾',
                    style: GoogleFonts.plusJakartaSans(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 10),

                  // Preset Avatars Selector Row
                  SizedBox(
                    height: 60,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: PandaAvatarWidget.pandaPresets.length,
                      itemBuilder: (context, index) {
                        final preset = PandaAvatarWidget.pandaPresets[index];
                        final isSelected = selectedPresetUrl == preset['url'];

                        return GestureDetector(
                          onTap: () {
                            setDialogState(() {
                              selectedPresetUrl = preset['url']!;
                              photoUrlController.clear();
                            });
                          },
                          child: Container(
                            margin: const EdgeInsets.only(right: 10),
                            padding: const EdgeInsets.all(2),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: isSelected
                                    ? AppTheme.primaryColor
                                    : Colors.white.withValues(alpha: 0.15),
                                width: isSelected ? 3 : 1,
                              ),
                            ),
                            child: PandaAvatarWidget(
                              name: 'Panda',
                              photoUrl: preset['url'],
                              size: 50,
                              showOnlineBadge: isSelected,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 14),

                  // Custom Photo URL Input
                  TextFormField(
                    controller: photoUrlController,
                    style: GoogleFonts.plusJakartaSans(color: Colors.white),
                    decoration: InputDecoration(
                      labelText: 'Custom Photo URL (Optional)',
                      hintText: 'https://...',
                      hintStyle: GoogleFonts.plusJakartaSans(
                        color: AppTheme.textSecondary.withValues(alpha: 0.5),
                        fontSize: 13,
                      ),
                      labelStyle: GoogleFonts.plusJakartaSans(color: AppTheme.textSecondary),
                      prefixIcon: const Icon(Icons.link_rounded, color: AppTheme.primaryColor),
                    ),
                    onChanged: (val) {
                      setDialogState(() {
                        if (val.trim().isNotEmpty) {
                          selectedPresetUrl = val.trim();
                        }
                      });
                    },
                  ),
                  const SizedBox(height: 14),

                  // Display Name
                  TextFormField(
                    controller: nameController,
                    style: GoogleFonts.plusJakartaSans(color: Colors.white),
                    decoration: InputDecoration(
                      labelText: 'Display Name',
                      labelStyle: GoogleFonts.plusJakartaSans(color: AppTheme.textSecondary),
                      prefixIcon: const Icon(Icons.badge_rounded, color: AppTheme.primaryColor),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter a name';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 14),

                  // Username (@handle)
                  TextFormField(
                    controller: usernameController,
                    style: GoogleFonts.plusJakartaSans(color: Colors.white),
                    decoration: InputDecoration(
                      labelText: 'Username (@handle)',
                      labelStyle: GoogleFonts.plusJakartaSans(color: AppTheme.textSecondary),
                      prefixIcon: const Icon(Icons.alternate_email_rounded, color: AppTheme.primaryAccent),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter a username';
                      }
                      if (value.trim().length < 3) {
                        return 'Username must be at least 3 characters';
                      }
                      return null;
                    },
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: Text(
                'Cancel',
                style: GoogleFonts.plusJakartaSans(color: AppTheme.textSecondary),
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                if (!formKey.currentState!.validate()) return;
                final messenger = ScaffoldMessenger.of(context);
                Navigator.of(ctx).pop();

                final finalPhotoUrl = photoUrlController.text.trim().isNotEmpty
                    ? photoUrlController.text.trim()
                    : selectedPresetUrl;

                bool success = await authProvider.updateProfile(
                  newName: nameController.text.trim(),
                  newUsername: usernameController.text.trim(),
                  newPhotoUrl: finalPhotoUrl,
                );

                if (mounted) {
                  messenger.showSnackBar(
                    SnackBar(
                      content: Text(
                        success ? 'Profile updated successfully!' : 'Failed to update profile.',
                        style: GoogleFonts.plusJakartaSans(color: Colors.white),
                      ),
                      backgroundColor: success ? AppTheme.primaryColor : Colors.redAccent,
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryColor,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              child: Text(
                'Save Changes',
                style: GoogleFonts.plusJakartaSans(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.currentUser;

    return Scaffold(
      backgroundColor: AppTheme.darkBackground,
      appBar: AppBar(
        title: Text(
          'My Profile',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 26,
            fontWeight: FontWeight.w800,
            color: Colors.white,
            letterSpacing: -0.8,
          ),
        ),
        elevation: 0,
        backgroundColor: AppTheme.darkBackground,
      ),
      body: SingleChildScrollView(
        physics: const UltraSmoothGravityScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        child: Column(
          children: [
            const SizedBox(height: 8),

            // Profile Header 3D Gravity Card
            Gravity3DCard(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  PandaAvatarWidget(
                    name: user?.name ?? 'User',
                    photoUrl: user?.photoUrl,
                    size: 96,
                    showOnlineBadge: true,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    user?.name ?? 'User Name',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 24,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    user?.formattedUsername ?? '@username',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.primaryColor,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    user?.email ?? 'email@domain.com',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 13,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 18),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton.icon(
                        onPressed: () => _showEditProfileDialog(context, authProvider),
                        icon: const Icon(Icons.edit_rounded, size: 18, color: Colors.white),
                        label: Text(
                          'Edit Profile',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primaryColor,
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryColor.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: AppTheme.primaryColor.withValues(alpha: 0.4),
                          ),
                        ),
                        child: Text(
                          'Member since ${DateFormatter.formatTimestamp(user?.createdAt)}',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.primaryColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Settings & Security Container
            Container(
              decoration: BoxDecoration(
                color: AppTheme.surfaceColor.withValues(alpha: 0.65),
                borderRadius: BorderRadius.circular(28),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.08),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Column(
                children: [
                  _buildProfileTile(
                    icon: Icons.person_outline_rounded,
                    iconColor: AppTheme.primaryColor,
                    title: 'Edit Account Details',
                    subtitle: 'Change display name, @username & avatar',
                    onTap: () => _showEditProfileDialog(context, authProvider),
                  ),
                  Divider(
                    height: 1,
                    indent: 64,
                    endIndent: 20,
                    color: Colors.white.withValues(alpha: 0.08),
                  ),
                  _buildProfileTile(
                    icon: Icons.notifications_active_outlined,
                    iconColor: AppTheme.neonPinkGlow,
                    title: 'Push Notifications',
                    subtitle: 'Real-time FCM message alerts',
                    trailing: Switch(
                      value: _notificationsEnabled,
                      activeThumbColor: AppTheme.primaryColor,
                      onChanged: (val) {
                        setState(() {
                          _notificationsEnabled = val;
                        });
                      },
                    ),
                  ),
                  Divider(
                    height: 1,
                    indent: 64,
                    endIndent: 20,
                    color: Colors.white.withValues(alpha: 0.08),
                  ),
                  _buildProfileTile(
                    icon: Icons.fingerprint_rounded,
                    iconColor: AppTheme.onlineEmerald,
                    title: 'Biometric App Lock',
                    subtitle: 'Fingerprint / Face ID security',
                    trailing: Switch(
                      value: _biometricEnabled,
                      activeThumbColor: AppTheme.primaryColor,
                      onChanged: (val) {
                        setState(() {
                          _biometricEnabled = val;
                        });
                      },
                    ),
                  ),
                  Divider(
                    height: 1,
                    indent: 64,
                    endIndent: 20,
                    color: Colors.white.withValues(alpha: 0.08),
                  ),
                  _buildProfileTile(
                    icon: Icons.timer_outlined,
                    iconColor: const Color(0xFFF59E0B),
                    title: 'Disappearing Messages',
                    subtitle: 'Auto-delete after expiry',
                    trailing: DropdownButton<String>(
                      value: _disappearingTimer,
                      dropdownColor: AppTheme.surfaceColor,
                      underline: const SizedBox(),
                      style: GoogleFonts.plusJakartaSans(
                        color: AppTheme.primaryColor,
                        fontWeight: FontWeight.w700,
                      ),
                      items: ['Off', '1 Min', '1 Hour', '24 Hours']
                          .map((val) => DropdownMenuItem(
                                value: val,
                                child: Text(val),
                              ))
                          .toList(),
                      onChanged: (newVal) {
                        if (newVal != null) {
                          setState(() {
                            _disappearingTimer = newVal;
                          });
                        }
                      },
                    ),
                  ),
                  Divider(
                    height: 1,
                    indent: 64,
                    endIndent: 20,
                    color: Colors.white.withValues(alpha: 0.08),
                  ),
                  _buildProfileTile(
                    icon: Icons.security_rounded,
                    iconColor: const Color(0xFF8B5CF6),
                    title: 'End-to-End Encryption',
                    subtitle: 'SHA-256 protected key room',
                  ),
                  Divider(
                    height: 1,
                    indent: 64,
                    endIndent: 20,
                    color: Colors.white.withValues(alpha: 0.08),
                  ),
                  _buildProfileTile(
                    icon: Icons.pets_rounded,
                    iconColor: AppTheme.primaryColor,
                    title: 'BAO CHAT Community',
                    subtitle: 'PanPan Mascot & Jarif Ovi (@jarifovi)',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),

            // Logout Button
            authProvider.isLoading
                ? const CircularProgressIndicator(color: AppTheme.primaryColor)
                : Container(
                    width: double.infinity,
                    height: 56,
                    decoration: BoxDecoration(
                      color: Colors.redAccent.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(
                        color: Colors.redAccent.withValues(alpha: 0.3),
                      ),
                    ),
                    child: ElevatedButton.icon(
                      onPressed: () => _confirmLogout(context, authProvider),
                      icon: const Icon(Icons.logout_rounded, color: Colors.redAccent),
                      label: Text(
                        'Log Out',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Colors.redAccent,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                        ),
                      ),
                    ),
                  ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileTile({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
      leading: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: iconColor.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Icon(icon, color: iconColor, size: 22),
      ),
      title: Text(
        title,
        style: GoogleFonts.plusJakartaSans(
          fontWeight: FontWeight.w700,
          fontSize: 15,
          color: Colors.white,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: GoogleFonts.plusJakartaSans(
          color: AppTheme.textSecondary,
          fontSize: 13,
        ),
      ),
      trailing: trailing ??
          const Icon(
            Icons.arrow_forward_ios_rounded,
            size: 16,
            color: AppTheme.textSecondary,
          ),
    );
  }

  void _confirmLogout(BuildContext context, AuthProvider authProvider) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.surfaceColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
        ),
        title: Text(
          'Log Out',
          style: GoogleFonts.plusJakartaSans(
            color: Colors.white,
            fontWeight: FontWeight.w800,
          ),
        ),
        content: Text(
          'Are you sure you want to log out of your account?',
          style: GoogleFonts.plusJakartaSans(
            color: AppTheme.textSecondary,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(
              'Cancel',
              style: GoogleFonts.plusJakartaSans(color: AppTheme.textSecondary),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              authProvider.logout();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              'Log Out',
              style: GoogleFonts.plusJakartaSans(
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
