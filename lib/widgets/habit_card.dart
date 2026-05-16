import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/habit.dart';
import '../theme/app_colors.dart';

/// [HabitCard] — Kartu habit modern dengan micro-interaction.
///
/// - Habit *boolean*: tampilkan status & checkbox animasi.
/// - Habit *progress*: tampilkan progress bar animasi.
/// - Saat di-tap, kartu "bounce" mengecil lalu kembali.
class HabitCard extends StatefulWidget {
  final Habit habit;
  final VoidCallback onTap;

  const HabitCard({
    super.key,
    required this.habit,
    required this.onTap,
  });

  @override
  State<HabitCard> createState() => _HabitCardState();
}

class _HabitCardState extends State<HabitCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _scaleController;
  late final Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 160),
      vsync: this,
      lowerBound: 0.94,
      upperBound: 1.0,
      value: 1.0,
    );
    _scaleAnimation = CurvedAnimation(
      parent: _scaleController,
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _scaleController.dispose();
    super.dispose();
  }

  Future<void> _handleTap() async {
    await _scaleController.reverse();
    widget.onTap();
    await _scaleController.forward();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colorScheme = Theme.of(context).colorScheme;

    final bool isProgress = widget.habit.type == HabitGoalType.progress;
    final bool done = widget.habit.isCompleted;
    final double progress = widget.habit.progressPercentage;

    final Color subtitleColor =
        isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;

    return ScaleTransition(
      scale: _scaleAnimation,
      child: Card(
        margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 0),
        elevation: done ? 0 : 2,
        shadowColor: AppColors.secondary.withOpacity(0.08),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            color: done
                ? (isDark ? AppColors.darkBorder : AppColors.lightBorder)
                : colorScheme.secondary.withOpacity(0.12),
            width: 1,
          ),
        ),
        child: InkWell(
          onTap: _handleTap,
          borderRadius: BorderRadius.circular(16),
          splashColor: AppColors.secondary.withOpacity(0.06),
          highlightColor: AppColors.secondary.withOpacity(0.04),
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Baris atas: judul + streak badge ────────────────────────
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Ikon habit
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: (isProgress
                                ? AppColors.info
                                : AppColors.success)
                            .withOpacity(0.12),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        isProgress
                            ? Icons.trending_up_rounded
                            : Icons.task_alt_rounded,
                        size: 18,
                        color: isProgress ? AppColors.info : AppColors.success,
                      ),
                    ),
                    const SizedBox(width: 12),

                    // Judul
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          AnimatedDefaultTextStyle(
                            duration: const Duration(milliseconds: 250),
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              letterSpacing: -0.2,
                              color: done
                                  ? subtitleColor
                                  : (isDark
                                      ? AppColors.darkTextPrimary
                                      : AppColors.lightTextPrimary),
                              decoration:
                                  done ? TextDecoration.lineThrough : null,
                              decorationColor: subtitleColor,
                            ),
                            child: Text(
                              widget.habit.title,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (!isProgress) ...[
                            const SizedBox(height: 3),
                            AnimatedDefaultTextStyle(
                              duration: const Duration(milliseconds: 250),
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: done
                                    ? AppColors.success
                                    : subtitleColor,
                              ),
                              child: Text(
                                done ? 'Sudah Selesai ✓' : 'Belum Selesai',
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),

                    const SizedBox(width: 8),

                    // Streak badge
                    if (widget.habit.streak > 0) ...[
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 9, vertical: 5),
                        decoration: BoxDecoration(
                          color: AppColors.warning.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.local_fire_department_rounded,
                              size: 14,
                              color: AppColors.warning,
                            ),
                            const SizedBox(width: 3),
                            Text(
                              '${widget.habit.streak}',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 12,
                                fontWeight: FontWeight.w800,
                                color: AppColors.warning,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ] else ...[
                      // Checkbox untuk habit boolean
                      if (!isProgress)
                        _AnimatedHabitCheckbox(isChecked: done),
                    ],
                  ],
                ),

                // ── Progress bar (hanya untuk tipe progress) ──────────────
                if (isProgress) ...[
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Progress Hari Ini',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: subtitleColor,
                          letterSpacing: 0.2,
                        ),
                      ),
                      Text(
                        '${widget.habit.currentProgress.toInt()} / ${widget.habit.targetProgress.toInt()}',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                          color: AppColors.info,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  // Progress bar dengan animasi implisit
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: TweenAnimationBuilder<double>(
                      tween: Tween<double>(begin: 0, end: progress),
                      duration: const Duration(milliseconds: 600),
                      curve: Curves.easeOut,
                      builder: (context, value, _) {
                        return LinearProgressIndicator(
                          value: value,
                          minHeight: 9,
                          backgroundColor: isDark
                              ? AppColors.darkBorder
                              : AppColors.lightBorder,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            value >= 1.0
                                ? AppColors.success
                                : AppColors.info,
                          ),
                        );
                      },
                    ),
                  ),
                ],

                // ── Checkbox untuk boolean (ketika streak == 0) ───────────
                if (!isProgress && widget.habit.streak == 0) ...[
                  const SizedBox(height: 12),
                  Align(
                    alignment: Alignment.centerRight,
                    child: _AnimatedHabitCheckbox(isChecked: done),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Checkbox habit dengan animasi color + scale (AnimatedContainer + AnimatedSwitcher).
// ─────────────────────────────────────────────────────────────────────────────
class _AnimatedHabitCheckbox extends StatelessWidget {
  final bool isChecked;

  const _AnimatedHabitCheckbox({required this.isChecked});

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 280),
      curve: Curves.easeInOut,
      width: 26,
      height: 26,
      decoration: BoxDecoration(
        color: isChecked ? AppColors.success : Colors.transparent,
        shape: BoxShape.circle,
        border: Border.all(
          color: isChecked
              ? AppColors.success
              : AppColors.success.withOpacity(0.35),
          width: 2,
        ),
        boxShadow: isChecked
            ? [
                BoxShadow(
                  color: AppColors.success.withOpacity(0.30),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ]
            : [],
      ),
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 200),
        transitionBuilder: (child, animation) =>
            ScaleTransition(scale: animation, child: child),
        child: isChecked
            ? const Icon(
                Icons.check_rounded,
                key: ValueKey('checked'),
                size: 16,
                color: Colors.white,
              )
            : const SizedBox.shrink(key: ValueKey('unchecked')),
      ),
    );
  }
}
