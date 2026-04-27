import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/sleep_schedule.dart';

class SleepNotifier extends StateNotifier<SleepSchedule> {
  SleepNotifier() : super(SleepSchedule(
    bedtime: const TimeOfDay(hour: 22, minute: 0),
    wakeupTime: const TimeOfDay(hour: 6, minute: 0),
  ));

  void updateBedtime(TimeOfDay time) {
    state = state.copyWith(bedtime: time);
  }

  void updateWakeupTime(TimeOfDay time) {
    state = state.copyWith(wakeupTime: time);
  }

  void toggleWindDown(bool value) {
    state = state.copyWith(isWindDownEnabled: value);
  }
}

final sleepProvider = StateNotifierProvider<SleepNotifier, SleepSchedule>((ref) {
  return SleepNotifier();
});
