enum HabitGoalType { boolean, progress }

class Habit {
  final int? id;
  final String title;
  final HabitGoalType type;
  final double currentProgress;
  final double targetProgress;
  final int streak;
  final bool isCompleted;
  /// Date this habit record applies to (YYYY-MM-DD).
  /// One row per habit definition; `date` tracks the last-reset day.
  final String date;

  Habit({
    this.id,
    required this.title,
    required this.type,
    this.currentProgress = 0,
    this.targetProgress = 1,
    this.streak = 0,
    this.isCompleted = false,
    String? date,
  }) : date = date ?? _today();

  static String _today() {
    final now = DateTime.now();
    return '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
  }

  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{
      'title': title,
      'type': type.name,
      'currentProgress': currentProgress,
      'targetProgress': targetProgress,
      'streak': streak,
      'isCompleted': isCompleted ? 1 : 0,
      'date': date,
    };
    if (id != null) map['id'] = id;
    return map;
  }

  factory Habit.fromMap(Map<String, dynamic> map) {
    return Habit(
      id: map['id'] as int?,
      title: map['title'] as String,
      type: HabitGoalType.values.firstWhere(
        (e) => e.name == map['type'],
        orElse: () => HabitGoalType.boolean,
      ),
      currentProgress: (map['currentProgress'] as num).toDouble(),
      targetProgress: (map['targetProgress'] as num).toDouble(),
      streak: (map['streak'] as int?) ?? 0,
      isCompleted: map['isCompleted'] == 1,
      date: (map['date'] as String?) ?? _today(),
    );
  }

  Habit copyWith({
    int? id,
    String? title,
    HabitGoalType? type,
    double? currentProgress,
    double? targetProgress,
    int? streak,
    bool? isCompleted,
    String? date,
  }) {
    return Habit(
      id: id ?? this.id,
      title: title ?? this.title,
      type: type ?? this.type,
      currentProgress: currentProgress ?? this.currentProgress,
      targetProgress: targetProgress ?? this.targetProgress,
      streak: streak ?? this.streak,
      isCompleted: isCompleted ?? this.isCompleted,
      date: date ?? this.date,
    );
  }

  double get progressPercentage =>
      (currentProgress / targetProgress).clamp(0.0, 1.0);
}
