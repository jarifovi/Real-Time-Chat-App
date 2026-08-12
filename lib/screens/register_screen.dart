import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/gravity_3d_card.dart';
import '../widgets/gravity_3d_orb.dart';
import '../widgets/panda_avatar_widget.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _photoUrlController = TextEditingController();
  bool _obscurePassword = true;
  String _selectedPresetUrl = PandaAvatarWidget.pandaPresets[0]['url']!;

  @override
  void dispose() {
    _nameController.dispose();
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _photoUrlController.dispose();
    super.dispose();
  }

  void _submitRegister() async {
    if (!_formKey.currentState!.validate()) return;

    final finalPhotoUrl = _photoUrlController.text.trim().isNotEmpty
        ? _photoUrlController.text.trim()
        : _selectedPresetUrl;

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    bool success = await authProvider.register(
      name: _nameController.text.trim(),
      username: _usernameController.text.trim(),
      email: _emailController.text.trim(),
      password: _passwordController.text,
      photoUrl: finalPhotoUrl,
    );

    if (success && mounted) {
      Navigator.of(context).pop();
    } else if (!success && authProvider.errorMessage != null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(authProvider.errorMessage!),
          backgroundColor: AppTheme.primaryColor,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      body: Stack(
        children: [
          // Midnight Obsidian Dark Background
          Container(color: AppTheme.darkBackground),

          // Bamboo Emerald & Sky Blue Floating Orbs
          const Positioned(
            top: -50,
            right: -50,
            child: Gravity3DOrb(
              size: 280,
              gradient: AppTheme.bambooOrbGradient,
              offset: Offset(0, 0),
            ),
          ),
          const Positioned(
            bottom: -60,
            left: -50,
            child: Gravity3DOrb(
              size: 260,
              gradient: AppTheme.primaryGradient,
              offset: Offset(0, 0),
            ),
          ),

          // Main Scroll View with Ultra Smooth Gravity Physics
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                physics: const UltraSmoothGravityScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Official BAO CHAT Logo Badge
                    Container(
                      width: 110,
                      height: 110,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        boxShadow: AppTheme.glowingOrbShadows,
                        border: Border.all(
                          color: AppTheme.primaryColor,
                          width: 3,
                        ),
                      ),
                      child: ClipOval(
                        child: Image.asset(
                          'assets/images/bao_chat_logo.png',
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => const Icon(
                            Icons.pets_rounded,
                            size: 54,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    Text(
                      'Join BAO CHAT',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 34,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                        letterSpacing: -1.0,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Setup Profile Pic & Join 🌿',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.primaryColor,
                      ),
                    ),
                    const SizedBox(height: 28),

                    // 3D Glassmorphic Bamboo Card Container
                    Gravity3DCard(
                      padding: const EdgeInsets.all(24),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // Profile Pic Avatar Picker Header
                            Text(
                              'Choose Profile Avatar 🐾',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 15,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 14),

                            // Avatar Preset Selector Carousel
                            SizedBox(
                              height: 68,
                              child: ListView.builder(
                                scrollDirection: Axis.horizontal,
                                itemCount: PandaAvatarWidget.pandaPresets.length,
                                itemBuilder: (context, index) {
                                  final preset = PandaAvatarWidget.pandaPresets[index];
                                  final isSelected = _selectedPresetUrl == preset['url'];

                                  return GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        _selectedPresetUrl = preset['url']!;
                                        _photoUrlController.clear();
                                      });
                                    },
                                    child: AnimatedContainer(
                                      duration: const Duration(milliseconds: 200),
                                      margin: const EdgeInsets.only(right: 12),
                                      padding: const EdgeInsets.all(3),
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
                                        size: 56,
                                        showOnlineBadge: isSelected,
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                            const SizedBox(height: 16),

                            // Custom Photo URL Field (Optional)
                            TextFormField(
                              controller: _photoUrlController,
                              style: GoogleFonts.plusJakartaSans(color: Colors.white),
                              decoration: InputDecoration(
                                labelText: 'Or Custom Image URL (Optional)',
                                hintText: 'https://example.com/avatar.jpg',
                                hintStyle: GoogleFonts.plusJakartaSans(
                                  color: AppTheme.textSecondary.withValues(alpha: 0.5),
                                  fontSize: 13,
                                ),
                                labelStyle: GoogleFonts.plusJakartaSans(
                                  color: AppTheme.textSecondary,
                                ),
                                prefixIcon: const Icon(
                                  Icons.add_a_photo_outlined,
                                  color: AppTheme.primaryColor,
                                ),
                              ),
                              onChanged: (_) {
                                setState(() {});
                              },
                            ),
                            const SizedBox(height: 18),

                            // Full Name
                            TextFormField(
                              controller: _nameController,
                              style: GoogleFonts.plusJakartaSans(color: Colors.white),
                              decoration: InputDecoration(
                                labelText: 'Full Name',
                                labelStyle: GoogleFonts.plusJakartaSans(
                                  color: AppTheme.textSecondary,
                                ),
                                prefixIcon: const Icon(
                                  Icons.badge_rounded,
                                  color: AppTheme.primaryColor,
                                ),
                              ),
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'Please enter your name';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 18),

                            // Username Handle
                            TextFormField(
                              controller: _usernameController,
                              style: GoogleFonts.plusJakartaSans(color: Colors.white),
                              decoration: InputDecoration(
                                labelText: 'Username (@handle)',
                                hintText: 'e.g. panpan_wave',
                                hintStyle: GoogleFonts.plusJakartaSans(
                                  color: AppTheme.textSecondary.withValues(alpha: 0.5),
                                  fontSize: 14,
                                ),
                                labelStyle: GoogleFonts.plusJakartaSans(
                                  color: AppTheme.textSecondary,
                                ),
                                prefixIcon: const Icon(
                                  Icons.alternate_email_rounded,
                                  color: AppTheme.primaryColor,
                                ),
                              ),
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'Please choose a username';
                                }
                                if (value.trim().length < 3) {
                                  return 'Username must be at least 3 characters';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 18),

                            // Email
                            TextFormField(
                              controller: _emailController,
                              keyboardType: TextInputType.emailAddress,
                              style: GoogleFonts.plusJakartaSans(color: Colors.white),
                              decoration: InputDecoration(
                                labelText: 'Email Address',
                                labelStyle: GoogleFonts.plusJakartaSans(
                                  color: AppTheme.textSecondary,
                                ),
                                prefixIcon: const Icon(
                                  Icons.email_outlined,
                                  color: AppTheme.primaryAccent,
                                ),
                              ),
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'Please enter your email';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 18),

                            // Password
                            TextFormField(
                              controller: _passwordController,
                              obscureText: _obscurePassword,
                              style: GoogleFonts.plusJakartaSans(color: Colors.white),
                              decoration: InputDecoration(
                                labelText: 'Password',
                                labelStyle: GoogleFonts.plusJakartaSans(
                                  color: AppTheme.textSecondary,
                                ),
                                prefixIcon: const Icon(
                                  Icons.fingerprint_rounded,
                                  color: AppTheme.sunnyAmber,
                                ),
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _obscurePassword
                                        ? Icons.visibility_off_outlined
                                        : Icons.visibility_outlined,
                                    color: AppTheme.textSecondary,
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      _obscurePassword = !_obscurePassword;
                                    });
                                  },
                                ),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter a password';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 28),

                            // Submit Button
                            authProvider.isLoading
                                ? const Center(
                                    child: CircularProgressIndicator(
                                      color: AppTheme.primaryColor,
                                    ),
                                  )
                                : Container(
                                    height: 58,
                                    decoration: BoxDecoration(
                                      gradient: AppTheme.primaryGradient,
                                      borderRadius: BorderRadius.circular(22),
                                      boxShadow: AppTheme.glowingOrbShadows,
                                    ),
                                    child: ElevatedButton(
                                      onPressed: _submitRegister,
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.transparent,
                                        shadowColor: Colors.transparent,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(22),
                                        ),
                                      ),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            'Create Account',
                                            style: GoogleFonts.plusJakartaSans(
                                              fontSize: 17,
                                              fontWeight: FontWeight.w800,
                                              color: Colors.white,
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          const Icon(Icons.pets_rounded, size: 18, color: Colors.white),
                                        ],
                                      ),
                                    ),
                                  ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Login Link
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Already in the community? ',
                          style: GoogleFonts.plusJakartaSans(
                            color: AppTheme.textSecondary,
                          ),
                        ),
                        GestureDetector(
                          onTap: () => Navigator.of(context).pop(),
                          child: Text(
                            'Log In',
                            style: GoogleFonts.plusJakartaSans(
                              color: AppTheme.primaryColor,
                              fontWeight: FontWeight.w800,
                              fontSize: 15,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
