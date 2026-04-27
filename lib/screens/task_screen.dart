import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../widgets/success_modal.dart';
import '../providers/task_provider.dart';
import '../widgets/task_item_card.dart';

class TaskScreen extends ConsumerWidget {
  const TaskScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tasks = ref.watch(taskProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        title: const Text('Daftar Tugas'),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: const Color(0xFF1E3A8A),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.only(top: 12, bottom: 80),
        itemCount: tasks.length,
        itemBuilder: (context, index) {
          final task = tasks[index];
          return TaskItemCard(
            task: task,
            onToggle: () {
              try {
                ref.read(taskProvider.notifier).toggleTask(task.id);
                if (!task.isCompleted) {
                  SuccessModal.show(context, title: 'Tugas Selesai!', message: 'Kerja bagus! Satu tugas lagi terselesaikan.')
                      .then((_) => Navigator.pop(context));
                }
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Gagal memperbarui tugas: $e'),
                    backgroundColor: Colors.redAccent,
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              }
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          ref.read(taskProvider.notifier).addTask('Tugas Baru', '12:00 PM');
        },
        backgroundColor: const Color(0xFF1E3A8A),
        child: const Icon(Icons.add_rounded),
      ),
    );
  }
}
