import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/habit.dart';
import '../providers/habit_provider.dart';
import '../theme/app_colors.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Entry point — call this from any screen to show the sheet.
// ─────────────────────────────────────────────────────────────────────────────
void showAddHabitSheet(BuildContext context) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => const AddHabitSheet(),
  );
}

// ─────────────────────────────────────────────────────────────────────────────
// AddHabitSheet
// ─────────────────────────────────────────────────────────────────────────────
class AddHabitSheet extends ConsumerStatefulWidget {
  const AddHabitSheet({super.key});

  @override
  ConsumerState<AddHabitSheet> createState() => _AddHabitSheetState();
}

class _AddHabitSheetState extends ConsumerState<AddHabitSheet> {
  final _formKey = GlobalKey<FormState>();
  final _titleCtrl = TextEditingController();
  final _targetCtrl = TextEditingController();

  HabitGoalType _type = HabitGoalType.boolean;
  String _category = 'Health';
  bool _isSaving = false;

  // ── Static data ────────────────────────────────────────────────────────────
  static const _categories = [
    'Health',
    'Fitness',
    'Learning',
    'Mindfulness',
    'Other',
  ];

  static const _typeMeta = [
    (
      value: HabitGoalType.boolean,
      label: 'Ya / Tidak',
      icon: Icons.check_circle_outline_rounded,
      desc: 'Selesai atau belum',
    ),
    (
      value: HabitGoalType.progress,
      label: 'Progress',
      icon: Icons.bar_chart_rounded,
      desc: 'Capai target angka',
    ),
  ];

  @override
  void dispose() {
    _titleCtrl.dispose();
    _targetCtrl.dispose();
    super.dispose();
  }

  // ── Save ───────────────────────────────────────────────────────────────────
  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);
    HapticFeedback.lightImpact();

    final target = _type == HabitGoalType.progress
        ? double.tryParse(_targetCtrl.text.trim()) ?? 1.0
        : 1.0;

    await ref.read(habitProvider.notifier).addHabit(
          Habit(
            title: _titleCtrl.text.trim(),
            type: _type,
            targetProgress: target,
            category: _category,
          ),
        );

    if (!mounted) return;
    setState(() => _isSaving = false);
    Navigator.pop(context);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.local_fire_department_rounded,
                color: Colors.white, size: 20),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                'Habit "${_titleCtrl.text.trim()}" berhasil ditambahkan! 🔥',
                style: GoogleFonts.plusJakartaSans(
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: AppColors.warning,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  // ── Build ──────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final viewInset = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : AppColors.lightCard,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 12,
        bottom: viewInset + 28,
      ),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Drag Handle ──────────────────────────────────────────────
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                    borderRadius: BorderRadius.circular(99),
                  ),
                ),
              ),

              // ── Header ───────────────────────────────────────────────────
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFFF59E0B), Color(0xFFEF4444)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.local_fire_department_rounded,
                        color: Colors.white, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Habit Baru',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.3,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // ── Nama Habit ───────────────────────────────────────────────
              _HabitSectionLabel(label: 'NAMA HABIT'),
              const SizedBox(height: 8),
              TextFormField(
                controller: _titleCtrl,
                autofocus: true,
                textCapitalization: TextCapitalization.sentences,
                style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w600),
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Nama tidak boleh kosong' : null,
                decoration: _habitInputDecoration(
                  context,
                  hint: 'Contoh: Minum 8 gelas air',
                  prefixIcon: Icons.self_improvement_rounded,
                ),
              ),
              const SizedBox(height: 20),

              // ── Tipe Habit ───────────────────────────────────────────────
              _HabitSectionLabel(label: 'TIPE HABIT'),
              const SizedBox(height: 10),
              Row(
                children: _typeMeta.map((t) {
                  final isSelected = _type == t.value;
                  return Expanded(
                    child: Padding(
                      padding: EdgeInsets.only(
                        right: t.value == HabitGoalType.boolean ? 6 : 0,
                        left: t.value == HabitGoalType.progress ? 6 : 0,
                      ),
                      child: GestureDetector(
                        onTap: () {
                          HapticFeedback.selectionClick();
                          setState(() => _type = t.value);
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 14),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? AppColors.warning.withOpacity(0.12)
                                : (isDark
                                    ? AppColors.darkBackground
                                    : const Color(0xFFF4F6F8)),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: isSelected
                                  ? AppColors.warning
                                  : (isDark
                                      ? AppColors.darkBorder
                                      : AppColors.lightBorder),
                              width: isSelected ? 1.5 : 1,
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(
                                t.icon,
                                size: 20,
                                color: isSelected
                                    ? AppColors.warning
                                    : cs.onSurface.withOpacity(0.4),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                t.label,
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color: isSelected
                                      ? AppColors.warning
                                      : cs.onSurface.withOpacity(0.7),
                                ),
                              ),
                              Text(
                                t.desc,
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w500,
                                  color: cs.onSurface.withOpacity(0.4),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),

              // ── Target (conditional) ─────────────────────────────────────
              AnimatedSize(
                duration: const Duration(milliseconds: 250),
                curve: Curves.easeInOut,
                child: _type == HabitGoalType.progress
                    ? Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 20),
                          _HabitSectionLabel(label: 'TARGET ANGKA'),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: _targetCtrl,
                            keyboardType: const TextInputType.numberWithOptions(
                                decimal: false),
                            style: GoogleFonts.plusJakartaSans(
                                fontWeight: FontWeight.w600),
                            validator: (v) {
                              if (_type != HabitGoalType.progress) return null;
                              if (v == null || v.trim().isEmpty) {
                                return 'Target tidak boleh kosong';
                              }
                              final n = double.tryParse(v.trim());
                              if (n == null || n <= 0) {
                                return 'Masukkan angka yang valid';
                              }
                              return null;
                            },
                            decoration: _habitInputDecoration(
                              context,
                              hint: 'Contoh: 10000 (langkah)',
                              prefixIcon: Icons.flag_rounded,
                            ),
                          ),
                        ],
                      )
                    : const SizedBox.shrink(),
              ),
              const SizedBox(height: 20),

              // ── Kategori ─────────────────────────────────────────────────
              _HabitSectionLabel(label: 'KATEGORI'),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _categories.map((cat) {
                  final isSelected = _category == cat;
                  return GestureDetector(
                    onTap: () {
                      HapticFeedback.selectionClick();
                      setState(() => _category = cat);
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColors.warning.withOpacity(0.12)
                            : (isDark
                                ? AppColors.darkBackground
                                : const Color(0xFFF4F6F8)),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isSelected
                              ? AppColors.warning
                              : (isDark
                                  ? AppColors.darkBorder
                                  : AppColors.lightBorder),
                          width: isSelected ? 1.5 : 1,
                        ),
                      ),
                      child: Text(
                        _habitCategoryLabel(cat),
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 13,
                          fontWeight:
                              isSelected ? FontWeight.w700 : FontWeight.w500,
                          color: isSelected
                              ? AppColors.warning
                              : cs.onSurface.withOpacity(0.6),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 28),

              // ── Save Button ──────────────────────────────────────────────
              SizedBox(
                width: double.infinity,
                height: 52,
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 250),
                  child: _isSaving
                      ? Container(
                          key: const ValueKey('loading'),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFFF59E0B), Color(0xFFEF4444)],
                            ),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: const Center(
                            child: SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.5,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        )
                      : DecoratedBox(
                          key: const ValueKey('button'),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFFF59E0B), Color(0xFFEF4444)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(14),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.warning.withOpacity(0.4),
                                blurRadius: 14,
                                offset: const Offset(0, 6),
                              ),
                            ],
                          ),
                          child: ElevatedButton.icon(
                            onPressed: _save,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              shadowColor: Colors.transparent,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                            icon: const Icon(
                                Icons.local_fire_department_rounded,
                                color: Colors.white),
                            label: Text(
                              'Mulai Habit Ini',
                              style: GoogleFonts.plusJakartaSans(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                                fontSize: 15,
                              ),
                            ),
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Helpers
// ─────────────────────────────────────────────────────────────────────────────
String _habitCategoryLabel(String cat) {
  const map = {
    'Health': '❤️ Health',
    'Fitness': '🏋️ Fitness',
    'Learning': '📚 Learning',
    'Mindfulness': '🧘 Mindfulness',
    'Other': '📌 Other',
    'Umum': '📌 Umum',
  };
  return map[cat] ?? cat;
}

InputDecoration _habitInputDecoration(
  BuildContext context, {
  required String hint,
  required IconData prefixIcon,
}) {
  final isDark = Theme.of(context).brightness == Brightness.dark;
  return InputDecoration(
    hintText: hint,
    hintStyle: GoogleFonts.plusJakartaSans(
      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.35),
      fontSize: 14,
    ),
    prefixIcon: Icon(prefixIcon,
        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.4),
        size: 20),
    filled: true,
    fillColor: isDark
        ? AppColors.darkBackground.withOpacity(0.6)
        : const Color(0xFFF4F6F8),
    contentPadding:
        const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: BorderSide(
        color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
      ),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: BorderSide(
        color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
      ),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: const BorderSide(color: AppColors.warning, width: 2),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: const BorderSide(color: AppColors.error),
    ),
    focusedErrorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: const BorderSide(color: AppColors.error, width: 2),
    ),
  );
}

class _HabitSectionLabel extends StatelessWidget {
  final String label;
  const _HabitSectionLabel({required this.label});

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: GoogleFonts.plusJakartaSans(
        fontSize: 10,
        fontWeight: FontWeight.w800,
        letterSpacing: 1.4,
        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.45),
      ),
    );
  }
}
