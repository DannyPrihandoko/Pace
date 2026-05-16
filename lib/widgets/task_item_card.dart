import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/task.dart';
import '../theme/app_colors.dart';

/// [TaskItemCard] — Kartu tugas modern dengan micro-interaction.
///
/// Saat user menekan tombol selesai (checkbox), kartu akan "bounce" sedikit
/// mengecil lalu kembali normal, memberikan umpan balik visual yang memuaskan.
class TaskItemCard extends StatefulWidget {
  final Task task;
  final VoidCallback onToggle;

  const TaskItemCard({
    super.key,
    required this.task,
    required this.onToggle,
  });

  @override
  State<TaskItemCard> createState() => _TaskItemCardState();
}

class _TaskItemCardState extends State<TaskItemCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _scaleController;
  late final Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 160),
      vsync: this,
      lowerBound: 0.93,
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

  /// Jalankan animasi "bounce" lalu panggil callback toggle.
  Future<void> _handleToggle() async {
    await _scaleController.reverse(); // mengecil
    widget.onToggle();
    await _scaleController.forward(); // kembali normal
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final bool done = widget.task.isCompleted;

    // Warna teks adaptif berdasarkan status
    final Color titleColor = done
        ? (isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary)
        : (isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary);

    final Color subtitleColor =
        isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;

    return ScaleTransition(
      scale: _scaleAnimation,
      child: Card(
        margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 0),
        // Elevation & shadow yang sangat halus — hanya terasa, tidak mencolok
        elevation: done ? 0 : 2,
        shadowColor: AppColors.primary.withOpacity(0.08),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: BorderSide(
            color: done
                ? (isDark ? AppColors.darkBorder : AppColors.lightBorder)
                : colorScheme.primary.withOpacity(0.12),
            width: 1,
          ),
        ),
        child: InkWell(
          onTap: _handleToggle,
          borderRadius: BorderRadius.circular(14),
          splashColor: AppColors.primary.withOpacity(0.06),
          highlightColor: AppColors.primary.withOpacity(0.04),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                // ── Checkbox animasi ───────────────────────────────────────
                _AnimatedCheckbox(
                  isChecked: done,
                  onTap: _handleToggle,
                ),
                const SizedBox(width: 14),

                // ── Konten teks ────────────────────────────────────────────
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AnimatedDefaultTextStyle(
                        duration: const Duration(milliseconds: 250),
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: titleColor,
                          decoration: done ? TextDecoration.lineThrough : null,
                          decorationColor: subtitleColor,
                        ),
                        child: Text(widget.task.title, maxLines: 2, overflow: TextOverflow.ellipsis),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            Icons.schedule_rounded,
                            size: 12,
                            color: subtitleColor,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            widget.task.time,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: subtitleColor,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // ── Accent dot (hanya tampil jika belum selesai) ──────────
                if (!done) ...[
                  const SizedBox(width: 10),
                  Container(
                    width: 7,
                    height: 7,
                    decoration: BoxDecoration(
                      color: AppColors.warning,
                      shape: BoxShape.circle,
                    ),
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
// Widget checkbox animasi terpisah — menggunakan AnimatedContainer agar
// transisi warna & ikon berlangsung halus.
// ─────────────────────────────────────────────────────────────────────────────
class _AnimatedCheckbox extends StatelessWidget {
  final bool isChecked;
  final VoidCallback onTap;

  const _AnimatedCheckbox({required this.isChecked, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 280),
        curve: Curves.easeInOut,
        width: 26,
        height: 26,
        decoration: BoxDecoration(
          color: isChecked ? AppColors.primary : Colors.transparent,
          shape: BoxShape.circle,
          border: Border.all(
            color: isChecked
                ? AppColors.primary
                : AppColors.primary.withOpacity(0.35),
            width: 2,
          ),
          boxShadow: isChecked
              ? [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.30),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ]
              : [],
        ),
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 200),
          transitionBuilder: (child, animation) => ScaleTransition(
            scale: animation,
            child: child,
          ),
          child: isChecked
              ? const Icon(
                  Icons.check_rounded,
                  key: ValueKey('checked'),
                  size: 16,
                  color: Colors.white,
                )
              : const SizedBox.shrink(key: ValueKey('unchecked')),
        ),
      ),
    );
  }
}
