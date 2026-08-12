import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // 3D Gravity Deep Midnight Palette
  static const Color darkBackground = Color(0xFF070A12); // Pure Deep Space
  static const Color surfaceColor = Color(0xFF0F172A);    // 3D Gravity Surface Card
  static const Color surfaceLight = Color(0xFF1E293B);    // Elevated 3D Top Highlight
  static const Color surfaceBorder = Color(0x2BFFFFFF);   // 3D Rim Light

  // Neon Gravity Accents
  static const Color primaryColor = Color(0xFF8B5CF6);   // Deep Violet 3D
  static const Color primaryAccent = Color(0xFF6366F1);  // Electric Indigo
  static const Color neonCyan = Color(0xFF06B6D4);       // Neon Cyber Blue
  static const Color onlineEmerald = Color(0xFF10B981);  // 3D Emerald Glow

  // Text Colors
  static const Color textPrimary = Color(0xFFF8FAFC);    // Crisp White
  static const Color textSecondary = Color(0xFF94A3B8);  // Soft Slate

  // 3D Multi-Layered Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF8B5CF6), Color(0xFF4F46E5), Color(0xFF06B6D4)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient gravityOrbGradient = LinearGradient(
    colors: [Color(0xFFA855F7), Color(0xFF6366F1), Color(0xFF3B82F6)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const LinearGradient avatarGradient = LinearGradient(
    colors: [Color(0xFFEC4899), Color(0xFF8B5CF6), Color(0xFF06B6D4)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient sentBubbleGradient = LinearGradient(
    colors: [Color(0xFF7C3AED), Color(0xFF4F46E5)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // 3D Neumorphic Gravity Shadows
  static List<BoxShadow> get gravity3dShadows => [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.6),
          offset: const Offset(8, 12),
          blurRadius: 20,
          spreadRadius: 2,
        ),
        BoxShadow(
          color: const Color(0xFF8B5CF6).withValues(alpha: 0.15),
          offset: const Offset(-4, -4),
          blurRadius: 16,
          spreadRadius: 0,
        ),
      ];

  static List<BoxShadow> get glowingOrbShadows => [
        BoxShadow(
          color: primaryColor.withValues(alpha: 0.5),
          offset: const Offset(0, 10),
          blurRadius: 28,
          spreadRadius: 4,
        ),
        BoxShadow(
          color: neonCyan.withValues(alpha: 0.3),
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
        secondary: neonCyan,
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
          elevation: 10,
          shadowColor: primaryColor.withValues(alpha: 0.6),
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          textStyle: GoogleFonts.plusJakartaSans(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.2,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surfaceLight.withValues(alpha: 0.6),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: const BorderSide(color: surfaceBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: const BorderSide(color: surfaceBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: const BorderSide(color: primaryColor, width: 2.5),
        ),
      ),
    );
  }
}

/// Custom Ultra-Smooth Gravity Bouncing Physics
class UltraSmoothGravityScrollPhysics extends BouncingScrollPhysics {
  const UltraSmoothGravityScrollPhysics({super.parent});

  @override
  UltraSmoothGravityScrollPhysics applyTo(ScrollPhysics? ancestor) {
    return UltraSmoothGravityScrollPhysics(parent: buildParent(ancestor));
  }

  @override
  SpringDescription get spring => const SpringDescription(
        mass: 0.8,
        stiffness: 90.0,
        damping: 14.0,
      );
}
