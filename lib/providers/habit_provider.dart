import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/habit.dart';
import '../services/database_service.dart';

final habitProvider =
    StateNotifierProvider<HabitNotifier, List<Habit>>((ref) {
  return HabitNotifier();
});

class HabitNotifier extends StateNotifier<List<Habit>> {
  HabitNotifier() : super([]) {
    loadHabits();
  }

  // ── Load ─────────────────────────────────────────────────────────────────
  Future<void> loadHabits() async {
    if (kIsWeb) {
      state = _webDefaults();
      return;
    }
    try {
      final habits = await DatabaseService.instance.readAllHabits();
      // Seed defaults on first launch
      if (habits.isEmpty) {
        await _seedDefaults();
        state = await DatabaseService.instance.readAllHabits();
      } else {
        state = habits;
      }
    } catch (e) {
      debugPrint('[HabitProvider] loadHabits error: $e');
      state = _webDefaults();
    }
  }

  // ── Add ──────────────────────────────────────────────────────────────────
  Future<void> addHabit(Habit habit) async {
    if (kIsWeb) {
      state = [...state, habit.copyWith(id: state.length + 1)];
      return;
    }
    try {
      final id = await DatabaseService.instance.createHabit(habit);
      state = [...state, habit.copyWith(id: id)];
    } catch (e) {
      debugPrint('[HabitProvider] addHabit error: $e');
    }
  }

  // ── Toggle boolean habit ──────────────────────────────────────────────────
  Future<void> toggleHabit(int? id) async {
    if (id == null) return;
    final habit = state.firstWhere((h) => h.id == id);
    final updated = habit.copyWith(isCompleted: !habit.isCompleted);
    await _persistUpdate(updated);
  }

  // ── Increment progress ────────────────────────────────────────────────────
  Future<void> incrementProgress(int? id) async {
    if (id == null) return;
    final habit = state.firstWhere((h) => h.id == id);
    if (habit.type != HabitGoalType.progress) return;
    final newProgress =
        (habit.currentProgress + 1).clamp(0, habit.targetProgress).toDouble();
    final updated = habit.copyWith(currentProgress: newProgress);
    await _persistUpdate(updated);
  }

  // ── Update arbitrary fields ───────────────────────────────────────────────
  Future<void> updateHabit(Habit habit) async {
    await _persistUpdate(habit);
  }

  // ── Delete ────────────────────────────────────────────────────────────────
  Future<void> deleteHabit(int? id) async {
    if (id == null) return;
    if (!kIsWeb) {
      try {
        await DatabaseService.instance.deleteHabit(id);
      } catch (e) {
        debugPrint('[HabitProvider] deleteHabit error: $e');
      }
    }
    state = state.where((h) => h.id != id).toList();
  }

  // ── Helpers ───────────────────────────────────────────────────────────────
  Future<void> _persistUpdate(Habit updated) async {
    state = [
      for (final h in state)
        if (h.id == updated.id) updated else h,
    ];
    if (!kIsWeb && updated.id != null) {
      try {
        await DatabaseService.instance.updateHabit(updated);
      } catch (e) {
        debugPrint('[HabitProvider] updateHabit error: $e');
      }
    }
  }

  Future<void> _seedDefaults() async {
    for (final h in _webDefaults()) {
      await DatabaseService.instance.createHabit(h);
    }
  }

  List<Habit> _webDefaults() => [
        Habit(
          id: 1,
          title: 'Jalan kaki 10.000 langkah',
          type: HabitGoalType.progress,
          currentProgress: 0,
          targetProgress: 10000,
          streak: 0,
        ),
        Habit(
          id: 2,
          title: 'Tidur 7-8 jam',
          type: HabitGoalType.boolean,
          streak: 0,
        ),
        Habit(
          id: 3,
          title: 'Membaca 1 buku per minggu',
          type: HabitGoalType.progress,
          currentProgress: 0,
          targetProgress: 7,
          streak: 0,
        ),
        Habit(
          id: 4,
          title: 'Daily Journaling',
          type: HabitGoalType.boolean,
          streak: 0,
        ),
      ];
}
