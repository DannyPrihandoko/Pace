import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_colors.dart';
import '../providers/activity_provider.dart';
import '../providers/task_provider.dart';
import '../providers/habit_provider.dart';
import '../providers/user_provider.dart';
import '../providers/mood_provider.dart';
import '../models/activity.dart';
import '../widgets/schedule_item_card.dart';
import '../widgets/task_item_card.dart';
import '../widgets/habit_card.dart';
import '../widgets/mood_card.dart';
import 'edit_activity_screen.dart';
import 'ai_chat_screen.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  static const List<String> _quotes = [
    "Satu langkah kecil setiap hari, satu lompatan besar untuk masa depan.",
    "Fokus pada proses, hasilnya akan mengikuti.",
    "Konsistensi adalah kunci dari kesuksesan.",
    "Jadilah lebih baik 1% setiap harinya.",
    "Jangan menunggu sempurna untuk mulai, mulailah untuk menjadi sempurna.",
    "Kesuksesan adalah kumpulan usaha kecil yang diulang setiap hari.",
  ];

  String _getDailyQuote() => _quotes[DateTime.now().day % _quotes.length];

  /// Sapaan dinamis berdasarkan jam + ikon emoji.
  ({String text, String emoji}) _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return (text: 'Selamat Pagi', emoji: '☀️');
    if (hour < 15) return (text: 'Selamat Siang', emoji: '🌤️');
    if (hour < 18) return (text: 'Selamat Sore', emoji: '🌇');
    return (text: 'Selamat Malam', emoji: '🌙');
  }

  Future<void> _onRefresh() async {
    await ref.read(activityProvider.notifier).loadActivities();
    await ref.read(taskProvider.notifier).loadTasks();
    await ref.read(habitProvider.notifier).loadHabits();
    await ref.read(moodProvider.notifier).loadTodayMood();
  }

  @override
  Widget build(BuildContext context) {
    // ── Data dari provider ─────────────────────────────────────────────────
    final activities   = ref.watch(todayActivitiesProvider);
    final tasks        = ref.watch(taskProvider);
    final habits       = ref.watch(habitProvider);
    final user         = ref.watch(userProvider);
    final isDark       = Theme.of(context).brightness == Brightness.dark;
    final colorScheme  = Theme.of(context).colorScheme;

    // Hanya task hari ini
    final today = DateTime.now();
    final todayStr =
        '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';
    final todayTasks   = tasks.where((t) => t.date == todayStr).toList();
    final todayHabits  = habits.where((h) => h.date == todayStr).toList();

    // Progress gabungan (task + habit)
    final totalItems     = todayTasks.length + todayHabits.length;
    final completedItems = todayTasks.where((t) => t.isCompleted).length +
        todayHabits.where((h) => h.isCompleted).length;
    final progress = totalItems > 0 ? completedItems / totalItems : 0.0;

    // Aktivitas prioritas (belum selesai, maks 3)
    final priorityTasks = activities.where((a) => !a.isCompleted).take(3).toList();

    final sleepActivity = activities.firstWhere(
      (a) =>
          a.title.toLowerCase().contains('tidur') ||
          a.title.toLowerCase().contains('sleep') ||
          a.category == 'Kesehatan',
      orElse: () => Activity(
        title: 'Waktu Tidur Ideal',
        description: 'Tidur 8 jam sangat baik untuk kesehatan',
        time: const TimeOfDay(hour: 22, minute: 0),
        date: todayStr,
        category: 'Kesehatan',
      ),
    );

    final greeting = _getGreeting();
    final userName = user?.name ?? 'Kamu';

    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _onRefresh,
          color: AppColors.primary,
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(
                parent: BouncingScrollPhysics()),
            slivers: [
              // ── 1. Greeting Header ──────────────────────────────────────
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
                  child: Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: AppColors.mainGradient,
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withOpacity(0.28),
                          blurRadius: 24,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Baris atas: sapaan + tombol AI
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Label jam
                                  Row(
                                    children: [
                                      Text(
                                        greeting.emoji,
                                        style: const TextStyle(fontSize: 14),
                                      ),
                                      const SizedBox(width: 6),
                                      Text(
                                        greeting.text.toUpperCase(),
                                        style: GoogleFonts.plusJakartaSans(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w800,
                                          color: AppColors.white.withOpacity(0.75),
                                          letterSpacing: 1.8,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 6),
                                  // Nama user
                                  Text(
                                    userName,
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 26,
                                      fontWeight: FontWeight.w900,
                                      color: AppColors.white,
                                      letterSpacing: -0.5,
                                      height: 1.1,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            // Tombol AI Chat
                            Container(
                              decoration: BoxDecoration(
                                color: AppColors.white.withOpacity(0.18),
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: IconButton(
                                onPressed: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (_) => const AiChatScreen()),
                                ),
                                icon: const Icon(
                                  Icons.auto_awesome_rounded,
                                  color: AppColors.white,
                                ),
                                tooltip: 'AI Assistant',
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),

                        // ── Mini Progress Summary ─────────────────────────
                        Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: AppColors.white.withOpacity(0.14),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Progress Hari Ini',
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.white.withOpacity(0.85),
                                    ),
                                  ),
                                  Text(
                                    totalItems > 0
                                        ? '$completedItems/$totalItems selesai'
                                        : 'Belum ada item',
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w800,
                                      color: AppColors.white,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: TweenAnimationBuilder<double>(
                                  tween: Tween(begin: 0, end: progress),
                                  duration: const Duration(milliseconds: 800),
                                  curve: Curves.easeOut,
                                  builder: (_, val, __) =>
                                      LinearProgressIndicator(
                                    value: val,
                                    minHeight: 8,
                                    backgroundColor:
                                        AppColors.white.withOpacity(0.2),
                                    valueColor:
                                        const AlwaysStoppedAnimation<Color>(
                                            AppColors.white),
                                  ),
                                ),
                              ),
                              if (totalItems > 0) ...[
                                const SizedBox(height: 8),
                                Text(
                                  progress >= 1.0
                                      ? '🎉 Semua selesai! Luar biasa!'
                                      : '${(progress * 100).toStringAsFixed(0)}% tercapai — terus semangat!',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.white.withOpacity(0.8),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),

                        // ── AI Quote ──────────────────────────────────────
                        Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: AppColors.white.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Icon(Icons.format_quote_rounded,
                                  color: AppColors.white, size: 20),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'AI INSIGHT',
                                      style: GoogleFonts.plusJakartaSans(
                                        fontSize: 10,
                                        fontWeight: FontWeight.w800,
                                        color: AppColors.white.withOpacity(0.65),
                                        letterSpacing: 1.2,
                                      ),
                                    ),
                                    const SizedBox(height: 3),
                                    Text(
                                      _getDailyQuote(),
                                      style: GoogleFonts.plusJakartaSans(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.white,
                                        height: 1.4,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // ── Mood Card ───────────────────────────────────────────────
              const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 6),
                  child: MoodCard(),
                ),
              ),

              // ── 2. Sleep Card ───────────────────────────────────────────
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
                  child: _buildSleepCard(context, sleepActivity, isDark),
                ),
              ),

              // ── 3. Tugas Hari Ini ───────────────────────────────────────
              SliverToBoxAdapter(
                child: _SectionHeader(
                  icon: Icons.check_circle_outline_rounded,
                  iconColor: AppColors.primary,
                  title: 'Tugas Hari Ini',
                  trailing: todayTasks.isNotEmpty
                      ? '${todayTasks.where((t) => t.isCompleted).length}/${todayTasks.length}'
                      : null,
                ),
              ),

              if (todayTasks.isEmpty)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: _EmptyStateCard(
                      icon: Icons.task_alt_rounded,
                      iconColor: AppColors.primary,
                      title: 'Tidak Ada Tugas',
                      subtitle:
                          'Yeay! Semua tugas hari ini sudah selesai.\nWaktunya bersantai! 🎉',
                    ),
                  ),
                )
              else
                SliverPadding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (ctx, i) => TaskItemCard(
                        task: todayTasks[i],
                        onToggle: () => ref
                            .read(taskProvider.notifier)
                            .toggleTask(todayTasks[i].id),
                      ),
                      childCount: todayTasks.length,
                    ),
                  ),
                ),

              // ── 4. Habit Hari Ini ───────────────────────────────────────
              SliverToBoxAdapter(
                child: _SectionHeader(
                  icon: Icons.local_fire_department_rounded,
                  iconColor: AppColors.warning,
                  title: 'Habit Hari Ini',
                  trailing: todayHabits.isNotEmpty
                      ? '${todayHabits.where((h) => h.isCompleted).length}/${todayHabits.length}'
                      : null,
                ),
              ),

              if (todayHabits.isEmpty)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: _EmptyStateCard(
                      icon: Icons.self_improvement_rounded,
                      iconColor: AppColors.warning,
                      title: 'Tidak Ada Habit',
                      subtitle:
                          'Mulai bangun kebiasaan baik hari ini.\nSatu kebiasaan kecil bisa mengubah segalanya! 💪',
                    ),
                  ),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (ctx, i) => HabitCard(
                        habit: todayHabits[i],
                        onTap: () => ref
                            .read(habitProvider.notifier)
                            .toggleHabit(todayHabits[i].id),
                      ),
                      childCount: todayHabits.length,
                    ),
                  ),
                ),

              // ── 5. Aktivitas Prioritas ──────────────────────────────────
              SliverToBoxAdapter(
                child: _SectionHeader(
                  icon: Icons.star_rounded,
                  iconColor: AppColors.warning,
                  title: 'Aktivitas Prioritas',
                ),
              ),

              if (priorityTasks.isEmpty)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: _EmptyStateCard(
                      icon: Icons.check_circle_outline_rounded,
                      iconColor: AppColors.success,
                      title: 'Semua Beres!',
                      subtitle:
                          'Semua prioritas aktivitas sudah selesai.\nSantai dulu, kamu luar biasa! 😎',
                    ),
                  ),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (ctx, i) => Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: ScheduleItemCard(activity: priorityTasks[i]),
                      ),
                      childCount: priorityTasks.length,
                    ),
                  ),
                ),

              const SliverToBoxAdapter(child: SizedBox(height: 100)),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const EditActivityScreen()),
        ),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.white,
        elevation: 4,
        label: const Text('Tambah'),
        icon: const Icon(Icons.add_rounded),
      ),
    );
  }

  Widget _buildSleepCard(
      BuildContext context, Activity sleep, bool isDark) {
    return Card(
      margin: EdgeInsets.zero,
      elevation: 1,
      shadowColor: AppColors.info.withOpacity(0.08),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: AppColors.info.withOpacity(0.15),
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.info.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child:
                  const Icon(Icons.nights_stay_rounded, color: AppColors.info, size: 26),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'JADWAL TIDUR',
                    style: GoogleFonts.plusJakartaSans(
                      color: isDark
                          ? AppColors.darkTextSecondary
                          : AppColors.lightTextSecondary,
                      fontWeight: FontWeight.w800,
                      fontSize: 10,
                      letterSpacing: 1.5,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    sleep.title,
                    style: GoogleFonts.plusJakartaSans(
                      fontWeight: FontWeight.w800,
                      fontSize: 17,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    sleep.time.format(context),
                    style: GoogleFonts.plusJakartaSans(
                      color: isDark
                          ? AppColors.darkTextSecondary
                          : AppColors.lightTextSecondary,
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Section Header
// ─────────────────────────────────────────────────────────────────────────────
class _SectionHeader extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String? trailing;

  const _SectionHeader({
    required this.icon,
    required this.iconColor,
    required this.title,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 10),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: iconColor, size: 18),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              title,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 18,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          if (trailing != null)
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                trailing!,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  color: iconColor,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Empty State Card — cantik & motivatif
// ─────────────────────────────────────────────────────────────────────────────
class _EmptyStateCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;

  const _EmptyStateCard({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 4),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
      decoration: BoxDecoration(
        color: isDark
            ? AppColors.darkCard.withOpacity(0.6)
            : AppColors.lightCard,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
          width: 1,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 40, color: iconColor.withOpacity(0.8)),
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 16,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: isDark
                  ? AppColors.darkTextSecondary
                  : AppColors.lightTextSecondary,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
