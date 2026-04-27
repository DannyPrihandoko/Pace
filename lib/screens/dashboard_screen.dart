import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/colors.dart';
import '../providers/activity_provider.dart';
import '../models/activity.dart';
import '../widgets/schedule_item_card.dart';
import 'edit_activity_screen.dart';
import 'ai_chat_screen.dart';
import '../models/activity_category.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Selamat Pagi';
    if (hour < 15) return 'Selamat Siang';
    if (hour < 18) return 'Selamat Sore';
    return 'Selamat Malam';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activities = ref.watch(todayActivitiesProvider);
    final upcomingActivity = activities.isNotEmpty ? activities.first : null;

    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24.0, 32.0, 24.0, 32.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          _getGreeting(),
                          style: Theme.of(context).textTheme.headlineMedium,
                        ),
                        IconButton(
                          onPressed: () => Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const AiChatScreen()),
                          ),
                          icon: const Icon(Icons.auto_awesome_rounded),
                          color: AppColors.primary,
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Jadwal & Alarm Hari Ini',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: Theme.of(context).brightness == Brightness.dark
                                ? AppColors.darkTextSecondary
                                : AppColors.textMuted,
                          ),
                    ),
                    const SizedBox(height: 32),
                    _buildUpcomingCard(context, upcomingActivity),
                  ],
                ),
              ),
            ),
            if (activities.isEmpty)
              SliverFillRemaining(
                hasScrollBody: false,
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(32),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.05),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.event_note_outlined, 
                          size: 64, 
                          color: AppColors.primary.withOpacity(0.2)
                        ),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'Belum ada jadwal hari ini', 
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: Theme.of(context).brightness == Brightness.dark
                              ? AppColors.darkTextSecondary
                              : AppColors.textMuted,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Ketuk + untuk menambah kegiatan', 
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final activity = activities[index];
                      return ScheduleItemCard(activity: activity);
                    },
                    childCount: activities.length,
                  ),
                ),
              ),
            const SliverToBoxAdapter(child: SizedBox(height: 100)),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.large(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const EditActivityScreen()),
          );
        },
        backgroundColor: AppColors.primary,
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: const Icon(Icons.add_rounded, color: AppColors.white, size: 32),
      ),
    );
  }

  Widget _buildUpcomingCard(BuildContext context, Activity? upcoming) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(28),
      child: Container(
        height: 160,
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: AppColors.mainGradient,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withOpacity(0.3),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Stack(
          children: [
            Positioned(
              right: -20,
              top: -20,
              child: Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: AppColors.white.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(24),
              child: upcoming == null
                  ? Center(
                      child: Text(
                        'Istirahat sejenak,\nbelum ada kegiatan',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.plusJakartaSans(
                          color: AppColors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    )
                  : (() {
                      final cat = ActivityCategory.fromName(upcoming.category);
                      return Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: AppColors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Icon(
                              cat.icon,
                              color: AppColors.white,
                              size: 32,
                            ),
                          ),
                          const SizedBox(width: 20),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      'MENDATANG',
                                      style: GoogleFonts.plusJakartaSans(
                                        color: AppColors.white.withOpacity(0.7),
                                        fontWeight: FontWeight.w800,
                                        fontSize: 11,
                                        letterSpacing: 1.5,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                      decoration: BoxDecoration(
                                        color: cat.color.withOpacity(0.9),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Text(
                                        cat.name.toUpperCase(),
                                        style: GoogleFonts.plusJakartaSans(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w900,
                                          fontSize: 9,
                                          letterSpacing: 1.0,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  upcoming.title,
                                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                        color: AppColors.white,
                                        fontSize: 22,
                                      ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                Text(
                                  upcoming.time.format(context),
                                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                        color: AppColors.white.withOpacity(0.9),
                                        fontWeight: FontWeight.bold,
                                      ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      );
                    }()),
            ),
          ],
        ),
      ),
    );
  }
}

