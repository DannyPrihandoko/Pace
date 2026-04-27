class Task {
  final String id;
  final String title;
  final String time;
  final bool isCompleted;

  Task({
    required this.id,
    required this.title,
    required this.time,
    this.isCompleted = false,
  });

  Task copyWith({
    String? id,
    String? title,
    String? time,
    bool? isCompleted,
  }) {
    return Task(
      id: id ?? this.id,
      title: title ?? this.title,
      time: time ?? this.time,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }
}
