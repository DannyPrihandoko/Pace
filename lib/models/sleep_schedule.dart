import 'package:flutter/material.dart';

class SleepSchedule {
  final TimeOfDay bedtime;
  final TimeOfDay wakeupTime;
  final bool isWindDownEnabled;
  final int windDownMinutes;

  SleepSchedule({
    required this.bedtime,
    required this.wakeupTime,
    this.isWindDownEnabled = false,
    this.windDownMinutes = 30,
  });

  SleepSchedule copyWith({
    TimeOfDay? bedtime,
    TimeOfDay? wakeupTime,
    bool? isWindDownEnabled,
    int? windDownMinutes,
  }) {
    return SleepSchedule(
      bedtime: bedtime ?? this.bedtime,
      wakeupTime: wakeupTime ?? this.wakeupTime,
      isWindDownEnabled: isWindDownEnabled ?? this.isWindDownEnabled,
      windDownMinutes: windDownMinutes ?? this.windDownMinutes,
    );
  }

  double calculateDuration() {
    double bedHour = bedtime.hour + bedtime.minute / 60.0;
    double wakeHour = wakeupTime.hour + wakeupTime.minute / 60.0;
    
    if (wakeHour <= bedHour) {
      wakeHour += 24;
    }
    
    return wakeHour - bedHour;
  }
}
