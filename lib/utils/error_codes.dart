/// Standardized Error Codes for Pace App
/// Format: ERR-[CATEGORY]-[CODE]
class AppErrorCodes {
  // Database Errors
  static const String dbInsertFailed = 'ERR-DB-01'; // Gagal memasukkan data
  static const String dbUpdateFailed = 'ERR-DB-02'; // Gagal memperbarui data
  static const String dbDeleteFailed = 'ERR-DB-03'; // Gagal menghapus data
  static const String dbStorageFull = 'ERR-DB-04'; // Penyimpanan penuh

  // Notification & Alarm Errors
  static const String notifPermissionDenied = 'ERR-NOTIF-01'; // Izin notifikasi ditolak
  static const String alarmPermissionDenied = 'ERR-ALARM-01'; // Izin alarm tepat waktu ditolak
  static const String alarmScheduleFailed = 'ERR-ALARM-02'; // Gagal menjadwalkan alarm

  // Validation Errors
  static const String valInvalidInput = 'ERR-VAL-01'; // Input tidak valid
  static const String valConflict = 'ERR-VAL-02'; // Jadwal bentrok

  // General Errors
  static const String unknown = 'ERR-GEN-01'; // Error tidak dikenal

  /// Helper to get user-friendly message based on error code
  static String getMessage(String code) {
    switch (code) {
      case dbInsertFailed:
        return 'Gagal menyimpan data ke database.';
      case dbStorageFull:
        return 'Penyimpanan perangkat Anda penuh. Silakan hapus beberapa data.';
      case notifPermissionDenied:
        return 'Izin notifikasi diperlukan untuk menjalankan fitur ini.';
      case alarmPermissionDenied:
        return 'Aplikasi memerlukan izin "Exact Alarm" untuk berfungsi dengan benar.';
      case valConflict:
        return 'Jadwal yang Anda pilih bentrok dengan kegiatan lain.';
      default:
        return 'Terjadi kesalahan sistem yang tidak terduga.';
    }
  }
}
