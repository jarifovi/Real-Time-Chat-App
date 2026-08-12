import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // BAO CHAT Brand Color Palette (Bamboo Emerald & Midnight Obsidian)
  static const Color darkBackground = Color(0xFF141720); // Midnight Obsidian Dark
  static const Color surfaceColor = Color(0xFF1F2432);    // Bamboo Obsidian Surface
  static const Color surfaceLight = Color(0xFF2B3144);    // Elevated Glass Surface
  static const Color surfaceBorder = Color(0x3B34A853);   // Bamboo Emerald Rim Light

  // Brand Accent Colors
  static const Color primaryColor = Color(0xFF34A853);   // Bamboo Emerald Green
  static const Color primaryAccent = Color(0xFF4285F4);  // Vibe Sky Blue
  static const Color sunnyAmber = Color(0xFFFFBB00);     // Sunny Amber Highlight
  static const Color clayBlush = Color(0xFFE67E22);      // Clay Blush Warm Accent
  static const Color neonPinkGlow = Color(0xFF6EE7B7);   // Soft Mint Glow
  static const Color neonCyan = Color(0xFF34A853);       // Primary Accent Alias
  static const Color onlineEmerald = Color(0xFF10B981);  // Online Emerald Status

  // Text Colors
  static const Color textPrimary = Color(0xFFF8FAFC);    // Crisp Panda White
  static const Color textSecondary = Color(0xFF94A3B8);  // Muted Slate

  // Multi-Pass Glowing Bamboo Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF34A853), Color(0xFF2E9747), Color(0xFF4285F4)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient bambooOrbGradient = LinearGradient(
    colors: [Color(0xFF34A853), Color(0xFF1B5E20), Color(0xFF4285F4)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const LinearGradient avatarGradient = LinearGradient(
    colors: [Color(0xFF34A853), Color(0xFF4285F4), Color(0xFFFFBB00)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient sentBubbleGradient = LinearGradient(
    colors: [Color(0xFF2E9747), Color(0xFF34A853), Color(0xFF2E9B56)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // 3D Glassmorphic Bamboo Depth Shadows
  static List<BoxShadow> get gravity3dShadows => [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.65),
          offset: const Offset(8, 12),
          blurRadius: 22,
          spreadRadius: 2,
        ),
        BoxShadow(
          color: const Color(0xFF34A853).withValues(alpha: 0.25),
          offset: const Offset(-4, -4),
          blurRadius: 18,
          spreadRadius: 0,
        ),
      ];

  static List<BoxShadow> get glowingOrbShadows => [
        BoxShadow(
          color: primaryColor.withValues(alpha: 0.55),
          offset: const Offset(0, 8),
          blurRadius: 28,
          spreadRadius: 5,
        ),
        BoxShadow(
          color: primaryAccent.withValues(alpha: 0.35),
          offset: const Offset(-6, -6),
          blurRadius: 20,
          spreadRadius: 2,
        ),
      ];

  static ThemeData get darkTheme {
    final baseTextTheme = GoogleFonts.plusJakartaSansTextTheme(ThemeData.dark().textTheme);

    return ThemeData.dark().copyWith(
      scaffoldBackgroundColor: darkBackground,
      primaryColor: primaryColor,
      colorScheme: const ColorScheme.dark(
        primary: primaryColor,
        secondary: primaryAccent,
        surface: surfaceColor,
      ),
      textTheme: baseTextTheme.apply(
        bodyColor: textPrimary,
        displayColor: textPrimary,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        foregroundColor: textPrimary,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: GoogleFonts.plusJakartaSans(
          fontSize: 24,
          fontWeight: FontWeight.w800,
          color: textPrimary,
          letterSpacing: -0.5,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          elevation: 12,
          shadowColor: primaryColor.withValues(alpha: 0.7),
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(22),
          ),
          textStyle: GoogleFonts.plusJakartaSans(
            fontSize: 16,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.3,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surfaceLight.withValues(alpha: 0.7),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(22),
          borderSide: const BorderSide(color: surfaceBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(22),
          borderSide: const BorderSide(color: surfaceBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(22),
          borderSide: const BorderSide(color: primaryColor, width: 2.5),
        ),
      ),
    );
  }
}

/// Custom Ultra-Smooth Physics Engine
class UltraSmoothGravityScrollPhysics extends BouncingScrollPhysics {
  const UltraSmoothGravityScrollPhysics({super.parent});

  @override
  UltraSmoothGravityScrollPhysics applyTo(ScrollPhysics? ancestor) {
    return UltraSmoothGravityScrollPhysics(parent: buildParent(ancestor));
  }

  @override
  SpringDescription get spring => const SpringDescription(
        mass: 0.8,
        stiffness: 95.0,
        damping: 14.0,
      );
}
