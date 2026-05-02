import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/task.dart';

class TaskItemCard extends StatelessWidget {
  final Task task;
  final VoidCallback onToggle;

  const TaskItemCard({
    super.key,
    required this.task,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    // 2D Flat Palette
    const black = Colors.black;
    const navyBlue = Color(0xFF1E3A8A);
    const brightAccent = Color(0xFF3B82F6);
    const completedBg = Color(0xFFDBEAFE); // Pastel Blue for completed
    const defaultBg = Colors.white;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: task.isCompleted ? completedBg : defaultBg,
        borderRadius: BorderRadius.circular(6), // Sharp border radius
        border: Border.all(color: black, width: 2.0), // Hard 2D border
      ),
      child: Row(
        children: [
          // Custom 2D Flat Checkbox
          GestureDetector(
            onTap: onToggle,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              width: 26,
              height: 26,
              decoration: BoxDecoration(
                color: task.isCompleted ? brightAccent : Colors.white,
                borderRadius: BorderRadius.circular(4), // Sharp corners
                border: Border.all(color: black, width: 2.0),
              ),
              child: task.isCompleted
                  ? const Icon(Icons.check, size: 18, color: black)
                  : null,
            ),
          ),
          const SizedBox(width: 16),
          // Task Title & Time with Strikethrough Animation
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Stack(
                  children: [
                    Text(
                      task.title,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: black,
                      ),
                    ),
                    // Strikethrough Animation (Flat styled)
                    Positioned.fill(
                      child: AnimatedAlign(
                        duration: const Duration(milliseconds: 400),
                        curve: Curves.easeInOut,
                        alignment: task.isCompleted ? Alignment.centerLeft : const Alignment(-1.1, 0),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 400),
                          width: task.isCompleted ? double.infinity : 0,
                          height: 3, // Thicker strike for flat look
                          color: black,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  task.time,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: black.withOpacity(0.6),
                  ),
                ),
              ],
            ),
          ),
          // Active Accent (Flat block instead of circle)
          if (!task.isCompleted)
            Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: brightAccent,
                border: Border.all(color: black, width: 1.5),
              ),
            ),
        ],
      ),
    );
  }
}

