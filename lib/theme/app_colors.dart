import 'package:flutter/material.dart';

/// Seed color untuk seluruh ColorScheme Material 3.
/// Semua warna turunan dihasilkan via [ColorScheme.fromSeed].
class AppColors {
  AppColors._();

  // ── Seed ──────────────────────────────────────────────────────────────────
  static const Color seed = Color(0xFF4F46E5); // Indigo 600

  // ── Semantic / Fixed ──────────────────────────────────────────────────────
  static const Color success = Color(0xFF10B981); // Emerald 500
  static const Color warning = Color(0xFFF59E0B); // Amber 500
  static const Color error   = Color(0xFFEF4444); // Red 500
  static const Color info    = Color(0xFF3B82F6); // Blue 500

  // ── Activity / Accent ─────────────────────────────────────────────────────
  static const Color color1 = Color(0xFFFB7185); // Rose
  static const Color color2 = Color(0xFF2DD4BF); // Teal
  static const Color color3 = Color(0xFF38BDF8); // Sky
  static const Color color4 = Color(0xFF34D399); // Emerald
  static const Color color5 = Color(0xFFFBBF24); // Amber
  static const Color color6 = Color(0xFFF472B6); // Pink
  static const Color color7 = Color(0xFF818CF8); // Indigo-light

  static const List<Color> activityColors = [
    color1, color2, color3, color4, color5, color6, color7,
  ];

  // ── Gradient helpers ──────────────────────────────────────────────────────
  static const List<Color> mainGradient   = [Color(0xFF4F46E5), Color(0xFF7C3AED)];
  static const List<Color> accentGradient = [Color(0xFF0D9488), Color(0xFF0284C7)];

  // ── Light surface overrides (digunakan di ColorScheme.light) ──────────────
  static const Color lightBackground = Color(0xFFF9FAFB); // Gray 50
  static const Color lightCard       = Color(0xFFFFFFFF);
  static const Color lightBorder     = Color(0xFFE2E8F0); // Slate 200
  static const Color lightTextPrimary   = Color(0xFF0F172A); // Slate 900
  static const Color lightTextSecondary = Color(0xFF475569); // Slate 600

  // ── Dark surface overrides (digunakan di ColorScheme.dark) ────────────────
  static const Color darkBackground = Color(0xFF020617); // Slate 950
  static const Color darkCard       = Color(0xFF0F172A); // Slate 900
  static const Color darkBorder     = Color(0xFF1E293B); // Slate 800
  static const Color darkTextPrimary   = Color(0xFFF8FAFF);
  static const Color darkTextSecondary = Color(0xFF94A3B8); // Slate 400

  // ── Legacy aliases (agar widget lama tidak perlu diubah) ──────────────────
  static const Color primary    = seed;
  static const Color secondary  = Color(0xFF0D9488);
  static const Color accent     = warning;
  static const Color background = lightBackground;
  static const Color white      = Color(0xFFFFFFFF);
  static const Color textDark   = lightTextPrimary;
  static const Color textMuted  = lightTextSecondary;
  static const Color borderColor     = lightBorder;
  static const Color darkTextPrimary_  = darkTextPrimary; // alias internal
  static const Color darkBorderColor  = darkBorder;

  // ── Helper ────────────────────────────────────────────────────────────────
  /// Returns [lightTextPrimary] or [white] based on luminance.
  static Color contrastOn(Color bg) {
    final double lum = bg.computeLuminance();
    return lum > 0.179 ? lightTextPrimary : white;
  }

  // ── ColorScheme factories ─────────────────────────────────────────────────
  static ColorScheme get lightScheme => ColorScheme.fromSeed(
        seedColor: seed,
        brightness: Brightness.light,
      ).copyWith(
        surface:                lightBackground,
        surfaceContainerHighest: lightCard,
        outline:                lightBorder,
        error:                  error,
      );

  static ColorScheme get darkScheme => ColorScheme.fromSeed(
        seedColor: seed,
        brightness: Brightness.dark,
      ).copyWith(
        surface:                darkBackground,
        surfaceContainerHighest: darkCard,
        outline:                darkBorder,
        error:                  error,
      );
}
