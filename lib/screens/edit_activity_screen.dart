import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/activity.dart';
import '../providers/activity_provider.dart';
import '../theme/colors.dart';
import 'package:intl/intl.dart';
import '../models/activity_category.dart';

class EditActivityScreen extends ConsumerStatefulWidget {
  final Activity? activity;

  const EditActivityScreen({super.key, this.activity});

  @override
  ConsumerState<EditActivityScreen> createState() => _EditActivityScreenState();
}

class _EditActivityScreenState extends ConsumerState<EditActivityScreen> {
  late TextEditingController _titleController;
  late TextEditingController _descController;
  late TimeOfDay _selectedTime;
  late bool _isAlarmEnabled;

  late String _selectedDate;
  String? _recurrenceRule;
  late String _selectedCategory;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.activity?.title ?? '');
    _descController = TextEditingController(text: widget.activity?.description ?? '');
    _selectedTime = widget.activity?.time ?? TimeOfDay.now();
    _isAlarmEnabled = widget.activity?.isAlarmEnabled ?? true;
    _selectedDate = widget.activity?.date ?? DateFormat('yyyy-MM-dd').format(DateTime.now());
    _recurrenceRule = widget.activity?.recurrenceRule;
    _selectedCategory = widget.activity?.category ?? 'Umum';
    _preAlertMinutes = widget.activity?.preAlertMinutes ?? 0;
    _snoozeMinutes = widget.activity?.snoozeMinutes ?? 5;
  }

  late int _snoozeMinutes;

  late int _preAlertMinutes;

  String _getRecurrenceLabel() {
    if (_recurrenceRule == null) return 'Tidak';
    if (_recurrenceRule!.contains('FREQ=DAILY')) return 'Setiap Hari';
    if (_recurrenceRule!.contains('FREQ=WEEKLY')) return 'Setiap Minggu';
    if (_recurrenceRule!.contains('FREQ=MONTHLY')) return 'Setiap Bulan';
    return 'Lainnya';
  }

  void _setRecurrence(String? type) {
    setState(() {
      if (type == null) {
        _recurrenceRule = null;
      } else {
        final date = DateTime.parse(_selectedDate);
        if (type == 'DAILY') {
          _recurrenceRule = 'FREQ=DAILY;INTERVAL=1';
        } else if (type == 'WEEKLY') {
          final dayNames = ['MO', 'TU', 'WE', 'TH', 'FR', 'SA', 'SU'];
          final day = dayNames[date.weekday - 1];
          _recurrenceRule = 'FREQ=WEEKLY;BYDAY=$day;INTERVAL=1';
        } else if (type == 'MONTHLY') {
          _recurrenceRule = 'FREQ=MONTHLY;BYMONTHDAY=${date.day};INTERVAL=1';
        }
      }
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    super.dispose();
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
              primary: AppColors.primary,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() => _selectedTime = picked);
    }
  }

  Future<void> _pickDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.parse(_selectedDate),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
       builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
              primary: AppColors.primary,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _selectedDate = DateFormat('yyyy-MM-dd').format(picked);
      });
    }
  }

  void _showSuccessModal(bool isEdit) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.success.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_circle_rounded,
                  color: AppColors.success,
                  size: 64,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                isEdit ? 'Pembaruan Berhasil' : 'Kegiatan Ditambahkan',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w900,
                      letterSpacing: -0.5,
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                isEdit 
                    ? 'Jadwal Anda telah diperbarui dengan sukses.' 
                    : 'Kegiatan baru Anda telah tersimpan ke dalam jadwal.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).brightness == Brightness.dark
                          ? AppColors.darkTextSecondary
                          : AppColors.textMuted,
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context); // Close dialog
                    Navigator.pop(this.context); // Go back to main screen
                  },
                  child: const Text('Kembali ke Beranda'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _save() {
    if (_titleController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Judul tidak boleh kosong')),
      );
      return;
    }

    final activity = Activity(
      id: widget.activity?.id,
      title: _titleController.text,
      description: _descController.text,
      time: _selectedTime,
      isAlarmEnabled: _isAlarmEnabled,
      date: _selectedDate,
      recurrenceRule: _recurrenceRule,
      category: _selectedCategory,
      preAlertMinutes: _preAlertMinutes,
      snoozeMinutes: _snoozeMinutes,
    );

    // Conflict Check
    final allActivities = ref.read(activityProvider);
    final hasConflict = allActivities.any((a) =>
        a.id != activity.id &&
        a.date == activity.date &&
        a.time.hour == activity.time.hour &&
        a.time.minute == activity.time.minute);

    if (hasConflict) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Jadwal Bentrok!'),
          content: const Text(
            'Sudah ada kegiatan lain yang dijadwalkan pada hari dan jam yang sama. Silakan pilih waktu lain.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Mengerti'),
            ),
          ],
        ),
      );
      return;
    }

    final bool isEdit = widget.activity != null;
    if (!isEdit) {
      ref.read(activityProvider.notifier).addActivity(activity);
    } else {
      ref.read(activityProvider.notifier).updateActivity(activity);
    }

    _showSuccessModal(isEdit);
  }

  void _showRecurrenceSheet() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Pilih Pengulangan', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 24),
            _buildRecurrenceOption('Tidak', null),
            _buildRecurrenceOption('Setiap Hari', 'DAILY'),
            _buildRecurrenceOption('Setiap Minggu', 'WEEKLY'),
            _buildRecurrenceOption('Setiap Bulan', 'MONTHLY'),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildRecurrenceOption(String label, String? type) {
    final bool isSelected = (type == null && _recurrenceRule == null) ||
        (type != null && _recurrenceRule?.contains(type) == true);

    return InkWell(
      onTap: () {
        _setRecurrence(type);
        Navigator.pop(context);
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              color: isSelected ? AppColors.primary : null,
            )),
            if (isSelected) const Icon(Icons.check_circle_rounded, color: AppColors.primary),
          ],
        ),
      ),
    );
  }

  void _confirmDelete() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Kegiatan?'),
        content: const Text('Tindakan ini tidak dapat dibatalkan.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () {
              ref.read(activityProvider.notifier).deleteActivity(widget.activity!.id!);
              Navigator.pop(context); // Close dialog
              Navigator.pop(this.context); // Close screen
              ScaffoldMessenger.of(this.context).showSnackBar(
                const SnackBar(
                  content: Text('Kegiatan dihapus'),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            child: const Text('Hapus', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.activity == null ? 'Tambah Kegiatan' : 'Edit Kegiatan'),
        actions: [
          if (widget.activity != null)
            IconButton(
              onPressed: _confirmDelete,
              icon: const Icon(Icons.delete_outline_rounded, color: AppColors.error),
            ),
        ],
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTextField(
              'Judul Kegiatan', 
              _titleController, 
              hint: 'Contoh: Olahraga Pagi',
              helperText: 'Tuliskan nama singkat kegiatan Anda.',
            ),
            const SizedBox(height: 24),
            _buildCategorySelector(),
            const SizedBox(height: 24),
            _buildTextField(
              'Deskripsi', 
              _descController, 
              maxLines: 3, 
              hint: 'Tambahkan detail kegiatan...',
              helperText: 'Info tambahan seperti lokasi atau catatan penting.',
            ),
            const SizedBox(height: 32),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Tanggal', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                      Text('Kapan dimulai?', style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).brightness == Brightness.dark
                            ? AppColors.darkTextSecondary
                            : AppColors.textMuted,
                      )),
                      const SizedBox(height: 12),
                      _buildPickerTile(
                        icon: Icons.calendar_today_rounded,
                        label: DateFormat('dd MMM yyyy').format(DateTime.parse(_selectedDate)),
                        onTap: _pickDate,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Waktu', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                      Text('Jam pelaksanaan', style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).brightness == Brightness.dark
                            ? AppColors.darkTextSecondary
                            : AppColors.textMuted,
                      )),
                      const SizedBox(height: 12),
                      _buildPickerTile(
                        icon: Icons.access_time_rounded,
                        label: _selectedTime.format(context),
                        onTap: _pickTime,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),
            Text('Pengulangan', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
            Text('Atur siklus kegiatan rutin', style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).brightness == Brightness.dark
                  ? AppColors.darkTextSecondary
                  : AppColors.textMuted,
            )),
            const SizedBox(height: 12),
            _buildPickerTile(
              icon: Icons.repeat_rounded,
              label: _getRecurrenceLabel(),
              onTap: _showRecurrenceSheet,
            ),
            const SizedBox(height: 32),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).cardTheme.color,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: Theme.of(context).brightness == Brightness.dark
                      ? AppColors.darkBorderColor
                      : AppColors.borderColor.withOpacity(0.5),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(Icons.notifications_active_rounded, color: AppColors.primary, size: 20),
                      ),
                      const SizedBox(width: 12),
                      Text('Aktifkan Alarm', style: Theme.of(context).textTheme.titleMedium),
                    ],
                  ),
                  Switch(
                    value: _isAlarmEnabled,
                    onChanged: (val) => setState(() => _isAlarmEnabled = val),
                    activeColor: AppColors.primary,
                  ),
                ],
              ),
            ),
            if (_isAlarmEnabled) ...[
              const SizedBox(height: 24),
              Text('Pengingat Pra-Kegiatan', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
              Text('Dapatkan peringatan sebelum dimulai', style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).brightness == Brightness.dark
                    ? AppColors.darkTextSecondary
                    : AppColors.textMuted,
              )),
              const SizedBox(height: 16),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                child: Row(
                  children: [
                    _buildPreAlertChip('Tidak', 0),
                    _buildPreAlertChip('10 Menit', 10),
                    _buildPreAlertChip('15 Menit', 15),
                    _buildPreAlertChip('30 Menit', 30),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Text('Durasi Snooze', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
              Text('Waktu tunda saat alarm berbunyi', style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).brightness == Brightness.dark
                    ? AppColors.darkTextSecondary
                    : AppColors.textMuted,
              )),
              const SizedBox(height: 16),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                child: Row(
                  children: [
                    _buildSnoozeChip('5m', 5),
                    _buildSnoozeChip('10m', 10),
                    _buildSnoozeChip('15m', 15),
                    _buildSnoozeChip('30m', 30),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 48),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _save,
                child: const Text('Simpan Kegiatan'),
              ),
            ),
            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }

  Widget _buildSnoozeChip(String label, int minutes) {
    final bool isSelected = _snoozeMinutes == minutes;
    return GestureDetector(
      onTap: () => setState(() => _snoozeMinutes = minutes),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(right: 12),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Theme.of(context).cardTheme.color,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.borderColor.withOpacity(0.5),
            width: 1.5,
          ),
          boxShadow: [
            if (isSelected)
              BoxShadow(
                color: AppColors.primary.withOpacity(0.3),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
          ],
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Theme.of(context).textTheme.bodyMedium?.color,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            fontSize: 13,
          ),
        ),
      ),
    );
  }

  Widget _buildPreAlertChip(String label, int minutes) {
    final bool isSelected = _preAlertMinutes == minutes;
    return GestureDetector(
      onTap: () => setState(() => _preAlertMinutes = minutes),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(right: 12),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Theme.of(context).cardTheme.color,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.borderColor.withOpacity(0.5),
            width: 1.5,
          ),
          boxShadow: [
            if (isSelected)
              BoxShadow(
                color: AppColors.primary.withOpacity(0.3),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
          ],
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Theme.of(context).textTheme.bodyMedium?.color,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            fontSize: 13,
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller, {int maxLines = 1, String? hint, String? helperText}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
        if (helperText != null)
          Padding(
            padding: const EdgeInsets.only(top: 4, bottom: 8),
            child: Text(
              helperText,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).brightness == Brightness.dark
                    ? AppColors.darkTextSecondary
                    : AppColors.textMuted,
              ),
            ),
          ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          maxLines: maxLines,
          style: Theme.of(context).textTheme.bodyLarge,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: AppColors.textMuted.withOpacity(0.5), fontSize: 14),
            filled: true,
            fillColor: Theme.of(context).cardTheme.color,
            contentPadding: const EdgeInsets.all(20),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(20),
              borderSide: BorderSide(
                color: Theme.of(context).brightness == Brightness.dark
                    ? AppColors.darkBorderColor
                    : AppColors.borderColor.withOpacity(0.8),
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(20),
              borderSide: BorderSide(
                color: Theme.of(context).brightness == Brightness.dark
                    ? AppColors.darkBorderColor
                    : AppColors.borderColor.withOpacity(0.8),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(20),
              borderSide: const BorderSide(color: AppColors.primary, width: 2),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPickerTile({required IconData icon, required String label, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: Theme.of(context).cardTheme.color,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: Theme.of(context).brightness == Brightness.dark
                ? AppColors.darkBorderColor
                : AppColors.borderColor.withOpacity(0.5),
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon, 
              color: Theme.of(context).brightness == Brightness.dark
                  ? AppColors.darkTextSecondary
                  : AppColors.textMuted, 
              size: 20
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategorySelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Kategori', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        SizedBox(
          height: 100,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            itemCount: ActivityCategory.categories.length,
            itemBuilder: (context, index) {
              final cat = ActivityCategory.categories[index];
              final isSelected = _selectedCategory == cat.name;
              return GestureDetector(
                onTap: () => setState(() => _selectedCategory = cat.name),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 80,
                  margin: const EdgeInsets.only(right: 12),
                  decoration: BoxDecoration(
                    color: isSelected ? cat.color : Theme.of(context).cardTheme.color,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isSelected 
                          ? cat.color 
                          : (Theme.of(context).brightness == Brightness.dark 
                              ? AppColors.darkBorderColor 
                              : AppColors.borderColor.withOpacity(0.5)),
                      width: 2,
                    ),
                    boxShadow: [
                      if (isSelected)
                        BoxShadow(
                          color: cat.color.withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                    ],
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        cat.icon, 
                        color: isSelected ? Colors.white : cat.color,
                        size: 28,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        cat.name,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: isSelected ? Colors.white : Theme.of(context).textTheme.bodySmall?.color,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
