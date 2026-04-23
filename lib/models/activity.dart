import 'package:flutter/material.dart';

class Activity {
  final int? id;
  final String title;
  final String description;
  final TimeOfDay time;
  final bool isAlarmEnabled;
  final String date; // Format: YYYY-MM-DD

  Activity({
    this.id,
    required this.title,
    required this.description,
    required this.time,
    this.isAlarmEnabled = true,
    required this.date,
  });

  DateTime get startTime {
    final dateParts = date.split('-');
    if (dateParts.length == 3) {
      final year = int.parse(dateParts[0]);
      final month = int.parse(dateParts[1]);
      final day = int.parse(dateParts[2]);
      return DateTime(year, month, day, time.hour, time.minute);
    }
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day, time.hour, time.minute);
  }

  DateTime get endTime => startTime.add(const Duration(hours: 1));

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'hour': time.hour,
      'minute': time.minute,
      'isAlarmEnabled': isAlarmEnabled ? 1 : 0,
      'date': date,
    };
  }

  factory Activity.fromMap(Map<String, dynamic> map) {
    return Activity(
      id: map['id'],
      title: map['title'],
      description: map['description'],
      time: TimeOfDay(hour: map['hour'], minute: map['minute']),
      isAlarmEnabled: map['isAlarmEnabled'] == 1,
      date: map['date'],
    );
  }

  Activity copyWith({
    int? id,
    String? title,
    String? description,
    TimeOfDay? time,
    bool? isAlarmEnabled,
    String? date,
  }) {
    return Activity(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      time: time ?? this.time,
      isAlarmEnabled: isAlarmEnabled ?? this.isAlarmEnabled,
      date: date ?? this.date,
    );
  }
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Activity &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          title == other.title &&
          description == other.description &&
          time == other.time &&
          isAlarmEnabled == other.isAlarmEnabled &&
          date == other.date;

  @override
  int get hashCode =>
      id.hashCode ^
      title.hashCode ^
      description.hashCode ^
      time.hashCode ^
      isAlarmEnabled.hashCode ^
      date.hashCode;
}
