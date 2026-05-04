import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/colors.dart';
import '../providers/activity_provider.dart';
import '../models/activity.dart';
import '../widgets/schedule_item_card.dart';
import 'edit_activity_screen.dart';
import 'ai_chat_screen.dart';
import '../widgets/mood_card.dart';
import '../providers/mood_provider.dart';

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
    "Kesuksesan adalah kumpulan usaha kecil yang diulang setiap hari."
  ];

  String _getDailyQuote() {
    final day = DateTime.now().day;
    return _quotes[day % _quotes.length];
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Selamat Pagi';
    if (hour < 15) return 'Selamat Siang';
    if (hour < 18) return 'Selamat Sore';
    return 'Selamat Malam';
  }

  Future<void> _onRefresh() async {
    await ref.read(activityProvider.notifier).loadActivities();
    await ref.read(moodProvider.notifier).loadTodayMood();
  }

  @override
  Widget build(BuildContext context) {
    final activities = ref.watch(todayActivitiesProvider);
    final completedActivities = activities.where((a) => a.isCompleted).length;
    final totalActivities = activities.length;
    final progress = totalActivities > 0 ? completedActivities / totalActivities : 0.0;
    
    final priorityTasks = activities.where((a) => !a.isCompleted).take(3).toList();
    
    final sleepActivity = activities.firstWhere(
      (a) => a.title.toLowerCase().contains('tidur') || a.title.toLowerCase().contains('sleep') || a.category == 'Kesehatan',
      orElse: () => Activity(
        title: 'Waktu Tidur Ideal',
        description: 'Tidur 8 jam sangat baik untuk kesehatan',
        time: const TimeOfDay(hour: 22, minute: 0),
        date: DateTime.now().toIso8601String().split('T')[0],
        category: 'Kesehatan',
      ),
    );

    // 2D Flat Color Palette
    const black = Colors.black;
    const accentBlue = Color(0xFF3B82F6);
    const pastelYellow = Color(0xFFFEF08A);
    const pastelGreen = Color(0xFFD1FAE5);
    const bgWhite = Colors.white;

    return Scaffold(
      backgroundColor: bgWhite,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _onRefresh,
          color: black,
          backgroundColor: pastelYellow,
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
            slivers: [
              // 1. Combined Header & AI Quote (Big Solid Contrast Box)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20.0, 24.0, 20.0, 16.0),
                  child: Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: accentBlue,
                      borderRadius: BorderRadius.circular(8), // Sharp corners
                      border: Border.all(color: black, width: 3.0), // Hard borders
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _getGreeting().toUpperCase(),
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w900,
                                    color: black,
                                    letterSpacing: 2.0,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Siap Beraksi?',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 24,
                                    fontWeight: FontWeight.w900,
                                    color: bgWhite,
                                  ),
                                ),
                              ],
                            ),
                            // AI Chat Button Flat
                            Container(
                              decoration: BoxDecoration(
                                color: pastelYellow,
                                border: Border.all(color: black, width: 2.0),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: IconButton(
                                onPressed: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (context) => const AiChatScreen()),
                                ),
                                icon: const Icon(Icons.auto_awesome, color: black),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        // Quote Section inside the Header
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: bgWhite,
                            border: Border.all(color: black, width: 2.0),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Icon(Icons.format_quote_rounded, color: black, size: 28),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'AI Insight',
                                      style: GoogleFonts.plusJakartaSans(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w900,
                                        color: black,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      _getDailyQuote(),
                                      style: GoogleFonts.plusJakartaSans(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w700,
                                        color: black.withOpacity(0.8),
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

              // Mood Question
              const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
                  child: MoodCard(),
                ),
              ),

              // 2. Progress Bar
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: pastelYellow,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: black, width: 3.0),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Progress Hari Ini',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 16,
                                fontWeight: FontWeight.w900,
                                color: black,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: bgWhite,
                                border: Border.all(color: black, width: 2.0),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                '$completedActivities/$totalActivities Selesai',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w900,
                                  color: black,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        // 2D Flat Progress Bar Implementation
                        Container(
                          height: 20,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: bgWhite,
                            border: Border.all(color: black, width: 2.0),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          alignment: Alignment.centerLeft,
                          child: FractionallySizedBox(
                            widthFactor: progress,
                            child: Container(
                              decoration: BoxDecoration(
                                color: black, // Solid fill
                                border: progress > 0 && progress < 1.0 
                                    ? const Border(right: BorderSide(color: black, width: 2.0)) 
                                    : null,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // 3. Sleep Schedule Card
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
                  child: _buildSleepCard(context, sleepActivity),
                ),
              ),

              // Priority Tasks Header
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20.0, 24.0, 20.0, 16.0),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: black,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Icon(Icons.star, color: bgWhite, size: 16),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Tugas Prioritas',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                          color: black,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // 4. Priority Tasks List or Empty State Placeholder
              if (priorityTasks.isEmpty)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
                    child: Container(
                      padding: const EdgeInsets.all(32),
                      decoration: BoxDecoration(
                        color: Colors.grey[200], // Neutral background for empty
                        border: Border.all(color: black, width: 3.0),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Custom 2D Flat Illustration Placeholder
                          Container(
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              color: pastelGreen,
                              border: Border.all(color: black, width: 3.0),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                Positioned(
                                  top: 16,
                                  child: Container(width: 40, height: 4, color: black),
                                ),
                                Positioned(
                                  top: 28,
                                  child: Container(width: 40, height: 4, color: black),
                                ),
                                Positioned(
                                  top: 40,
                                  child: Container(width: 20, height: 4, color: black),
                                ),
                                const Positioned(
                                  bottom: 12,
                                  right: 12,
                                  child: Icon(Icons.check_box, color: black, size: 28),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 24),
                          Text(
                            'KOSONG!',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 20,
                              fontWeight: FontWeight.w900,
                              color: black,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Semua prioritas sudah selesai. Santai dulu bos!',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: black.withOpacity(0.7),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        // Assuming ScheduleItemCard supports the flat aesthetic or will be refactored too
                        return ScheduleItemCard(activity: priorityTasks[index]);
                      },
                      childCount: priorityTasks.length,
                    ),
                  ),
                ),

              const SliverToBoxAdapter(child: SizedBox(height: 100)),
            ],
          ),
        ),
      ),
      
      // 5. Flat Floating Action Button
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const EditActivityScreen()),
          );
        },
        backgroundColor: pastelYellow,
        elevation: 0, // No shadow
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(4), // Flat box shape
          side: const BorderSide(color: black, width: 3.0), // Hard border
        ),
        child: const Icon(Icons.add, color: black, size: 32),
      ),
    );
  }

  Widget _buildSleepCard(BuildContext context, Activity sleepActivity) {
    const black = Colors.black;
    const pastelBlue = Color(0xFFBFDBFE); // Blue 200
    const bgWhite = Colors.white;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: pastelBlue,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: black, width: 3.0),
      ),
      child: Stack(
        children: [
          // Flat geometric decoration replacing the old soft gradient circle
          Positioned(
            right: -10,
            top: -10,
            child: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: bgWhite.withOpacity(0.4),
                border: Border.all(color: black, width: 2.0),
                shape: BoxShape.circle, // Sharp circled line
              ),
            ),
          ),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: bgWhite,
                  border: Border.all(color: black, width: 2.0),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Icon(Icons.nights_stay, color: black, size: 28),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'JADWAL TIDUR',
                      style: GoogleFonts.plusJakartaSans(
                        color: black,
                        fontWeight: FontWeight.w900,
                        fontSize: 12,
                        letterSpacing: 2.0,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      sleepActivity.title,
                      style: GoogleFonts.plusJakartaSans(
                        color: black,
                        fontWeight: FontWeight.w900,
                        fontSize: 20,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      sleepActivity.time.format(context),
                      style: GoogleFonts.plusJakartaSans(
                        color: black.withOpacity(0.8),
                        fontWeight: FontWeight.w800,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
