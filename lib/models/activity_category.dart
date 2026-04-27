import 'package:flutter/material.dart';

class ActivityCategory {
  final String name;
  final IconData icon;
  final Color color;

  const ActivityCategory({
    required this.name,
    required this.icon,
    required this.color,
  });

  static const List<ActivityCategory> categories = [
    ActivityCategory(
      name: 'Umum',
      icon: Icons.dashboard_customize_rounded,
      color: Color(0xFF5E5CE6), // Vibrant Indigo
    ),
    ActivityCategory(
      name: 'Kerja',
      icon: Icons.work_rounded,
      color: Color(0xFF00C7BE), // Vibrant Teal
    ),
    ActivityCategory(
      name: 'Pribadi',
      icon: Icons.person_rounded,
      color: Color(0xFFFF375F), // Vibrant Pink/Rose
    ),
    ActivityCategory(
      name: 'Rapat',
      icon: Icons.groups_rounded,
      color: Color(0xFFFF9F0A), // Vibrant Orange
    ),
    ActivityCategory(
      name: 'Kesehatan',
      icon: Icons.favorite_rounded,
      color: Color(0xFF32D74B), // Vibrant Green
    ),
    ActivityCategory(
      name: 'Belajar',
      icon: Icons.auto_stories_rounded,
      color: Color(0xFFBF5AF2), // Vibrant Purple
    ),
    ActivityCategory(
      name: 'Hobi',
      icon: Icons.videogame_asset_rounded,
      color: Color(0xFFFF2D55), // Vibrant Red
    ),
    ActivityCategory(
      name: 'Belanja',
      icon: Icons.shopping_cart_rounded,
      color: Color(0xFF64D2FF), // Vibrant Sky
    ),
  ];

  static ActivityCategory fromName(String? name) {
    return categories.firstWhere(
      (c) => c.name == name,
      orElse: () => categories[0],
    );
  }
}
