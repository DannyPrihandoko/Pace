class Task {
  final int? id;
  final String title;
  final String time; // Display string e.g. "09:00 AM"
  final bool isCompleted;
  /// Date this task belongs to (YYYY-MM-DD).
  final String date;

  Task({
    this.id,
    required this.title,
    required this.time,
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
      'time': time,
      'isCompleted': isCompleted ? 1 : 0,
      'date': date,
    };
    if (id != null) map['id'] = id;
    return map;
  }

  factory Task.fromMap(Map<String, dynamic> map) {
    return Task(
      id: map['id'] as int?,
      title: map['title'] as String,
      time: map['time'] as String,
      isCompleted: map['isCompleted'] == 1,
      date: (map['date'] as String?) ?? _today(),
    );
  }

  Task copyWith({
    int? id,
    String? title,
    String? time,
    bool? isCompleted,
    String? date,
  }) {
    return Task(
      id: id ?? this.id,
      title: title ?? this.title,
      time: time ?? this.time,
      isCompleted: isCompleted ?? this.isCompleted,
      date: date ?? this.date,
    );
  }
}
