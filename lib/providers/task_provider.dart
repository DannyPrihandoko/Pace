import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/task.dart';

class TaskNotifier extends StateNotifier<List<Task>> {
  TaskNotifier() : super([
    Task(id: '1', title: 'Meeting dengan tim desain', time: '09:00 AM'),
    Task(id: '2', title: 'Review sprint backlog', time: '11:30 AM', isCompleted: true),
    Task(id: '3', title: 'Update dokumentasi API', time: '02:00 PM'),
    Task(id: '4', title: 'Olahraga sore', time: '05:00 PM'),
  ]);

  void toggleTask(String id) {
    state = [
      for (final task in state)
        if (task.id == id)
          task.copyWith(isCompleted: !task.isCompleted)
        else
          task,
    ];
  }

  void addTask(String title, String time) {
    state = [
      ...state,
      Task(
        id: DateTime.now().toString(),
        title: title,
        time: time,
      ),
    ];
  }
}

final taskProvider = StateNotifierProvider<TaskNotifier, List<Task>>((ref) {
  return TaskNotifier();
});
