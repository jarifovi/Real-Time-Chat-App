import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/gravity_3d_card.dart';
import '../widgets/gravity_3d_orb.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _submitRegister() async {
    if (!_formKey.currentState!.validate()) return;

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    bool success = await authProvider.register(
      name: _nameController.text.trim(),
      email: _emailController.text.trim(),
      password: _passwordController.text,
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
          // Deep Space Dark Crimson Background
          Container(color: AppTheme.darkBackground),

          // 3D Crimson & Magenta Floating Orbs
          const Positioned(
            top: -50,
            right: -50,
            child: Gravity3DOrb(
              size: 270,
              gradient: AppTheme.crimsonOrbGradient,
              offset: Offset(0, 0),
            ),
          ),
          const Positioned(
            bottom: -60,
            left: -50,
            child: Gravity3DOrb(
              size: 250,
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
                    // Unique 3D Glowing Social Sparkle Pulse Icon
                    Container(
                      width: 96,
                      height: 96,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: AppTheme.primaryGradient,
                        boxShadow: AppTheme.glowingOrbShadows,
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.35),
                          width: 2.5,
                        ),
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.favorite_rounded,
                          size: 52,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    Text(
                      'Join VibePulse',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 34,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                        letterSpacing: -1.0,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Experience Next-Gen Crimson Messaging',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.neonPinkGlow,
                      ),
                    ),
                    const SizedBox(height: 32),

                    // 3D Glassmorphic Crimson Card Container
                    Gravity3DCard(
                      padding: const EdgeInsets.all(28),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
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
                                  Icons.alternate_email_rounded,
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
                                  color: AppTheme.neonCoral,
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
                                      child: Text(
                                        'Create Account',
                                        style: GoogleFonts.plusJakartaSans(
                                          fontSize: 17,
                                          fontWeight: FontWeight.w800,
                                          color: Colors.white,
                                        ),
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
                          'Already have an account? ',
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
