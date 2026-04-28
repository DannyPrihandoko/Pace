import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../widgets/success_modal.dart';
import '../utils/error_codes.dart';
import '../utils/storage_utils.dart';
import '../providers/habit_provider.dart';
import '../widgets/habit_card.dart';
import '../models/habit.dart';

class HabitTrackerScreen extends ConsumerWidget {
  const HabitTrackerScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final habits = ref.watch(habitProvider);
    const navyBlue = Color(0xFF1E3A8A);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          'Habit Tracker',
          style: GoogleFonts.plusJakartaSans(
            fontWeight: FontWeight.w900,
            color: navyBlue,
            letterSpacing: -0.5,
          ),
        ),
        centerTitle: false,
        elevation: 0,
        backgroundColor: Colors.white,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text(
              'Pantau progres harianmu di sini',
              style: GoogleFonts.plusJakartaSans(
                color: Colors.grey[600],
                fontSize: 14,
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.only(bottom: 100),
              itemCount: habits.length,
              itemBuilder: (context, index) {
                final habit = habits[index];
                return HabitCard(
                  habit: habit,
                  onTap: () async {
                    // Pre-check Storage
                    if (!(await StorageUtils.hasEnoughSpace())) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('[ERR-DB-04] Penyimpanan penuh. Gagal memperbarui habit.'),
                          backgroundColor: Colors.redAccent,
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                      return;
                    }

                    try {
                      if (habit.type == HabitGoalType.boolean) {
                        ref.read(habitProvider.notifier).toggleHabit(habit.id);
                        if (!habit.isCompleted) {
                          SuccessModal.show(context, title: 'Habit Selesai!', message: 'Bagus! Kamu telah menyelesaikan "${habit.title}".')
                              .then((_) => Navigator.pop(context));
                        }
                      } else {
                        ref.read(habitProvider.notifier).incrementProgress(habit.id);
                        if (habit.currentProgress + 1 >= habit.targetProgress) {
                          SuccessModal.show(context, title: 'Target Tercapai!', message: 'Hebat! Target "${habit.title}" hari ini sudah tercapai.')
                              .then((_) => Navigator.pop(context));
                        }
                      }
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Gagal memperbarui habit: $e'),
                          backgroundColor: Colors.redAccent,
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    }
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {},
        backgroundColor: navyBlue,
        icon: const Icon(Icons.add_rounded, color: Colors.white),
        label: Text(
          'Tambah Habit',
          style: GoogleFonts.plusJakartaSans(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
