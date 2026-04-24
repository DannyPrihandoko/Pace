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
      color: Color(0xFF3B82F6), // Blue 500
    ),
    ActivityCategory(
      name: 'Kerja',
      icon: Icons.work_rounded,
      color: Color(0xFF6366F1), // Indigo 500
    ),
    ActivityCategory(
      name: 'Pribadi',
      icon: Icons.person_rounded,
      color: Color(0xFFEC4899), // Pink 500
    ),
    ActivityCategory(
      name: 'Rapat',
      icon: Icons.groups_rounded,
      color: Color(0xFFF59E0B), // Amber 500
    ),
    ActivityCategory(
      name: 'Kesehatan',
      icon: Icons.favorite_rounded,
      color: Color(0xFF10B981), // Emerald 500
    ),
    ActivityCategory(
      name: 'Belajar',
      icon: Icons.auto_stories_rounded,
      color: Color(0xFF8B5CF6), // Violet 500
    ),
    ActivityCategory(
      name: 'Hobi',
      icon: Icons.videogame_asset_rounded,
      color: Color(0xFFF43F5E), // Rose 500
    ),
    ActivityCategory(
      name: 'Belanja',
      icon: Icons.shopping_cart_rounded,
      color: Color(0xFF06B6D4), // Cyan 500
    ),
  ];

  static ActivityCategory fromName(String? name) {
    return categories.firstWhere(
      (c) => c.name == name,
      orElse: () => categories[0],
    );
  }
}
