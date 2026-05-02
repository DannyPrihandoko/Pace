import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/habit.dart';

class HabitCard extends StatelessWidget {
  final Habit habit;
  final VoidCallback onTap;

  const HabitCard({
    super.key,
    required this.habit,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // 2D Flat Palette
    const black = Colors.black;
    const navyBlue = Color(0xFF1E3A8A);
    const accentGreen = Color(0xFF10B981); // Emerald 500
    const pastelGreen = Color(0xFFD1FAE5); // Emerald 100
    const accentBlue = Color(0xFF3B82F6);  // Blue 500

    final bool isProgress = habit.type == HabitGoalType.progress;
    final double progress = habit.progressPercentage;
    
    // Background color based on completion status
    final bgColor = habit.isCompleted ? pastelGreen : Colors.white;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(6), // Sharp radius
        border: Border.all(color: black, width: 2.0), // Hard 2D border
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(6),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      habit.title,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: navyBlue,
                        letterSpacing: -0.3,
                      ),
                    ),
                  ),
                  // Streak Badge (Flat)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(color: black, width: 1.5),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.local_fire_department_rounded, size: 14, color: Color(0xFFF59E0B)),
                        const SizedBox(width: 4),
                        Text(
                          '${habit.streak}',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: navyBlue,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              if (isProgress) ...[
                // Progress Bar View
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Progress',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: black,
                      ),
                    ),
                    Text(
                      '${habit.currentProgress.toInt()} / ${habit.targetProgress.toInt()}',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        color: navyBlue,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                // 2D Flat Progress Bar
                Container(
                  height: 16,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: black, width: 2.0),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  alignment: Alignment.centerLeft,
                  child: FractionallySizedBox(
                    widthFactor: progress,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 400),
                      curve: Curves.easeOutCubic,
                      decoration: BoxDecoration(
                        color: accentBlue,
                        border: progress > 0 && progress < 1.0 
                            ? const Border(right: BorderSide(color: black, width: 2.0)) 
                            : null,
                      ),
                    ),
                  ),
                ),
              ] else ...[
                // Boolean Checkbox View
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      habit.isCompleted ? 'Sudah Selesai' : 'Belum Selesai',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: black,
                      ),
                    ),
                    // 2D Flat Checkbox
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        color: habit.isCompleted ? accentGreen : Colors.white,
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(color: black, width: 2.0),
                      ),
                      child: habit.isCompleted
                          ? const Icon(Icons.check, size: 20, color: black)
                          : null,
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

