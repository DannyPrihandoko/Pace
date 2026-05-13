import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../widgets/success_modal.dart';
import '../utils/storage_utils.dart';
import '../providers/habit_provider.dart';
import '../widgets/habit_card.dart';
import '../models/habit.dart';

class HabitTrackerScreen extends ConsumerWidget {
  const HabitTrackerScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final habits = ref.watch(habitProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Habit Tracker'),
        centerTitle: false,
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
                      // ignore: use_build_context_synchronously
                      if (!context.mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('[ERR-DB-04] Penyimpanan penuh. Gagal memperbarui habit.'),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                      return;
                    }

                    try {
                      if (habit.type == HabitGoalType.boolean) {
                        ref.read(habitProvider.notifier).toggleHabit(habit.id);
                        if (!habit.isCompleted) {
                          // ignore: use_build_context_synchronously
                          if (context.mounted) {
                            SuccessModal.show(context,
                              title: 'Habit Selesai!',
                              message: 'Bagus! Kamu telah menyelesaikan "${habit.title}".',
                            );
                          }
                        }
                      } else {
                        ref.read(habitProvider.notifier).incrementProgress(habit.id);
                        if (habit.currentProgress + 1 >= habit.targetProgress) {
                          // ignore: use_build_context_synchronously
                          if (context.mounted) {
                            SuccessModal.show(context,
                              title: 'Target Tercapai!',
                              message: 'Hebat! Target "${habit.title}" hari ini sudah tercapai.',
                            );
                          }
                        }
                      }
                    } catch (e) {
                      // ignore: use_build_context_synchronously
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Gagal memperbarui habit: $e'),
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      }
                    }
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddHabitSheet(context, ref),
        icon: const Icon(Icons.add_rounded),
        label: const Text('Tambah Habit'),
      ),
    );
  }

  void _showAddHabitSheet(BuildContext context, WidgetRef ref) {
    final titleController = TextEditingController();
    HabitGoalType selectedType = HabitGoalType.boolean;
    double target = 1;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheetState) => Padding(
          padding: EdgeInsets.only(
            left: 24, right: 24, top: 24,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Tambah Habit Baru',
                  style: Theme.of(ctx).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              TextField(
                controller: titleController,
                autofocus: true,
                decoration: const InputDecoration(
                  labelText: 'Nama Habit',
                  hintText: 'Contoh: Minum 8 gelas air',
                ),
              ),
              const SizedBox(height: 16),
              Text('Tipe', style: Theme.of(ctx).textTheme.titleSmall),
              const SizedBox(height: 8),
              SegmentedButton<HabitGoalType>(
                segments: const [
                  ButtonSegment(value: HabitGoalType.boolean, label: Text('Ya/Tidak')),
                  ButtonSegment(value: HabitGoalType.progress, label: Text('Progress')),
                ],
                selected: {selectedType},
                onSelectionChanged: (s) => setSheetState(() => selectedType = s.first),
              ),
              if (selectedType == HabitGoalType.progress) ...[
                const SizedBox(height: 16),
                TextField(
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Target'),
                  onChanged: (v) => target = double.tryParse(v) ?? 1,
                ),
              ],
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    final title = titleController.text.trim();
                    if (title.isEmpty) return;
                    ref.read(habitProvider.notifier).addHabit(
                      Habit(
                        title: title,
                        type: selectedType,
                        targetProgress: selectedType == HabitGoalType.progress ? target : 1,
                      ),
                    );
                    Navigator.pop(ctx);
                  },
                  child: const Text('Simpan'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
