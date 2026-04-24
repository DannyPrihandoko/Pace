import 'package:flutter/material.dart';

class AppColors {
  // Primary Palette - Brighter & More Focused
  static const Color background = Color(0xFFF9FAFB); // Gray 50
  static const Color primary = Color(0xFF4F46E5); // Indigo 600
  static const Color secondary = Color(0xFF0D9488); // Teal 600
  static const Color accent = Color(0xFFF59E0B); // Amber 500
  
  // Semantic Colors
  static const Color success = Color(0xFF10B981);
  static const Color error = Color(0xFFEF4444);
  static const Color info = Color(0xFF3B82F6);

  // Vibrant Activity Colors (Refined for accessibility)
  static const Color color1 = Color(0xFFFB7185); // Rose
  static const Color color2 = Color(0xFF2DD4BF); // Teal
  static const Color color3 = Color(0xFF38BDF8); // Sky
  static const Color color4 = Color(0xFF34D399); // Emerald
  static const Color color5 = Color(0xFFFBBF24); // Amber
  static const Color color6 = Color(0xFFF472B6); // Pink
  static const Color color7 = Color(0xFF818CF8); // Indigo
  
  static const Color textDark = Color(0xFF0F172A); // Slate 900
  static const Color textMuted = Color(0xFF475569); // Slate 600 (Darker for better contrast)
  static const Color white = Color(0xFFFFFFFF);
  static const Color borderColor = Color(0xFFE2E8F0);

  // Dark Mode Palette - Refined Slate/Zinc
  static const Color darkBackground = Color(0xFF020617);
  static const Color darkCard = Color(0xFF0F172A);
  static const Color darkTextPrimary = Color(0xFFF8FAFF);
  static const Color darkTextSecondary = Color(0xFF94A3B8);
  static const Color darkBorderColor = Color(0xFF1E293B); // Slate 800

  static const List<Color> activityColors = [
    color1, color2, color3, color4, color5, color6, color7
  ];

  static const List<Color> mainGradient = [Color(0xFF4F46E5), Color(0xFF7C3AED)]; 
  static const List<Color> accentGradient = [Color(0xFF0D9488), Color(0xFF0284C7)]; 
}
