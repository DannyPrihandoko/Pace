import 'package:flutter/material.dart';

class AppColors {
  // Primary Palette - Brighter & Colorful
  static const Color background = Color(0xFFF8FAFF); // Soft Cloud Blue
  static const Color primary = Color(0xFF6366F1); // Indigo Modern
  static const Color secondary = Color(0xFF10B981); // Emerald Green
  static const Color accent = Color(0xFFF59E0B); // Amber
  
  // Vibrant Activity Colors
  static const Color color1 = Color(0xFFFF6B6B); // Coral Pink
  static const Color color2 = Color(0xFF4ECDC4); // Turquoise
  static const Color color3 = Color(0xFF45B7D1); // Sky Blue
  static const Color color4 = Color(0xFF96CEB4); // Sage
  static const Color color5 = Color(0xFFFFEEAD); // Cream Yellow
  static const Color color6 = Color(0xFFD4A5A5); // Rose
  static const Color color7 = Color(0xFF9B59B6); // Amethyst
  
  static const Color textDark = Color(0xFF1E293B); // Slate 800
  static const Color textMuted = Color(0xFF64748B); // Slate 500
  static const Color white = Color(0xFFFFFFFF);
  static const Color borderColor = Color(0xFFE2E8F0);

  // Dark Mode Palette - Keep it colorful
  static const Color darkBackground = Color(0xFF0F172A);
  static const Color darkCard = Color(0xFF1E293B);
  static const Color darkTextPrimary = Color(0xFFF8FAFF);

  static const List<Color> activityColors = [
    color1, color2, color3, color4, color5, color6, color7
  ];

  static const List<Color> mainGradient = [Color(0xFF6366F1), Color(0xFFA855F7)]; // Indigo to Purple
  static const List<Color> accentGradient = [Color(0xFF10B981), Color(0xFF3B82F6)]; // Green to Blue
}
