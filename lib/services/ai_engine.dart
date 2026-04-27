import 'dart:math';
import '../models/ai_model.dart';

// ─── Intent Classifier ────────────────────────────────────────────────────────

class IntentClassifier {
  static const Map<AiIntent, List<Pattern>> _rules = {
    AiIntent.greeting: [
      r'\b(halo|hai|hi|hei|selamat pagi|selamat siang|selamat sore|selamat malam|hey|assalamualaikum|permisi)\b',
    ],
    AiIntent.howAreYou: [
      r'\b(apa kabar|gimana kabar|how are you|bagaimana kabarmu)\b',
    ],
    AiIntent.showTodaySchedule: [
      r'\b(jadwal hari ini|agenda hari ini|kegiatan hari ini|apa yang harus saya lakukan|apa agenda|jadwal sekarang)\b',
    ],
    AiIntent.showUpcoming: [
      r'\b(jadwal berikutnya|selanjutnya|next schedule|yang akan datang)\b',
    ],
    AiIntent.checkHabits: [
      r'\b(habit|kebiasaan|rutinitas|habbit|tracking|lacak)\b',
    ],
    AiIntent.checkStreak: [
      r'\b(streak|hari berturut|konsisten|consecutive)\b',
    ],
    AiIntent.sleepAdvice: [
      r'\b(saran tidur|jam tidur|tidur ideal|waktu tidur|rekomendasi tidur|kapan tidur)\b',
    ],
    AiIntent.checkSleepSchedule: [
      r'\b(jadwal tidur|sleep schedule|jam tidur saya|kapan bangun|wind.down)\b',
    ],
    AiIntent.motivation: [
      r'\b(semangat|motivasi|dorongan|inspire|inspirasi|lelah|capek|menyerah)\b',
    ],
    AiIntent.productivityTip: [
      r'\b(tips|produktif|produktivitas|cara|trik|strategi|fokus|kerja efektif)\b',
    ],
    AiIntent.scheduleAdvice: [
      r'\b(saran jadwal|analisis jadwal|evaluasi|sibuk|terlalu banyak|atur jadwal|rekomendasi kegiatan)\b',
    ],
    AiIntent.alarmHelp: [
      r'\b(alarm|bangunkan|set alarm|ingatkan|pengingat)\b',
    ],
    AiIntent.addActivityHelp: [
      r'\b(tambah jadwal|buat jadwal|tambah kegiatan|jadwalkan|new activity|tambah agenda)\b',
    ],
    AiIntent.deleteActivityHelp: [
      r'\b(hapus jadwal|hapus kegiatan|cancel|batalkan|delete)\b',
    ],
    AiIntent.thankYou: [
      r'\b(terima kasih|makasih|thanks|thank you|thx)\b',
    ],
    AiIntent.affirmation: [
      r'\b(oke|ok|baik|siap|ya|yap|mantap|sip|noted)\b',
    ],
  };

  static AiIntent classify(String input) {
    final lower = input.toLowerCase().trim();
    for (final entry in _rules.entries) {
      for (final pattern in entry.value) {
        if (RegExp(pattern.toString()).hasMatch(lower)) {
          return entry.key;
        }
      }
    }
    return AiIntent.unknown;
  }
}

// ─── Response Generator ───────────────────────────────────────────────────────

class ResponseGenerator {
  static final Random _rng = Random();

  static String _pick(List<String> options) =>
      options[_rng.nextInt(options.length)];

  static AiMessage generate(AiIntent intent, AiContext ctx) {
    switch (intent) {
      case AiIntent.greeting:
        return AiMessage.fromAssistant(
          '${ctx.greeting}! 👋 Saya PACE AI, asisten jadwal Anda. Hari ini Anda punya **${ctx.todayActivities.length} kegiatan** dan **${ctx.completedHabits}/${ctx.totalHabits}** habit sudah selesai. Ada yang bisa saya bantu?',
          quickReplies: ['Jadwal hari ini', 'Cek habit saya', 'Tips produktivitas'],
        );

      case AiIntent.howAreYou:
        return AiMessage.fromAssistant(
          _pick([
            'Saya selalu siap membantu! 🤖 Anda bagaimana? Sudah selesaikan ${ctx.completedHabits} dari ${ctx.totalHabits} habit hari ini.',
            'Baik sekali, terima kasih sudah bertanya! 😊 Saya siap membantu mengatur jadwal Anda.',
          ]),
          quickReplies: ['Jadwal hari ini', 'Cek habit saya'],
        );

      case AiIntent.showTodaySchedule:
        if (ctx.todayActivities.isEmpty) {
          return AiMessage.fromAssistant(
            'Tidak ada jadwal untuk hari ini! 🎉 Ini saatnya istirahat atau tambahkan kegiatan baru.',
            quickReplies: ['Tambah jadwal baru', 'Tips produktivitas'],
          );
        }
        final list = ctx.todayActivities
            .map((a) => '• **${a.timeStr}** — ${a.title} (${a.category})')
            .join('\n');
        final upcoming = ctx.upcomingToday;
        final nextInfo = upcoming.isNotEmpty
            ? '\n\n⏰ Kegiatan berikutnya: **${upcoming.first.title}** pukul ${upcoming.first.timeStr}.'
            : '\n\n✅ Semua kegiatan hari ini sudah selesai!';
        return AiMessage.fromAssistant(
          'Ini jadwal Anda hari ini:\n\n$list$nextInfo',
          quickReplies: ['Kegiatan berikutnya', 'Cek habit saya'],
        );

      case AiIntent.showUpcoming:
        final upcoming = ctx.upcomingToday;
        if (upcoming.isEmpty) {
          return AiMessage.fromAssistant(
            '✅ Tidak ada lagi kegiatan tersisa untuk hari ini. Santai dulu!',
            quickReplies: ['Jadwal tidur', 'Tips produktivitas'],
          );
        }
        return AiMessage.fromAssistant(
          '⏭️ Kegiatan berikutnya adalah:\n\n**${upcoming.first.title}**\nPukul: **${upcoming.first.timeStr}**\nKategori: ${upcoming.first.category}',
          quickReplies: ['Lihat semua jadwal', 'Cek habit saya'],
        );

      case AiIntent.checkHabits:
        if (ctx.habits.isEmpty) {
          return AiMessage.fromAssistant(
            'Anda belum memiliki habit apapun. Yuk mulai tambahkan kebiasaan positif! 💪',
            quickReplies: ['Tips produktivitas', 'Jadwal hari ini'],
          );
        }
        final doneList = ctx.habits.where((h) => h.isCompleted).toList();
        final pendingList = ctx.habits.where((h) => !h.isCompleted).toList();

        String response = '**Status Habit Anda** (${ctx.completedHabits}/${ctx.totalHabits} selesai):\n\n';
        if (doneList.isNotEmpty) {
          response += '✅ Selesai:\n';
          response += doneList.map((h) => '• ${h.title}').join('\n');
          response += '\n\n';
        }
        if (pendingList.isNotEmpty) {
          response += '⏳ Belum selesai:\n';
          response += pendingList.map((h) => '• ${h.title}').join('\n');
        }
        return AiMessage.fromAssistant(response,
            quickReplies: ['Lihat streak', 'Jadwal hari ini']);

      case AiIntent.checkStreak:
        if (ctx.habits.isEmpty) {
          return AiMessage.fromAssistant('Belum ada habit untuk dilacak streaknya. 🔥');
        }
        final streakList = ctx.habits
            .where((h) => h.streak > 0)
            .map((h) => '🔥 **${h.streak} hari** — ${h.title}')
            .join('\n');
        final best = ctx.bestStreak;
        return AiMessage.fromAssistant(
          streakList.isNotEmpty
              ? 'Streak terbaik Anda saat ini:\n\n$streakList\n\n🏆 Pertahankan terus! Record terbaik: **$best hari berturut-turut**.'
              : 'Belum ada streak aktif. Mulai hari ini dan jangan putus! 💪',
          quickReplies: ['Cek habit saya', 'Tips produktivitas'],
        );

      case AiIntent.sleepAdvice:
        return AiMessage.fromAssistant(
          '😴 **Panduan Tidur Sehat:**\n\n• Tidur ideal adalah **7–9 jam** per malam\n• Usahakan tidur dan bangun di jam yang **sama setiap hari**\n• Matikan layar **30 menit** sebelum tidur (Wind-Down)\n• Suhu kamar ideal untuk tidur: **18–22°C**\n• Hindari kafein setelah pukul **14:00**',
          quickReplies: ['Lihat jadwal tidur saya', 'Jadwal hari ini'],
        );

      case AiIntent.checkSleepSchedule:
        final sleep = ctx.sleepSchedule;
        if (sleep == null) {
          return AiMessage.fromAssistant(
            'Anda belum mengatur jadwal tidur. Buka menu **Jadwal Tidur** untuk mengaturnya! 🌙',
            quickReplies: ['Saran tidur', 'Jadwal hari ini'],
          );
        }
        final quality = sleep.durationHours >= 7 ? '✅ Ideal' : '⚠️ Kurang dari 7 jam';
        return AiMessage.fromAssistant(
          '🌙 **Jadwal Tidur Anda:**\n\n• Jam Tidur: **${sleep.bedtime}**\n• Jam Bangun: **${sleep.wakeupTime}**\n• Durasi: **${sleep.durationHours.toStringAsFixed(1)} jam** ($quality)\n• Wind-Down: **${sleep.windDownEnabled ? "Aktif" : "Nonaktif"}**',
          quickReplies: ['Saran tidur', 'Jadwal hari ini'],
        );

      case AiIntent.motivation:
        return AiMessage.fromAssistant(
          _pick([
            '💪 "${_pick([
              'Disiplin adalah jembatan antara tujuan dan pencapaian.',
              'Setiap langkah kecil adalah kemajuan. Tetap konsisten!',
              'Anda tidak perlu sempurna, cukup lebih baik dari kemarin.',
              'Habiskan waktu Anda bukan untuk mengeluh, tapi untuk bergerak.',
            ])}"\n\nAnda sudah selesaikan **${ctx.completedHabits} habit** hari ini. Terus lanjutkan! 🔥',
          ]),
          quickReplies: ['Tips produktivitas', 'Jadwal hari ini'],
        );

      case AiIntent.productivityTip:
        return AiMessage.fromAssistant(
          _pick([
            '🧠 **Teknik Pomodoro:** Kerja fokus 25 menit, istirahat 5 menit. Setelah 4 sesi, istirahat panjang 15–30 menit.',
            '📋 **Metode Eat The Frog:** Selesaikan tugas terberat dan terpenting di pagi hari saat energi masih penuh.',
            '📵 **Deep Work:** Matikan semua notifikasi selama 90–120 menit untuk kerja mendalam tanpa gangguan.',
            '📝 **Aturan 2 Menit:** Jika suatu tugas bisa selesai dalam 2 menit, kerjakan sekarang juga.',
          ]),
          quickReplies: ['Motivasi dong', 'Jadwal hari ini'],
        );

      case AiIntent.scheduleAdvice:
        final activities = ctx.todayActivities;
        if (activities.isEmpty) {
          return AiMessage.fromAssistant(
            'Jadwal Anda hari ini masih kosong! 🏖️ Saya sarankan untuk menambahkan setidaknya satu kegiatan produktif dan satu kegiatan untuk diri sendiri (Self-care).',
            quickReplies: ['Cara tambah jadwal', 'Tips produktivitas'],
          );
        }

        List<String> advice = [];
        
        // 1. Crowd check
        if (activities.length > 5) {
          advice.add('• Hari ini Anda cukup sibuk (**${activities.length} kegiatan**). Jangan lupa sisipkan istirahat 15 menit di antara tugas agar tidak burnout.');
        }

        // 2. Category Balance check
        final categories = activities.map((a) => a.category).toSet();
        if (!categories.contains('Kesehatan') && !categories.contains('Pribadi')) {
          advice.add('• Saya melihat belum ada agenda **Kesehatan/Pribadi**. Coba tambahkan waktu untuk olahraga ringan atau meditasi.');
        }

        // 3. Late night check
        final lateTasks = activities.where((a) => a.hour >= 21).toList();
        if (lateTasks.isNotEmpty) {
          advice.add('• Ada kegiatan di atas jam 9 malam (**${lateTasks.first.title}**). Pastikan ini tidak mengganggu waktu tidur ideal Anda.');
        }

        // 4. Gap check (Simple estimation)
        if (activities.length >= 2 && activities.length < 4) {
          advice.add('• Ada cukup banyak waktu luang di antara jadwal. Ini waktu yang tepat untuk melakukan **Deep Work** pada proyek besar Anda.');
        }

        return AiMessage.fromAssistant(
          '📊 **Analisis Jadwal Anda:**\n\n${advice.join('\n\n')}\n\nAda yang ingin Anda sesuaikan?',
          quickReplies: ['Jadwal hari ini', 'Saran tidur'],
        );

      case AiIntent.alarmHelp:
        return AiMessage.fromAssistant(
          '⏰ Untuk mengatur alarm:\n\n1. Buka menu **Edit Kegiatan**\n2. Aktifkan toggle **"Aktifkan Alarm"**\n3. Atur **Pre-Alert** jika ingin diingatkan lebih awal\n4. Pilih **Durasi Snooze** sesuai kebiasaan Anda\n\nAlarm akan berbunyi bahkan saat aplikasi ditutup!',
          quickReplies: ['Jadwal hari ini', 'Cek habit saya'],
        );

      case AiIntent.addActivityHelp:
        return AiMessage.fromAssistant(
          '📅 Untuk menambah jadwal:\n\n1. Tekan tombol **"+"** di halaman utama\n2. Isi **judul** dan **deskripsi** kegiatan\n3. Pilih **tanggal** dan **jam**\n4. Pilih **kategori** (Kerja, Pribadi, dll.)\n5. Atur **alarm** jika perlu\n6. Tekan **Simpan**',
          quickReplies: ['Jadwal hari ini', 'Bantuan alarm'],
        );

      case AiIntent.deleteActivityHelp:
        return AiMessage.fromAssistant(
          '🗑️ Untuk menghapus jadwal:\n\nGeser kartu kegiatan ke kiri, atau buka kegiatan tersebut dan ketuk ikon **Hapus** di pojok kanan atas.',
          quickReplies: ['Jadwal hari ini'],
        );

      case AiIntent.thankYou:
        return AiMessage.fromAssistant(
          _pick([
            'Sama-sama! 😊 Senang bisa membantu Anda.',
            'Dengan senang hati! Ada yang bisa saya bantu lagi?',
            'Tentu! Jangan sungkan untuk bertanya lagi ya. 🤝',
          ]),
          quickReplies: ['Jadwal hari ini', 'Cek habit saya', 'Motivasi dong'],
        );

      case AiIntent.affirmation:
        return AiMessage.fromAssistant(
          _pick([
            'Siap! Hubungi saya kapan saja Anda butuh bantuan. 👍',
            'Oke! Semangat terus ya hari ini! 💪',
          ]),
          quickReplies: ['Jadwal hari ini', 'Cek habit saya'],
        );

      case AiIntent.unknown:
      default:
        return AiMessage.fromAssistant(
          _pick([
            'Hmm, saya kurang paham maksud Anda. 🤔 Coba tanya dengan kata kunci seperti "jadwal hari ini", "cek habit", atau "tips produktivitas".',
            'Maaf, saya belum mengerti pertanyaan itu. Saya bisa membantu dengan jadwal, habit, alarm, atau tips produktivitas. 😊',
          ]),
          quickReplies: ['Jadwal hari ini', 'Cek habit saya', 'Tips produktivitas', 'Motivasi dong'],
        );
    }
  }
}
