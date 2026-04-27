import 'dart:async';
import 'package:alarm/alarm.dart';
import 'package:flutter/foundation.dart';

class AlarmService {
  static final AlarmService _instance = AlarmService._internal();
  factory AlarmService() => _instance;
  AlarmService._internal();

  /// Inisialisasi plugin Alarm. Wajib dipanggil di main()
  Future<void> init() async {
    await Alarm.init();
    
    // Listening ke event alarm (opsional)
    Alarm.ringStream.stream.listen((alarmSettings) {
      debugPrint("Alarm berbunyi: ${alarmSettings.id}");
    });
  }

  /// Menjadwalkan alarm agresif
  /// [id]: ID unik untuk alarm
  /// [dateTime]: Kapan alarm akan berbunyi
  /// [assetAudioPath]: Path ke file audio di folder assets (misal: 'assets/audio/alarm.mp3')
  /// [label]: Judul yang muncul di notifikasi
  /// [body]: Pesan yang muncul di notifikasi
  Future<void> scheduleAlarm({
    required int id,
    required DateTime dateTime,
    required String assetAudioPath,
    String label = 'Alarm Pace',
    String body = 'Waktunya bangun dan beraktivitas!',
    bool loopAudio = true,
    bool vibrate = true,
    double volume = 1.0,
    bool fadeDuration = true,
  }) async {
    final alarmSettings = AlarmSettings(
      id: id,
      dateTime: dateTime,
      assetAudioPath: assetAudioPath,
      loopAudio: loopAudio,
      vibrate: vibrate,
      volume: volume,
      fadeDuration: fadeDuration ? 3.0 : 0.0, // Suara membesar perlahan selama 3 detik
      notificationTitle: label,
      notificationBody: body,
      enableNotificationOnKill: true, // PENTING: Tetap bunyi meski app di-kill
      stopOnTerminate: false, // PENTING: Tetap jalan meski app di-kill
      androidFullScreenIntent: true, // Membangunkan layar dan muncul full screen
    );

    await Alarm.set(alarmSettings: alarmSettings);
    debugPrint("Alarm dijadwalkan pada: $dateTime");
  }

  /// Menghentikan alarm tertentu
  Future<void> stopAlarm(int id) async {
    await Alarm.stop(id);
    debugPrint("Alarm $id dihentikan.");
  }

  /// Menghentikan semua alarm yang sedang berjalan
  Future<void> stopAll() async {
    final alarms = Alarm.getAlarms();
    for (final alarm in alarms) {
      await Alarm.stop(alarm.id);
    }
  }

  /// Mengecek apakah ada alarm yang sedang berbunyi
  bool isRinging(int id) {
    return Alarm.isRinging(id);
  }
}
