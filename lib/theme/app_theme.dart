import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Ultra-Modern Crimson-Pinkish Palette
  static const Color darkBackground = Color(0xFF0D0714); // Deep Space Crimson Dark
  static const Color surfaceColor = Color(0xFF1B0E2A);    // Frosted Pinkish-Glass Surface
  static const Color surfaceLight = Color(0xFF2D1642);    // Elevated Hot Pinkish Surface
  static const Color surfaceBorder = Color(0x3BFF2E63);   // Neon Rose Rim Light

  // Vibrant Reddish-Pinkish Accents
  static const Color primaryColor = Color(0xFFFF2E63);   // Electric Crimson Rose
  static const Color primaryAccent = Color(0xFFFF007F);  // Hot Magenta Pink
  static const Color neonCoral = Color(0xFFFF6B6B);      // Sunset Coral Gold
  static const Color neonPinkGlow = Color(0xFFFF85A1);   // Glowing Soft Pink
  static const Color neonCyan = Color(0xFFFF85A1);       // Crimson Rose Accent
  static const Color onlineEmerald = Color(0xFF10B981);  // Online Emerald Status

  // Text Colors
  static const Color textPrimary = Color(0xFFFFF0F5);    // Crisp Lavender-White
  static const Color textSecondary = Color(0xFFC0A5CD);  // Muted Rose-Slate

  // Multi-Pass Glowing Reddish-Pinkish Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFFFF2E63), Color(0xFFFF007F), Color(0xFFFF6B6B)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient crimsonOrbGradient = LinearGradient(
    colors: [Color(0xFFFF2E63), Color(0xFF99004D), Color(0xFFFF007F)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const LinearGradient avatarGradient = LinearGradient(
    colors: [Color(0xFFFF007F), Color(0xFFFF2E63), Color(0xFFFF6B6B)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient sentBubbleGradient = LinearGradient(
    colors: [Color(0xFFD90429), Color(0xFFFF2E63), Color(0xFFEF233C)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // 3D Glassmorphic Crimson Depth Shadows
  static List<BoxShadow> get gravity3dShadows => [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.7),
          offset: const Offset(8, 12),
          blurRadius: 22,
          spreadRadius: 2,
        ),
        BoxShadow(
          color: const Color(0xFFFF2E63).withValues(alpha: 0.2),
          offset: const Offset(-4, -4),
          blurRadius: 18,
          spreadRadius: 0,
        ),
      ];

  static List<BoxShadow> get glowingOrbShadows => [
        BoxShadow(
          color: primaryColor.withValues(alpha: 0.6),
          offset: const Offset(0, 8),
          blurRadius: 30,
          spreadRadius: 6,
        ),
        BoxShadow(
          color: primaryAccent.withValues(alpha: 0.4),
          offset: const Offset(-6, -6),
          blurRadius: 22,
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
