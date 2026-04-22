# Pace 🏃‍♂️

**Pace** adalah aplikasi penjadwalan kegiatan dan alarm pribadi yang dirancang dengan antarmuka modern, premium, dan intuitif. Aplikasi ini membantu Anda mengelola rutinitas harian dengan pengingat cerdas dan manajemen state yang responsif.

## ✨ Fitur Utama

-   **Manajemen Kegiatan**: Tambah, edit, dan hapus jadwal kegiatan harian Anda dengan mudah.
-   **Alarm & Notifikasi Cerdas**: Pengingat otomatis untuk setiap kegiatan yang dijadwalkan menggunakan `flutter_local_notifications`.
-   **Penyimpanan Lokal Persisten**: Menggunakan SQLite (`sqflite`) untuk memastikan data Anda aman dan tersedia bahkan tanpa koneksi internet.
-   **Dashboard Dinamis**: Tampilan ringkasan kegiatan mendatang dengan desain *glassmorphism* yang elegan.
-   **State Management Modern**: Dibangun di atas `flutter_riverpod` untuk performa yang cepat dan sinkronisasi data yang mulus.

## 🚀 Teknologi yang Digunakan

-   **Framework**: Flutter
-   **Bahasa**: Dart
-   **State Management**: Riverpod
-   **Database**: SQLite (sqflite)
-   **Notifications**: Flutter Local Notifications
-   **Styling**: Custom Theme dengan Glassmorphism Effects

## 🛠️ Persiapan & Instalasi

1.  **Clone Repositori**
    ```bash
    git clone https://github.com/DannyPrihandoko/Pace.git
    ```

2.  **Instal Dependensi**
    ```bash
    flutter pub get
    ```

3.  **Jalankan Aplikasi**
    ```bash
    flutter run
    ```

## 📱 Struktur Project

-   `lib/models/`: Definisi model data (Activity).
-   `lib/services/`: Layanan untuk Database dan Notifikasi.
-   `lib/providers/`: State management menggunakan Riverpod.
-   `lib/screens/`: Antarmuka pengguna (Dashboard, Editor).
-   `lib/theme/`: Konfigurasi warna dan tema aplikasi.

---
Dikembangkan dengan ❤️ oleh **Danny Prihandoko**.