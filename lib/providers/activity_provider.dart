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
    state = await DatabaseService.instance.readAllActivities();
  }

  Future<void> addActivity(Activity activity) async {
    final id = await DatabaseService.instance.createActivity(activity);
    final newActivity = activity.copyWith(id: id);
    state = [...state, newActivity];
    
    if (newActivity.isAlarmEnabled) {
      await NotificationService().scheduleActivityNotification(newActivity);
    }
  }

  Future<void> updateActivity(Activity activity) async {
    await DatabaseService.instance.updateActivity(activity);
    state = [
      for (final a in state)
        if (a.id == activity.id) activity else a
    ];

    await NotificationService().cancelNotification(activity.id!);
    if (activity.isAlarmEnabled) {
      await NotificationService().scheduleActivityNotification(activity);
    }
  }

  Future<void> deleteActivity(int id) async {
    await DatabaseService.instance.deleteActivity(id);
    state = state.where((a) => a.id != id).toList();
    await NotificationService().cancelNotification(id);
  }

  Future<void> toggleAlarm(Activity activity) async {
    final updated = activity.copyWith(isAlarmEnabled: !activity.isAlarmEnabled);
    await updateActivity(updated);
  }
}
