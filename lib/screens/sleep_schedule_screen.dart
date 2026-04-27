import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:progressive_time_picker/progressive_time_picker.dart';
import '../providers/sleep_provider.dart';
import '../models/sleep_schedule.dart';

class SleepScheduleScreen extends ConsumerWidget {
  const SleepScheduleScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final schedule = ref.watch(sleepProvider);
    
    // Theme Colors
    const Color navyBg = Color(0xFF0F172A);
    const Color softBlue = Color(0xFF3B82F6);
    const Color pastelYellow = Color(0xFFFEF08A);
    const Color borderColor = Color(0xFF1E293B);

    // Prepare time picker data
    final PickedTime initBedtime = PickedTime(h: schedule.bedtime.hour, m: schedule.bedtime.minute);
    final PickedTime initWakeup = PickedTime(h: schedule.wakeupTime.hour, m: schedule.wakeupTime.minute);

    final double durationHours = schedule.calculateDuration();

    return Scaffold(
      backgroundColor: navyBg,
      appBar: AppBar(
        title: Text(
          'Jadwal Tidur',
          style: GoogleFonts.plusJakartaSans(
            fontWeight: FontWeight.w800,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 20),
            // Circular Time Picker
            Center(
              child: Stack(
                alignment: Alignment.center,
                children: [
                  TimePicker(
                    initTime: initBedtime,
                    endTime: initWakeup,
                    height: 280,
                    width: 280,
                    onSelectionChange: (start, end, valid) {
                      ref.read(sleepProvider.notifier).updateBedtime(TimeOfDay(hour: start.h, minute: start.m));
                      ref.read(sleepProvider.notifier).updateWakeupTime(TimeOfDay(hour: end.h, minute: end.m));
                    },
                    decoration: TimePickerDecoration(
                      baseColor: borderColor,
                      pickerBaseColor: softBlue.withOpacity(0.2),
                      sweepColor: softBlue,
                      accentColor: softBlue,
                      showHandlerOutterRing: false,
                      initHandlerDecoration: TimePickerHandlerDecoration(
                        color: navyBg,
                        shape: BoxShape.circle,
                        icon: const Icon(Icons.bedtime_rounded, color: softBlue, size: 16),
                        border: Border.all(color: softBlue, width: 2),
                      ),
                      endHandlerDecoration: TimePickerHandlerDecoration(
                        color: navyBg,
                        shape: BoxShape.circle,
                        icon: const Icon(Icons.wb_sunny_rounded, color: pastelYellow, size: 16),
                        border: Border.all(color: pastelYellow, width: 2),
                      ),
                    ),
                  ),
                  // Real-time Duration Display
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '${durationHours.floor()}j ${((durationHours - durationHours.floor()) * 60).round()}m',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 32,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        'Durasi Tidur',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 14,
                          color: Colors.white54,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),
            // Time Labels Row
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildTimeInfo('Waktu Tidur', schedule.bedtime, Icons.bedtime_rounded, softBlue),
                  _buildTimeInfo('Waktu Bangun', schedule.wakeupTime, Icons.wb_sunny_rounded, pastelYellow),
                ],
              ),
            ),
            const SizedBox(height: 40),
            // Settings Section
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 24),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: borderColor.withOpacity(0.5),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: borderColor),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: softBlue.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(Icons.spa_rounded, color: softBlue, size: 20),
                          ),
                          const SizedBox(width: 16),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Wind-Down',
                                style: GoogleFonts.plusJakartaSans(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              Text(
                                '${schedule.windDownMinutes} menit persiapan',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 12,
                                  color: Colors.white54,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      Switch(
                        value: schedule.isWindDownEnabled,
                        onChanged: (val) => ref.read(sleepProvider.notifier).toggleWindDown(val),
                        activeColor: softBlue,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            // Weekly Sleep Quality Section
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 24),
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: borderColor.withOpacity(0.3),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: borderColor.withOpacity(0.5)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Ringkasan Mingguan',
                        style: GoogleFonts.plusJakartaSans(
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        '7.4j Rata-rata',
                        style: GoogleFonts.plusJakartaSans(
                          color: softBlue,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  // Weekly Bar Chart (Flat Design)
                  SizedBox(
                    height: 100,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        _buildSleepBar('Sen', 0.8, softBlue),
                        _buildSleepBar('Sel', 0.6, softBlue.withOpacity(0.5)),
                        _buildSleepBar('Rab', 0.9, softBlue),
                        _buildSleepBar('Kam', 0.7, softBlue.withOpacity(0.7)),
                        _buildSleepBar('Jum', 0.85, softBlue),
                        _buildSleepBar('Sab', 0.4, Colors.redAccent.withOpacity(0.6)), // Poor sleep
                        _buildSleepBar('Min', 0.95, softBlue),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }

  Widget _buildSleepBar(String day, double heightFactor, Color color) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Expanded(
          child: Container(
            width: 12,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(4),
            ),
            alignment: Alignment.bottomCenter,
            child: FractionallySizedBox(
              heightFactor: heightFactor,
              child: Container(
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          day,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 10,
            color: Colors.white38,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildTimeInfo(String label, TimeOfDay time, IconData icon, Color color) {
    return Column(
      children: [
        Row(
          children: [
            Icon(icon, color: color, size: 16),
            const SizedBox(width: 8),
            Text(
              label,
              style: GoogleFonts.plusJakartaSans(
                color: Colors.white54,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 24,
            fontWeight: FontWeight.w800,
            color: Colors.white,
          ),
        ),
      ],
    );
  }
}
