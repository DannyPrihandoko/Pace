import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import '../models/activity.dart';
import '../providers/activity_provider.dart';
import '../theme/colors.dart';
import 'edit_activity_screen.dart';
import '../models/activity_category.dart';

class CalendarScreen extends ConsumerWidget {
  const CalendarScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activities = ref.watch(activityProvider);
    final dataSource = ActivityDataSource(activities);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Kalender'),
      ),
      body: SfCalendar(
        key: ValueKey(activities.hashCode),
        view: CalendarView.month,
        allowedViews: const [CalendarView.month, CalendarView.week, CalendarView.day],
        firstDayOfWeek: 1,
        showNavigationArrow: true,
        monthViewSettings: const MonthViewSettings(
          showAgenda: true,
          agendaItemHeight: 70,
          agendaStyle: AgendaStyle(
            appointmentTextStyle: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
        dataSource: dataSource,
        allowDragAndDrop: false,
        headerHeight: 64,
        todayHighlightColor: AppColors.primary,
        selectionDecoration: BoxDecoration(
          color: AppColors.primary.withOpacity(0.1),
          border: Border.all(color: AppColors.primary, width: 2),
          borderRadius: BorderRadius.circular(12),
        ),
        appointmentTextStyle: GoogleFonts.plusJakartaSans(
          color: AppColors.white,
          fontWeight: FontWeight.w700,
          fontSize: 11,
        ),
        headerStyle: CalendarHeaderStyle(
          textAlign: TextAlign.center,
          textStyle: GoogleFonts.plusJakartaSans(
            color: isDark ? AppColors.white : AppColors.textDark,
            fontWeight: FontWeight.w800,
            fontSize: 18,
          ),
        ),
        viewHeaderStyle: ViewHeaderStyle(
          dayTextStyle: GoogleFonts.plusJakartaSans(
              color: isDark ? AppColors.white.withOpacity(0.7) : AppColors.textMuted, 
              fontWeight: FontWeight.w700,
              fontSize: 12),
          dateTextStyle: GoogleFonts.plusJakartaSans(
              color: isDark ? AppColors.white : AppColors.textDark, 
              fontWeight: FontWeight.w800,
              fontSize: 16),
        ),
        timeSlotViewSettings: TimeSlotViewSettings(
          startHour: 4,
          endHour: 24,
          timeTextStyle: GoogleFonts.plusJakartaSans(
            color: isDark ? AppColors.darkTextSecondary : AppColors.textMuted,
            fontSize: 11,
            fontWeight: FontWeight.w600,
          ),
        ),
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
      floatingActionButton: FloatingActionButton.large(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const EditActivityScreen()),
          );
        },
        backgroundColor: AppColors.primary,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: const Icon(Icons.add_rounded, color: AppColors.white, size: 32),
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
    if (!activity.isAlarmEnabled) {
      return AppColors.textMuted.withOpacity(0.3);
    }
    
    return ActivityCategory.fromName(activity.category).color;
  }

  @override
  bool isAllDay(int index) {
    return false;
  }

  @override
  String? getRecurrenceRule(int index) {
    return _getEventData(index).recurrenceRule;
  }

  Activity _getEventData(int index) {
    final dynamic event = appointments![index];
    return event as Activity;
  }
}
