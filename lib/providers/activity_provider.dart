import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/activity.dart';
import '../services/database_service.dart';
import '../services/notification_service.dart';

final activityProvider = StateNotifierProvider<ActivityNotifier, List<Activity>>((ref) {
  return ActivityNotifier();
});

class ActivityNotifier extends StateNotifier<List<Activity>> {
  ActivityNotifier() : super([]) {
    loadActivities();
  }

  Future<void> loadActivities() async {
    if (kIsWeb) {
      // Mock data for Web testing
      state = [
        Activity(
          id: 1,
          title: 'Olahraga Pagi',
          description: 'Lari santai di taman',
          time: const TimeOfDay(hour: 6, minute: 30),
          isAlarmEnabled: true,
          date: DateTime.now().toIso8601String().split('T')[0],
        ),
        Activity(
          id: 2,
          title: 'Meeting Tim',
          description: 'Sinkronisasi proyek Pace',
          time: const TimeOfDay(hour: 10, minute: 0),
          isAlarmEnabled: false,
          date: DateTime.now().toIso8601String().split('T')[0],
        ),
      ];
      return;
    }
    state = await DatabaseService.instance.readAllActivities();
  }

  Future<void> addActivity(Activity activity) async {
    Activity newActivity;
    if (kIsWeb) {
      newActivity = activity.copyWith(id: state.length + 1);
    } else {
      final id = await DatabaseService.instance.createActivity(activity);
      newActivity = activity.copyWith(id: id);
    }
    
    state = [...state, newActivity];
    
    if (newActivity.isAlarmEnabled && !kIsWeb) {
      await NotificationService().scheduleActivityNotification(newActivity);
    }
  }

  Future<void> updateActivity(Activity activity) async {
    if (!kIsWeb) {
      await DatabaseService.instance.updateActivity(activity);
    }
    state = [
      for (final a in state)
        if (a.id == activity.id) activity else a
    ];

    if (!kIsWeb) {
      await NotificationService().cancelNotification(activity.id!);
      if (activity.isAlarmEnabled) {
        await NotificationService().scheduleActivityNotification(activity);
      }
    }
  }

  Future<void> deleteActivity(int id) async {
    if (!kIsWeb) {
      await DatabaseService.instance.deleteActivity(id);
    }
    state = state.where((a) => a.id != id).toList();
    if (!kIsWeb) {
      await NotificationService().cancelNotification(id);
    }
  }

  Future<void> toggleAlarm(Activity activity) async {
    final updated = activity.copyWith(isAlarmEnabled: !activity.isAlarmEnabled);
    await updateActivity(updated);
  }

  Future<void> rescheduleActivity(Activity activity, DateTime newStartTime) async {
    // Format date properly like 'YYYY-MM-DD'
    final year = newStartTime.year.toString();
    final month = newStartTime.month.toString().padLeft(2, '0');
    final day = newStartTime.day.toString().padLeft(2, '0');
    final formattedDate = '$year-$month-$day';

    // Format new time
    final newTime = TimeOfDay(hour: newStartTime.hour, minute: newStartTime.minute);

    final updated = activity.copyWith(
      date: formattedDate,
      time: newTime,
    );

    await updateActivity(updated);
  }
}
