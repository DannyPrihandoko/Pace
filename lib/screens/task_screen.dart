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
      appBar: AppBar(
        title: const Text('Daftar Tugas'),
        centerTitle: true,
      ),
      body: tasks.isEmpty
          ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.task_alt_rounded,
                      size: 72,
                      color: Theme.of(context).colorScheme.primary.withAlpha(80)),
                  const SizedBox(height: 16),
                  Text('Belum ada tugas',
                      style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 8),
                  Text('Ketuk + untuk menambahkan tugas baru',
                      style: Theme.of(context).textTheme.bodySmall),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.only(top: 12, bottom: 100),
              itemCount: tasks.length,
              itemBuilder: (context, index) {
                final task = tasks[index];
                return Dismissible(
                  key: ValueKey(task.id),
                  direction: DismissDirection.endToStart,
                  background: Container(
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    color: Theme.of(context).colorScheme.errorContainer,
                    child: Icon(Icons.delete_sweep_rounded,
                        color: Theme.of(context).colorScheme.onErrorContainer),
                  ),
                  onDismissed: (_) {
                    ref.read(taskProvider.notifier).deleteTask(task.id);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('"${task.title}" dihapus'),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  },
                  child: TaskItemCard(
                    task: task,
                    onToggle: () {
                      try {
                        ref.read(taskProvider.notifier).toggleTask(task.id);
                        if (!task.isCompleted) {
                          SuccessModal.show(
                            context,
                            title: 'Tugas Selesai!',
                            message: 'Kerja bagus! Satu tugas lagi terselesaikan.',
                          ).then((_) {
                            if (context.mounted) Navigator.pop(context);
                          });
                        }
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Gagal memperbarui tugas: $e'),
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      }
                    },
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddTaskDialog(context, ref),
        child: const Icon(Icons.add_rounded),
      ),
    );
  }

  void _showAddTaskDialog(BuildContext context, WidgetRef ref) {
    final titleCtrl = TextEditingController();
    final timeCtrl = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          left: 24, right: 24, top: 24,
          bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Tambah Tugas Baru',
                style: Theme.of(ctx).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            TextField(
              controller: titleCtrl,
              autofocus: true,
              decoration: const InputDecoration(
                labelText: 'Nama Tugas',
                hintText: 'Contoh: Review dokumen',
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: timeCtrl,
              decoration: const InputDecoration(
                labelText: 'Waktu (opsional)',
                hintText: 'Contoh: 09:00 AM',
                prefixIcon: Icon(Icons.access_time_rounded),
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  final title = titleCtrl.text.trim();
                  if (title.isEmpty) return;
                  ref.read(taskProvider.notifier).addTask(
                    title,
                    timeCtrl.text.trim().isEmpty ? '--:--' : timeCtrl.text.trim(),
                  );
                  Navigator.pop(ctx);
                },
                child: const Text('Simpan'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
