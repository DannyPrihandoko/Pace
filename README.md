# Pace 🏃‍♂️

**Pace** adalah aplikasi penjadwalan kegiatan dan alarm pribadi yang dirancang dengan antarmuka modern, premium, dan intuitif. Aplikasi ini membantu Anda mengelola rutinitas harian dengan pengingat cerdas, manajemen jadwal yang fleksibel, dan fitur berbagi jadwal yang inovatif.

Aplikasi ini dirancang dengan memprioritaskan prinsip **usabilitas ISO 9241** dan estetika desain kontemporer.

## ✨ Fitur Utama

-   **Manajemen Kegiatan Lanjutan**: 
    -   **Kategori & Label Berwarna**: Organisasi jadwal dengan sistem *color-coding* yang *vibrant* dan *playful* (Kerja, Pribadi, Rapat, Kesehatan, dll).
    -   **Penjadwalan Berulang (Recurrence)**: Atur kegiatan rutin harian, mingguan, atau bulanan.
-   **Dashboard & UX Premium**:
    -   **Dynamic Greeting**: Sapaan dinamis berdasarkan waktu.
    -   **Glassmorphism Card**: Visualisasi kegiatan mendatang yang elegan.
-   **Widget Layar Utama (Home Widget)**:
    -   **Upcoming 2x1 Widget**: Pantau jadwal langsung dari layar utama dengan tata letak kotak ikon yang rapi.
    -   **Smart Filter**: Widget secara otomatis hanya menampilkan kegiatan yang akan datang.
-   **Alarm & Notifikasi Cerdas**: 
    -   **Pre-Activity Alerts**: Pilihan pengingat 10, 15, atau 30 menit sebelum jadwal dimulai.
    -   **Full-Screen Alarm**: Notifikasi prioritas tinggi yang muncul sebagai *full-screen intent*.
-   **Sharing & Collaboration**: QR-based sharing untuk berbagi dan mengadopsi jadwal teman secara instan.

## 📖 Panduan Penggunaan

### 1. Menambah & Mengelola Jadwal
- Buka aplikasi dan ketuk tombol **+** di pojok kanan bawah.
- Masukkan judul, deskripsi, tanggal, dan waktu kegiatan.
- Aktifkan **Alarm** jika Anda ingin menerima notifikasi saat waktu kegiatan tiba.
- Pilih **Pengingat Pra-Kegiatan** (10/15/30 menit) jika Anda ingin diingatkan sebelum waktu kegiatan dimulai.
- Ketuk **Simpan** dan Anda akan diarahkan kembali ke Dashboard setelah melihat konfirmasi sukses.

### 2. Mengatur Kegiatan Berulang
- Pada layar "Tambah/Edit Kegiatan", temukan opsi **Pengulangan**.
- Pilih frekuensi yang diinginkan:
    - **Setiap Hari**: Untuk rutinitas harian.
    - **Setiap Minggu**: Mengulang pada hari yang sama setiap minggu.
    - **Setiap Bulan**: Mengulang pada tanggal yang sama setiap bulan.

### 3. Berbagi Jadwal (QR Sharing)
- Buka tab **Profil** di menu navigasi bawah.
- Di sana, Anda akan melihat kode QR yang berisi jadwal Anda untuk **hari ini**.
- Minta teman Anda untuk membuka tab **Profil** mereka dan mengetuk tombol **Scan & Adopt Jadwal**.
- Setelah menscan kode Anda, mereka dapat meninjau dan mengimpor jadwal Anda ke daftar mereka sendiri.

### 4. Menavigasi Tampilan
- **Dashboard**: Melihat ringkasan kegiatan hari ini dan kegiatan mendatangkan terdekat.
- **Kalender**: Melihat jadwal dalam format kalender mingguan/bulanan.
- **Profil**: Mengelola identitas dan berbagi jadwal.

## 🚀 Teknologi yang Digunakan

-   **Framework**: Flutter (Dart)
-   **State Management**: `flutter_riverpod`
-   **Database**: SQLite (`sqflite`) untuk penyimpanan luring permanen.
-   **Notifications**: `flutter_local_notifications`
-   **UI/Typography**: `google_fonts` (Plus Jakarta Sans) & Custom Design System.
-   **Utilitas QR**: `mobile_scanner` & `qr_flutter`.

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

-   `lib/models/`: Definisi model data (`Activity`, `UserProfile`).
-   `lib/services/`: Logika sistem (`DatabaseService`, `NotificationService`).
-   `lib/providers/`: State management & business logic (`ActivityProvider`, `UserProvider`).
-   `lib/screens/`: Layar aplikasi (Dashboard, Calendar, Editor, Profile, Scanner).
-   `lib/theme/`: Sistem warna, tipografi, dan tema aplikasi.

---
Dikembangkan dengan ❤️ untuk membantu Anda menguasai waktu.