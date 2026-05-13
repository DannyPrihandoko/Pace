import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/sleep_schedule.dart';

final sleepProvider =
    StateNotifierProvider<SleepNotifier, SleepSchedule>((ref) {
  return SleepNotifier();
});

class SleepNotifier extends StateNotifier<SleepSchedule> {
  static const _keyBedHour = 'sleep_bed_hour';
  static const _keyBedMin = 'sleep_bed_min';
  static const _keyWakeHour = 'sleep_wake_hour';
  static const _keyWakeMin = 'sleep_wake_min';
  static const _keyWindDown = 'sleep_wind_down';
  static const _keyWindDownMin = 'sleep_wind_down_min';

  SleepNotifier()
      : super(SleepSchedule(
          bedtime: const TimeOfDay(hour: 22, minute: 0),
          wakeupTime: const TimeOfDay(hour: 6, minute: 0),
        )) {
    _load();
  }

  // ── Persistence ─────────────────────────────────────────────────────────
  Future<void> _load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final bedHour = prefs.getInt(_keyBedHour) ?? 22;
      final bedMin = prefs.getInt(_keyBedMin) ?? 0;
      final wakeHour = prefs.getInt(_keyWakeHour) ?? 6;
      final wakeMin = prefs.getInt(_keyWakeMin) ?? 0;
      final windDown = prefs.getBool(_keyWindDown) ?? false;
      final windDownMin = prefs.getInt(_keyWindDownMin) ?? 30;

      state = SleepSchedule(
        bedtime: TimeOfDay(hour: bedHour, minute: bedMin),
        wakeupTime: TimeOfDay(hour: wakeHour, minute: wakeMin),
        isWindDownEnabled: windDown,
        windDownMinutes: windDownMin,
      );
    } catch (e) {
      debugPrint('[SleepProvider] load error: $e');
    }
  }

  Future<void> _save() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_keyBedHour, state.bedtime.hour);
      await prefs.setInt(_keyBedMin, state.bedtime.minute);
      await prefs.setInt(_keyWakeHour, state.wakeupTime.hour);
      await prefs.setInt(_keyWakeMin, state.wakeupTime.minute);
      await prefs.setBool(_keyWindDown, state.isWindDownEnabled);
      await prefs.setInt(_keyWindDownMin, state.windDownMinutes);
    } catch (e) {
      debugPrint('[SleepProvider] save error: $e');
    }
  }

  // ── Mutators ─────────────────────────────────────────────────────────────
  Future<void> updateBedtime(TimeOfDay time) async {
    state = state.copyWith(bedtime: time);
    await _save();
  }

  Future<void> updateWakeupTime(TimeOfDay time) async {
    state = state.copyWith(wakeupTime: time);
    await _save();
  }

  Future<void> toggleWindDown(bool value) async {
    state = state.copyWith(isWindDownEnabled: value);
    await _save();
  }

  Future<void> updateWindDownMinutes(int minutes) async {
    state = state.copyWith(windDownMinutes: minutes);
    await _save();
  }
}
