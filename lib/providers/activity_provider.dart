import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:home_widget/home_widget.dart';
import '../models/activity.dart';
import '../services/database_service.dart';
import '../services/notification_service.dart';

final activityProvider = StateNotifierProvider<ActivityNotifier, List<Activity>>((ref) {
  return ActivityNotifier();
});

final todayActivitiesProvider = Provider<List<Activity>>((ref) {
  final activities = ref.watch(activityProvider);
  final now = DateTime.now();
  final todayStr = DateFormat('yyyy-MM-dd').format(now);
  
  return activities.where((a) => a.occursOn(now)).toList()..sort((a, b) {
    final aMinutes = a.time.hour * 60 + a.time.minute;
    final bMinutes = b.time.hour * 60 + b.time.minute;
    return aMinutes.compareTo(bMinutes);
  });
});

class ActivityNotifier extends StateNotifier<List<Activity>> {
  ActivityNotifier() : super([]) {
    loadActivities();
  }

  Future<void> loadActivities() async {
    if (kIsWeb) {
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
      _updateWidget();
      return;
    }
    state = await DatabaseService.instance.readAllActivities();
    _updateWidget();
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
    _updateWidget();
    
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
    _updateWidget();

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
    _updateWidget();
    if (!kIsWeb) {
      await NotificationService().cancelNotification(id);
    }
  }

  Future<void> toggleAlarm(Activity activity) async {
    final updated = activity.copyWith(isAlarmEnabled: !activity.isAlarmEnabled);
    await updateActivity(updated);
  }

  void _updateWidget() {
    if (kIsWeb) return;

    final now = DateTime.now();
    final todayStr = DateFormat('yyyy-MM-dd').format(now);
    
    // Find upcoming activities today that haven't passed yet
    final upcomingActivities = state.where((a) {
      if (a.date != todayStr) return false;
      final activityTimeMinutes = a.time.hour * 60 + a.time.minute;
      final nowMinutes = now.hour * 60 + now.minute;
      return activityTimeMinutes > nowMinutes;
    }).toList()..sort((a, b) => (a.time.hour * 60 + a.time.minute).compareTo(b.time.hour * 60 + b.time.minute));

    if (upcomingActivities.isEmpty) {
      HomeWidget.saveWidgetData<String>('upcoming_1_title', 'No more tasks today');
      HomeWidget.saveWidgetData<String>('upcoming_1_time', '--');
      HomeWidget.saveWidgetData<String>('upcoming_1_category', '✓');
      HomeWidget.saveWidgetData<String>('upcoming_2_title', '');
    } else {
      // First activity
      final next1 = upcomingActivities[0];
      HomeWidget.saveWidgetData<String>('upcoming_1_title', next1.title);
      HomeWidget.saveWidgetData<String>('upcoming_1_time', '${next1.time.hour.toString().padLeft(2, '0')}:${next1.time.minute.toString().padLeft(2, '0')}');
      HomeWidget.saveWidgetData<String>('upcoming_1_category', next1.category);

      // Second activity (if exists)
      if (upcomingActivities.length > 1) {
        final next2 = upcomingActivities[1];
        HomeWidget.saveWidgetData<String>('upcoming_2_title', next2.title);
        HomeWidget.saveWidgetData<String>('upcoming_2_time', '${next2.time.hour.toString().padLeft(2, '0')}:${next2.time.minute.toString().padLeft(2, '0')}');
        HomeWidget.saveWidgetData<String>('upcoming_2_category', next2.category);
      } else {
        HomeWidget.saveWidgetData<String>('upcoming_2_title', '');
      }
    }

    HomeWidget.updateWidget(
      name: 'PaceWidgetProvider',
      androidName: 'PaceWidgetProvider',
    );
  }

  Future<void> rescheduleActivity(Activity activity, DateTime newStartTime) async {
    final year = newStartTime.year.toString();
    final month = newStartTime.month.toString().padLeft(2, '0');
    final day = newStartTime.day.toString().padLeft(2, '0');
    final formattedDate = '$year-$month-$day';
    final newTime = TimeOfDay(hour: newStartTime.hour, minute: newStartTime.minute);

    final updated = activity.copyWith(
      date: formattedDate,
      time: newTime,
    );

    await updateActivity(updated);
  }
}
