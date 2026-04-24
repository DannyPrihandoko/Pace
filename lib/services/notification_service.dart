import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import 'package:flutter_timezone/flutter_timezone.dart';
import '../models/activity.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    try {
      tz.initializeTimeZones();
      final dynamic timezoneData = await FlutterTimezone.getLocalTimezone();
      
      String timeZoneName;
      if (timezoneData is String) {
        timeZoneName = timezoneData;
      } else {
        // Safe extraction for different versions/platforms
        try {
          timeZoneName = timezoneData.toString();
          if (timeZoneName.contains('Instance of')) {
            // If it's a generic object but not a string, try common property names
            final dynamic d = timezoneData;
            timeZoneName = d.name ?? d.id ?? 'UTC';
          }
        } catch (e) {
          timeZoneName = 'UTC';
        }
      }
      
      tz.setLocalLocation(tz.getLocation(timeZoneName));
    } catch (e) {
      debugPrint('Timezone initialization failed: $e. Falling back to UTC.');
      try {
        tz.setLocalLocation(tz.getLocation('UTC'));
      } catch (inner) {
        debugPrint('UTC fallback also failed.');
      }
    }

    try {
      const AndroidInitializationSettings initializationSettingsAndroid =
          AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings initializationSettingsDarwin =
        DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsDarwin,
    );

    await flutterLocalNotificationsPlugin.initialize(
        settings: initializationSettings,
        onDidReceiveNotificationResponse: (NotificationResponse details) {
          // Handle notification tap
        },
      );
    } catch (e) {
      debugPrint('Notification initialization failed: $e');
    }
  }

  Future<void> scheduleActivityNotification(Activity activity) async {
    if (!activity.isAlarmEnabled) return;

    final now = DateTime.now();
    DateTime scheduledDate = DateTime(
      now.year,
      now.month,
      now.day,
      activity.time.hour,
      activity.time.minute,
    );

    // If it's in the past and not recurring, don't schedule
    if (scheduledDate.isBefore(now) && activity.recurrenceRule == null) return;

    DateTimeComponents? matchComponents = DateTimeComponents.time;
    
    if (activity.recurrenceRule != null) {
      if (activity.recurrenceRule!.contains('FREQ=DAILY')) {
        matchComponents = DateTimeComponents.time;
      } else if (activity.recurrenceRule!.contains('FREQ=WEEKLY')) {
        matchComponents = DateTimeComponents.dayOfWeekAndTime;
        // Adjust scheduledDate to the correct day of week if needed
        // butzonedSchedule handles it if we match dayOfWeekAndTime
      } else if (activity.recurrenceRule!.contains('FREQ=MONTHLY')) {
        matchComponents = DateTimeComponents.dayOfMonthAndTime;
      }
    }

    await flutterLocalNotificationsPlugin.zonedSchedule(
      id: activity.id ?? 0,
      title: activity.title,
      body: activity.description,
      scheduledDate: tz.TZDateTime.from(scheduledDate, tz.local),
      notificationDetails: const NotificationDetails(
        android: AndroidNotificationDetails(
          'pace_activity_channel',
          'Pace Activity Alerts',
          importance: Importance.max,
          priority: Priority.high,
          ticker: 'ticker',
        ),
        iOS: DarwinNotificationDetails(),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      matchDateTimeComponents: matchComponents,
    );
  }

  Future<void> cancelNotification(int id) async {
    await flutterLocalNotificationsPlugin.cancel(id: id);
  }
}
