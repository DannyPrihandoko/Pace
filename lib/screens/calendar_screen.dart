import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import '../models/activity.dart';
import '../providers/activity_provider.dart';
import '../theme/colors.dart';
import 'edit_activity_screen.dart';

class CalendarScreen extends ConsumerWidget {
  const CalendarScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activities = ref.watch(activityProvider);
    final dataSource = ActivityDataSource(activities);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Jadwal Kalender'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Theme.of(context).brightness == Brightness.dark 
            ? AppColors.white 
            : AppColors.textDark,
      ),
      body: SfCalendar(
        key: ValueKey(activities.hashCode), // Force refresh when data changes
        view: CalendarView.week,
        allowedViews: const [CalendarView.day, CalendarView.week, CalendarView.month],
        firstDayOfWeek: 1,
        dataSource: dataSource,
        allowDragAndDrop: true,
        appointmentTextStyle: const TextStyle(
          color: AppColors.white,
          fontWeight: FontWeight.w600,
          fontSize: 12,
        ),
        headerStyle: CalendarHeaderStyle(
          textStyle: TextStyle(
            color: Theme.of(context).brightness == Brightness.dark 
                ? AppColors.white 
                : AppColors.textDark,
            fontWeight: FontWeight.bold,
          ),
        ),
        viewHeaderStyle: ViewHeaderStyle(
          dayTextStyle: TextStyle(
              color: Theme.of(context).brightness == Brightness.dark 
                  ? AppColors.white 
                  : AppColors.textDark, 
              fontWeight: FontWeight.bold),
          dateTextStyle: TextStyle(
              color: Theme.of(context).brightness == Brightness.dark 
                  ? AppColors.white 
                  : AppColors.textDark, 
              fontWeight: FontWeight.bold),
        ),
        timeSlotViewSettings: const TimeSlotViewSettings(
          startHour: 0,
          endHour: 24,
          timeTextStyle: TextStyle(color: AppColors.textMuted),
        ),
        onDragEnd: (AppointmentDragEndDetails details) {
          final dynamic appointment = details.appointment;
          final DateTime? droppingTime = details.droppingTime;
          
          if (appointment is Activity && droppingTime != null) {
            ref.read(activityProvider.notifier).rescheduleActivity(appointment, droppingTime);
          } else if (appointment is List && appointment.isNotEmpty && droppingTime != null) {
             final first = appointment.first;
             if (first is Activity) {
                ref.read(activityProvider.notifier).rescheduleActivity(first, droppingTime);
             }
          }
        },
        onTap: (CalendarTapDetails details) {
          if (details.targetElement == CalendarElement.appointment) {
            final Activity activity = details.appointments!.first as Activity;
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => EditActivityScreen(activity: activity)),
            );
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const EditActivityScreen()),
          );
        },
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add, color: AppColors.white), // Bright on CTA
      ),
    );
  }
}

class ActivityDataSource extends CalendarDataSource {
  ActivityDataSource(List<Activity> source) {
    appointments = source;
  }

  @override
  DateTime getStartTime(int index) {
    return _getEventData(index).startTime;
  }

  @override
  DateTime getEndTime(int index) {
    return _getEventData(index).endTime;
  }

  @override
  String getSubject(int index) {
    return _getEventData(index).title;
  }

  @override
  Color getColor(int index) {
    final activity = _getEventData(index);
    if (!activity.isAlarmEnabled) return AppColors.textMuted.withOpacity(0.3);
    
    // Pick color based on ID or index
    final colorIndex = (activity.id ?? index) % AppColors.activityColors.length;
    return AppColors.activityColors[colorIndex];
  }

  @override
  bool isAllDay(int index) {
    return false;
  }

  Activity _getEventData(int index) {
    final dynamic event = appointments![index];
    return event as Activity;
  }
}
