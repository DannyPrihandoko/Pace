import 'package:flutter/material.dart';

enum AiMessageRole { user, assistant }

enum AiMessageType { text, quickReplies, scheduleCard }

class AiMessage {
  final String id;
  final String text;
  final AiMessageRole role;
  final AiMessageType type;
  final DateTime timestamp;
  final List<String> quickReplies;

  AiMessage({
    required this.id,
    required this.text,
    required this.role,
    this.type = AiMessageType.text,
    this.quickReplies = const [],
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();

  factory AiMessage.fromUser(String text) => AiMessage(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        text: text,
        role: AiMessageRole.user,
      );

  factory AiMessage.fromAssistant(
    String text, {
    AiMessageType type = AiMessageType.text,
    List<String> quickReplies = const [],
  }) =>
      AiMessage(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        text: text,
        role: AiMessageRole.assistant,
        type: type,
        quickReplies: quickReplies,
      );
}

// ─── Intent Definitions ──────────────────────────────────────────────────────

enum AiIntent {
  greeting,
  showTodaySchedule,
  showUpcoming,
  checkHabits,
  checkStreak,
  sleepAdvice,
  checkSleepSchedule,
  motivation,
  productivityTip,
  scheduleAdvice,
  alarmHelp,
  addActivityHelp,
  deleteActivityHelp,
  thankYou,
  affirmation,
  howAreYou,
  unknown,
}

// ─── Context Snapshot ─────────────────────────────────────────────────────────

class AiContext {
  final List<AiActivitySnapshot> todayActivities;
  final List<AiHabitSnapshot> habits;
  final AiSleepSnapshot? sleepSchedule;
  final TimeOfDay currentTime;
  final DateTime currentDate;

  AiContext({
    required this.todayActivities,
    required this.habits,
    this.sleepSchedule,
    required this.currentTime,
    required this.currentDate,
  });

  String get greeting {
    final hour = currentTime.hour;
    if (hour < 12) return 'Selamat pagi';
    if (hour < 17) return 'Selamat siang';
    if (hour < 20) return 'Selamat sore';
    return 'Selamat malam';
  }

  List<AiActivitySnapshot> get upcomingToday {
    final nowMinutes = currentTime.hour * 60 + currentTime.minute;
    return todayActivities
        .where((a) => (a.hour * 60 + a.minute) > nowMinutes)
        .toList()
      ..sort((a, b) =>
          (a.hour * 60 + a.minute).compareTo(b.hour * 60 + b.minute));
  }

  int get completedHabits =>
      habits.where((h) => h.isCompleted).length;

  int get totalHabits => habits.length;

  int get bestStreak =>
      habits.map((h) => h.streak).fold(0, (a, b) => a > b ? a : b);
}

class AiActivitySnapshot {
  final String title;
  final int hour;
  final int minute;
  final String category;
  final bool hasAlarm;

  AiActivitySnapshot({
    required this.title,
    required this.hour,
    required this.minute,
    required this.category,
    required this.hasAlarm,
  });

  String get timeStr =>
      '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';
}

class AiHabitSnapshot {
  final String title;
  final int streak;
  final bool isCompleted;
  final double progress;
  final double target;

  AiHabitSnapshot({
    required this.title,
    required this.streak,
    required this.isCompleted,
    this.progress = 0,
    this.target = 1,
  });

  double get percentage => (progress / target).clamp(0, 1);
}

class AiSleepSnapshot {
  final String bedtime;
  final String wakeupTime;
  final double durationHours;
  final bool windDownEnabled;

  AiSleepSnapshot({
    required this.bedtime,
    required this.wakeupTime,
    required this.durationHours,
    required this.windDownEnabled,
  });
}
