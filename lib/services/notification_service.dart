import 'dart:convert';
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
          if (details.actionId == 'snooze_action' && details.payload != null) {
            _handleSnooze(details.payload!);
          }
        },
      );
    } catch (e) {
      debugPrint('Notification initialization failed: $e');
    }
  }

  Future<void> scheduleActivityNotification(Activity activity) async {
    if (!activity.isAlarmEnabled) return;

    final now = DateTime.now();
    DateTime scheduledDate = activity.startTime.subtract(Duration(minutes: activity.reminderOffset));

    // If it's in the past and not recurring, don't schedule
    if (scheduledDate.isBefore(now) && activity.recurrenceRule == null) return;

    DateTimeComponents? matchComponents = DateTimeComponents.time;
    
    if (activity.recurrenceRule != null) {
      if (activity.recurrenceRule!.contains('FREQ=DAILY')) {
        matchComponents = DateTimeComponents.time;
      } else if (activity.recurrenceRule!.contains('FREQ=WEEKLY')) {
        matchComponents = DateTimeComponents.dayOfWeekAndTime;
      } else if (activity.recurrenceRule!.contains('FREQ=MONTHLY')) {
        matchComponents = DateTimeComponents.dayOfMonthAndTime;
      }
    }

    // Common notification details for alarm behavior
    final androidDetails = AndroidNotificationDetails(
      'pace_activity_channel',
      'Pace Activity Alerts',
      channelDescription: 'Main channel for Pace activity alarms',
      importance: Importance.max,
      priority: Priority.max,
      fullScreenIntent: true,
      category: AndroidNotificationCategory.alarm,
      audioAttributesUsage: AudioAttributesUsage.alarm,
      ticker: 'Pace Alarm',
      actions: [
        const AndroidNotificationAction(
          'snooze_action',
          'Snooze',
          showsUserInterface: false,
          cancelNotification: true,
        ),
      ],
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
      interruptionLevel: InterruptionLevel.critical,
    );

    final details = NotificationDetails(android: androidDetails, iOS: iosDetails);

    // Schedule main notification
    await flutterLocalNotificationsPlugin.zonedSchedule(
      id: activity.id ?? 0,
      title: activity.title,
      body: activity.description.isEmpty ? 'Waktunya kegiatan Anda dimulai!' : activity.description,
      scheduledDate: tz.TZDateTime.from(scheduledDate, tz.local),
      notificationDetails: details,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      matchDateTimeComponents: matchComponents,
      payload: jsonEncode({
        'id': activity.id,
        'title': activity.title,
        'body': activity.description.isEmpty ? 'Waktunya kegiatan Anda dimulai!' : activity.description,
        'snoozeMinutes': activity.snoozeMinutes,
      }),
    );

    // Schedule pre-alert if enabled
    if (activity.preAlertMinutes > 0) {
      final preAlertDate = scheduledDate.subtract(Duration(minutes: activity.preAlertMinutes));
      
      // Only schedule if the pre-alert is in the future
      if (preAlertDate.isAfter(now) || activity.recurrenceRule != null) {
        await flutterLocalNotificationsPlugin.zonedSchedule(
          id: (activity.id ?? 0) + 10000, // Unique ID for pre-alert
          title: 'Pengingat: ${activity.title}',
          body: '${activity.preAlertMinutes} menit menuju jadwal Anda.',
          scheduledDate: tz.TZDateTime.from(preAlertDate, tz.local),
          notificationDetails: details,
          androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
          matchDateTimeComponents: matchComponents,
        );
      }
    }
  }

  Future<void> cancelNotification(int id) async {
    await flutterLocalNotificationsPlugin.cancel(id: id);
    await flutterLocalNotificationsPlugin.cancel(id: id + 10000);
    await flutterLocalNotificationsPlugin.cancel(id: id + 20000); // Also cancel potential snooze
  }

  void _handleSnooze(String payload) async {
    try {
      final data = jsonDecode(payload);
      final int id = data['id'];
      final String title = data['title'];
      final String body = data['body'];
      final int snoozeMinutes = data['snoozeMinutes'] ?? 5;

      final snoozeTime = tz.TZDateTime.now(tz.local).add(Duration(minutes: snoozeMinutes));

      // Re-use alarm settings for snooze
      final androidDetails = AndroidNotificationDetails(
        'pace_activity_channel',
        'Pace Activity Alerts',
        channelDescription: 'Main channel for Pace activity alarms',
        importance: Importance.max,
        priority: Priority.max,
        fullScreenIntent: true,
        category: AndroidNotificationCategory.alarm,
        audioAttributesUsage: AudioAttributesUsage.alarm,
        ticker: 'Pace Alarm',
        actions: [
          const AndroidNotificationAction(
            'snooze_action',
            'Snooze',
            showsUserInterface: false,
            cancelNotification: true,
          ),
        ],
      );

      const iosDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
        interruptionLevel: InterruptionLevel.critical,
      );

      final details = NotificationDetails(android: androidDetails, iOS: iosDetails);

      await flutterLocalNotificationsPlugin.zonedSchedule(
        id: id + 20000, // Unique ID for snoozed notification
        title: '$title (Snooze)',
        body: body,
        scheduledDate: snoozeTime,
        notificationDetails: details,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        payload: payload, // Keep payload for further snoozing
      );
    } catch (e) {
      debugPrint('Error handling snooze: $e');
    }
  }
}
