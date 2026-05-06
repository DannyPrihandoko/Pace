import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/mood_provider.dart';
import '../theme/colors.dart';

class MoodCard extends ConsumerWidget {
  const MoodCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final todayMood = ref.watch(moodProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    if (todayMood != null) {
      return Card(
        margin: EdgeInsets.zero,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  _getMoodEmoji(todayMood.score),
                  style: const TextStyle(fontSize: 24),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'MOOD KAMU HARI INI',
                      style: GoogleFonts.plusJakartaSans(
                        color: isDark ? AppColors.darkTextSecondary : AppColors.textMuted,
                        fontWeight: FontWeight.w800,
                        fontSize: 11,
                        letterSpacing: 1.5,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Kamu merasa ${_getMoodText(todayMood.score)}!',
                      style: GoogleFonts.plusJakartaSans(
                        fontWeight: FontWeight.w800,
                        fontSize: 18,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: Icon(
                  Icons.edit_outlined, 
                  color: isDark ? AppColors.darkTextSecondary : AppColors.textMuted, 
                  size: 20
                ),
                onPressed: () {
                  ref.read(moodProvider.notifier).clearState();
                },
              ),
            ],
          ),
        ),
      );
    }

    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'BAGAIMANA MOODMU HARI INI?',
              style: GoogleFonts.plusJakartaSans(
                color: isDark ? AppColors.darkTextSecondary : AppColors.textMuted,
                fontWeight: FontWeight.w800,
                fontSize: 11,
                letterSpacing: 1.5,
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(5, (index) {
                final score = index + 1;
                return GestureDetector(
                  onTap: () {
                    ref.read(moodProvider.notifier).saveMood(score);
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 54,
                    height: 54,
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.darkBackground : AppColors.background,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isDark ? AppColors.darkBorderColor : AppColors.borderColor,
                        width: 1,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        _getMoodEmoji(score),
                        style: const TextStyle(fontSize: 24),
                      ),
                    ),
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  String _getMoodEmoji(int score) {
    switch (score) {
      case 1: return '😫';
      case 2: return '😕';
      case 3: return '😐';
      case 4: return '🙂';
      case 5: return '🤩';
      default: return '😐';
    }
  }

  String _getMoodText(int score) {
    switch (score) {
      case 1: return 'Sangat Buruk';
      case 2: return 'Buruk';
      case 3: return 'Biasa Saja';
      case 4: return 'Baik';
      case 5: return 'Luar Biasa';
      default: return 'Biasa Saja';
    }
  }
}

