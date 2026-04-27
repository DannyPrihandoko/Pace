import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/habit.dart';

class HabitNotifier extends StateNotifier<List<Habit>> {
  HabitNotifier() : super([
    Habit(
      id: '1', 
      title: 'Jalan kaki 10.000 langkah', 
      type: HabitGoalType.progress, 
      currentProgress: 6500, 
      targetProgress: 10000,
      streak: 5
    ),
    Habit(
      id: '2', 
      title: 'Tidur 7-8 jam', 
      type: HabitGoalType.boolean, 
      isCompleted: true,
      streak: 12
    ),
    Habit(
      id: '3', 
      title: 'Membaca 1 buku per minggu', 
      type: HabitGoalType.progress, 
      currentProgress: 3, 
      targetProgress: 7, // 3/7 hari
      streak: 2
    ),
    Habit(
      id: '4', 
      title: 'Daily Journaling', 
      type: HabitGoalType.boolean, 
      isCompleted: false,
      streak: 0
    ),
  ]);

  void toggleHabit(String id) {
    state = [
      for (final habit in state)
        if (habit.id == id)
          habit.copyWith(isCompleted: !habit.isCompleted)
        else
          habit,
    ];
  }

  void incrementProgress(String id) {
    state = [
      for (final habit in state)
        if (habit.id == id && habit.type == HabitGoalType.progress)
          habit.copyWith(currentProgress: (habit.currentProgress + 1).clamp(0, habit.targetProgress))
        else
          habit,
    ];
  }
}

final habitProvider = StateNotifierProvider<HabitNotifier, List<Habit>>((ref) {
  return HabitNotifier();
});
