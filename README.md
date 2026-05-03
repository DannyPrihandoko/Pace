# Pace 🏃‍♂️

**Pace** adalah aplikasi penjadwalan kegiatan, pembentukan kebiasaan (*habit tracking*), dan pelacak keseimbangan hidup pribadi yang dirancang dengan antarmuka **2D Flat Design** yang modern, premium, dan intuitif. Aplikasi ini membantu Anda mengelola rutinitas harian dengan pengingat cerdas, sistem gamifikasi, dan asisten AI personal.

Aplikasi ini dirancang dengan memprioritaskan produktivitas tinggi melalui pendekatan *Offline-First* dan estetika desain kontemporer.

## ✨ Fitur Utama

-   🎨 **2D Flat Design Aesthetic**: Antarmuka bergaya *retro-modern* dengan warna solid tebal, garis *border* hitam tegas, dan tipografi mencolok tanpa elemen bayangan (*shadowless*).
-   🎮 **Gamifikasi Keseimbangan Hidup (Life Spheres)**: Lacak distribusi fokus Anda pada berbagai area hidup (Kesehatan, Karir, Sosial, dll) melalui *Spider Chart Custom 2D* yang bertumbuh setiap kali tugas/habit diselesaikan.
-   🤖 **AI Performance Insight**: *AI Engine* terintegrasi yang mengagregasi rasio penyelesaian habit dan kualitas jadwal tidur (7 hari terakhir) untuk memberikan wawasan, teguran bersahabat, atau apresiasi khusus secara langsung di Dashboard.
-   ☁️ **Arsitektur Sinkronisasi Offline-First**: Aplikasi berfungsi 100% tanpa internet menggunakan sistem antrean (*Queue*) di SQLite. Operasi CRUD (Create, Update, Delete) akan langsung direfleksikan di antarmuka pengguna (*Optimistic UI*) dan disinkronisasikan ke *cloud* secara otomatis di latar belakang saat koneksi internet kembali tersedia.
-   **Manajemen Kegiatan & Habit Lanjutan**: 
    -   Organisasi jadwal dengan warna *vibrant*.
    -   Sistem penjadwalan berulang (*Recurrence*).
    -   Pelacakan durasi tidur (*Sleep Schedule*).
-   **Alarm & Notifikasi Cerdas**: 
    -   *Pre-Activity Alerts* (10/15/30 menit sebelum jadwal).
    -   *Full-Screen Intent* untuk alarm prioritas tinggi.
-   **Sharing & Collaboration**: QR-based sharing untuk berbagi dan mengadopsi jadwal teman secara instan.

## 📖 Panduan Penggunaan

### 1. Menambah & Mengelola Jadwal / Habit
- Buka aplikasi dan gunakan tombol kotak (*Flat Floating Action Button*) di pojok layar.
- Masukkan judul, deskripsi, tanggal, dan waktu kegiatan.
- Anda dapat mengaktifkan **Alarm** *full-screen* atau **Pengingat Pra-Kegiatan**.

### 2. Membangun Keseimbangan Hidup
- Kunjungi tab **Life Spheres** untuk melihat visualisasi distribusi tugas yang telah Anda capai.
- Setiap kali Anda menyelesaikan *Task* atau *Habit*, matriks pada *Sphere* terkait akan bertambah secara dinamis.

### 3. Berbagi Jadwal (QR Sharing)
- Buka tab **Profil** di menu navigasi.
- Tampilkan kode QR jadwal Anda agar dapat dipindai oleh perangkat teman untuk diimpor secara instan.

### 4. Menavigasi Tampilan
- **Dashboard**: Melihat ringkasan kegiatan hari ini, jadwal tidur, indikator progres, dan pesan khusus dari AI.
- **Life Spheres**: Melihat grafik keseimbangan hidup.
- **Kalender**: Memantau jadwal dalam format kalender mingguan/bulanan.

## 🚀 Teknologi yang Digunakan

-   **Framework**: Flutter (Dart)
-   **State Management**: `flutter_riverpod`
-   **Database & Offline Queue**: SQLite (`sqflite`) dengan sinkronisasi `connectivity_plus`
-   **AI Integration**: `google_generative_ai`
-   **Notifications**: `flutter_local_notifications`
-   **UI/Typography**: `google_fonts` (Plus Jakarta Sans) & *Custom 2D Flat Design System*.
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

-   `lib/models/`: Definisi entitas (`Activity`, `Habit`, `Sphere`, `Task`, `SleepSchedule`).
-   `lib/services/`: Logika sistem inti (`DatabaseService`, `SyncService`, `AIEngine`, `AlarmService`).
-   `lib/providers/`: *State management* (`activityProvider`, `gamificationProvider`, `sphereProvider`).
-   `lib/screens/`: Antarmuka halaman utama (Dashboard, Life Spheres, Kalender, dsb).
-   `lib/widgets/`: Komponen UI modular bergaya *2D Flat* (`success_modal.dart`, `habit_card.dart`, dll).

---
Dikembangkan dengan ❤️ untuk membantu Anda menguasai waktu dengan cara yang estetis dan interaktif.