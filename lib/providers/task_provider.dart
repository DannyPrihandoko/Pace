import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/task.dart';
import '../services/database_service.dart';
// TaskPriority is defined in task.dart (already imported above)

final taskProvider =
    StateNotifierProvider<TaskNotifier, List<Task>>((ref) {
  return TaskNotifier();
});

class TaskNotifier extends StateNotifier<List<Task>> {
  TaskNotifier() : super([]) {
    loadTasks();
  }

  // ── Load ─────────────────────────────────────────────────────────────────
  Future<void> loadTasks() async {
    if (kIsWeb) {
      state = _webDefaults();
      return;
    }
    try {
      state = await DatabaseService.instance.readAllTasks();
    } catch (e) {
      debugPrint('[TaskProvider] loadTasks error: $e');
      state = [];
    }
  }

  // ── Add ──────────────────────────────────────────────────────────────────────────
  Future<void> addTask(
    String title,
    String time, {
    String? date,
    String category = 'Umum',
    TaskPriority priority = TaskPriority.low,
  }) async {
    final task = Task(
      title: title,
      time: time,
      date: date,
      category: category,
      priority: priority,
    );
    if (kIsWeb) {
      state = [...state, task.copyWith(id: state.length + 1)];
      return;
    }
    try {
      final id = await DatabaseService.instance.createTask(task);
      state = [...state, task.copyWith(id: id)];
    } catch (e) {
      debugPrint('[TaskProvider] addTask error: $e');
    }
  }

  // ── Toggle ────────────────────────────────────────────────────────────────
  Future<void> toggleTask(int? id) async {
    if (id == null) return;
    final task = state.firstWhere((t) => t.id == id);
    final updated = task.copyWith(isCompleted: !task.isCompleted);
    await _persistUpdate(updated);
  }

  // ── Update ────────────────────────────────────────────────────────────────
  Future<void> updateTask(Task task) async {
    await _persistUpdate(task);
  }

  // ── Delete ────────────────────────────────────────────────────────────────
  Future<void> deleteTask(int? id) async {
    if (id == null) return;
    if (!kIsWeb) {
      try {
        await DatabaseService.instance.deleteTask(id);
      } catch (e) {
        debugPrint('[TaskProvider] deleteTask error: $e');
      }
    }
    state = state.where((t) => t.id != id).toList();
  }

  // ── Helpers ───────────────────────────────────────────────────────────────
  Future<void> _persistUpdate(Task updated) async {
    state = [
      for (final t in state)
        if (t.id == updated.id) updated else t,
    ];
    if (!kIsWeb && updated.id != null) {
      try {
        await DatabaseService.instance.updateTask(updated);
      } catch (e) {
        debugPrint('[TaskProvider] updateTask error: $e');
      }
    }
  }

  List<Task> _webDefaults() => [
        Task(id: 1, title: 'Meeting dengan tim desain', time: '09:00 AM'),
        Task(id: 2, title: 'Review sprint backlog', time: '11:30 AM', isCompleted: true),
        Task(id: 3, title: 'Update dokumentasi API', time: '02:00 PM'),
        Task(id: 4, title: 'Olahraga sore', time: '05:00 PM'),
      ];
}
