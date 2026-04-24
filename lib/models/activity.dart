import 'package:flutter/material.dart';

class Activity {
  final int? id;
  final String title;
  final String description;
  final TimeOfDay time;
  final bool isAlarmEnabled;
  final String date; // Format: YYYY-MM-DD
  final String? recurrenceRule;
  final String category;

  Activity({
    this.id,
    required this.title,
    required this.description,
    required this.time,
    this.isAlarmEnabled = true,
    required this.date,
    this.recurrenceRule,
    this.category = 'Umum',
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
      'recurrenceRule': recurrenceRule,
      'category': category,
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
      recurrenceRule: map['recurrenceRule'] as String?,
      category: map['category'] ?? 'Umum',
    );
  }

  Activity copyWith({
    int? id,
    String? title,
    String? description,
    TimeOfDay? time,
    bool? isAlarmEnabled,
    String? date,
    String? recurrenceRule,
    String? category,
  }) {
    return Activity(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      time: time ?? this.time,
      isAlarmEnabled: isAlarmEnabled ?? this.isAlarmEnabled,
      date: date ?? this.date,
      recurrenceRule: recurrenceRule ?? this.recurrenceRule,
      category: category ?? this.category,
    );
  }

  bool occursOn(DateTime targetDate) {
    final targetStr = "${targetDate.year}-${targetDate.month.toString().padLeft(2, '0')}-${targetDate.day.toString().padLeft(2, '0')}";
    
    if (date == targetStr) return true;
    if (recurrenceRule == null) return false;
    
    final start = DateTime.parse(date);
    final targetDateOnly = DateTime(targetDate.year, targetDate.month, targetDate.day);
    final startDateOnly = DateTime(start.year, start.month, start.day);
    
    if (targetDateOnly.isBefore(startDateOnly)) return false;

    if (recurrenceRule!.contains('FREQ=DAILY')) return true;
    
    if (recurrenceRule!.contains('FREQ=WEEKLY')) {
       final dayNames = ['MO', 'TU', 'WE', 'TH', 'FR', 'SA', 'SU'];
       final day = dayNames[targetDate.weekday - 1];
       return recurrenceRule!.contains('BYDAY=$day');
    }
    
    if (recurrenceRule!.contains('FREQ=MONTHLY')) {
       return recurrenceRule!.contains('BYMONTHDAY=${targetDate.day};') || 
              recurrenceRule!.contains('BYMONTHDAY=${targetDate.day}');
    }
    
    return false;
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
          date == other.date &&
          recurrenceRule == other.recurrenceRule &&
          category == other.category;

  @override
  int get hashCode =>
      id.hashCode ^
      title.hashCode ^
      description.hashCode ^
      time.hashCode ^
      isAlarmEnabled.hashCode ^
      date.hashCode ^
      recurrenceRule.hashCode ^
      category.hashCode;
}
