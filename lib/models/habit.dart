enum HabitGoalType { boolean, progress }

class Habit {
  final String id;
  final String title;
  final HabitGoalType type;
  final double currentProgress;
  final double targetProgress;
  final int streak;
  final bool isCompleted;

  Habit({
    required this.id,
    required this.title,
    required this.type,
    this.currentProgress = 0,
    this.targetProgress = 1,
    this.streak = 0,
    this.isCompleted = false,
  });

  Habit copyWith({
    String? id,
    String? title,
    HabitGoalType? type,
    double? currentProgress,
    double? targetProgress,
    int? streak,
    bool? isCompleted,
  }) {
    return Habit(
      id: id ?? this.id,
      title: title ?? this.title,
      type: type ?? this.type,
      currentProgress: currentProgress ?? this.currentProgress,
      targetProgress: targetProgress ?? this.targetProgress,
      streak: streak ?? this.streak,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }

  double get progressPercentage => (currentProgress / targetProgress).clamp(0.0, 1.0);
}
