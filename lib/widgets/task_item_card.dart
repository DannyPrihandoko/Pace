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
    // Professional Navy Color Palette
    const navyBlue = Color(0xFF1E3A8A);
    const brightAccent = Color(0xFF3B82F6);
    const neutralGrey = Color(0xFF94A3B8);
    const borderColor = Color(0xFFE2E8F0);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: task.isCompleted ? Colors.white.withOpacity(0.9) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: task.isCompleted ? borderColor : navyBlue.withOpacity(0.1),
          width: 1.5,
        ),
      ),
      child: Row(
        children: [
          // Custom Checkbox Animation
          GestureDetector(
            onTap: onToggle,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: task.isCompleted ? brightAccent : Colors.transparent,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                  color: task.isCompleted ? brightAccent : navyBlue.withOpacity(0.3),
                  width: 2,
                ),
              ),
              child: task.isCompleted
                  ? const Icon(Icons.check_rounded, size: 18, color: Colors.white)
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
                        fontWeight: FontWeight.w700,
                        color: task.isCompleted ? neutralGrey : navyBlue,
                      ),
                    ),
                    // Strikethrough Animation
                    Positioned.fill(
                      child: AnimatedAlign(
                        duration: const Duration(milliseconds: 400),
                        curve: Curves.easeInOut,
                        alignment: task.isCompleted ? Alignment.centerLeft : const Alignment(-1.1, 0),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 400),
                          width: task.isCompleted ? double.infinity : 0,
                          height: 2,
                          color: brightAccent.withOpacity(0.5),
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
                    fontWeight: FontWeight.w500,
                    color: task.isCompleted ? neutralGrey.withOpacity(0.7) : neutralGrey,
                  ),
                ),
              ],
            ),
          ),
          // Active Accent
          if (!task.isCompleted)
            Container(
              width: 8,
              height: 8,
              decoration: const BoxDecoration(
                color: brightAccent,
                shape: BoxShape.circle,
              ),
            ),
        ],
      ),
    );
  }
}
