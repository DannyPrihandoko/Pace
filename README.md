# Pace 🏃‍♂️

**Pace** adalah aplikasi penjadwalan kegiatan dan alarm pribadi yang dirancang dengan antarmuka modern, premium, dan intuitif. Aplikasi ini membantu Anda mengelola rutinitas harian dengan pengingat cerdas, manajemen jadwal yang fleksibel, dan fitur berbagi jadwal yang inovatif.

Aplikasi ini dirancang dengan memprioritaskan prinsip **usabilitas ISO 9241** dan estetika desain kontemporer.

## ✨ Fitur Utama

-   **Manajemen Kegiatan Lanjutan**: 
    -   Tambah, edit, dan hapus jadwal dengan alur kerja yang mulus.
    -   **Penjadwalan Berulang (Recurrence)**: Atur kegiatan rutin harian, mingguan, atau bulanan.
    -   **Swipe to Delete**: Hapus kegiatan dengan gesekan jari yang dilengkapi dialog konfirmasi keamanan.
-   **Dashboard & UX Premium**:
    -   **Dynamic Greeting**: Sapaan dinamis berdasarkan waktu (Pagi/Siang/Sore/Malam).
    -   **Glassmorphism Card**: Visualisasi kegiatan mendatang yang elegan dengan efek kaca transparan.
    -   **Success Modals**: Animasi konfirmasi sukses setelah menambah atau memperbarui jadwal.
-   **Kalender Interaktif**: Tampilan mingguan dan bulanan yang terintegrasi dengan `syncfusion_flutter_calendar`.
-   **Sharing & Collaboration**:
    -   **Profil Pengguna**: Identitas unik untuk setiap perangkat.
    -   **QR-Based Sharing**: Bagikan jadwal hari ini hanya dengan scan kode QR (peer-to-peer).
    -   **Adopt Schedule**: Impor jadwal teman langsung ke daftar kegiatan Anda sendiri.
-   **Alarm & Notifikasi Cerdas**: Pengingat otomatis yang presisi untuk setiap kegiatan, mendukung pengulangan berkala.

## 📖 Panduan Penggunaan

### 1. Menambah & Mengelola Jadwal
- Buka aplikasi dan ketuk tombol **+** di pojok kanan bawah.
- Masukkan judul, deskripsi, tanggal, dan waktu kegiatan.
- Aktifkan **Alarm** jika Anda ingin menerima notifikasi saat waktu kegiatan tiba.
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