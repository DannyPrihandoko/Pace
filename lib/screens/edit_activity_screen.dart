import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/activity.dart';
import '../providers/activity_provider.dart';
import '../theme/colors.dart';
import 'package:intl/intl.dart';

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

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.activity?.title ?? '');
    _descController = TextEditingController(text: widget.activity?.description ?? '');
    _selectedTime = widget.activity?.time ?? TimeOfDay.now();
    _isAlarmEnabled = widget.activity?.isAlarmEnabled ?? true;
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
    );
    if (picked != null) {
      setState(() => _selectedTime = picked);
    }
  }

  void _save() {
    if (_titleController.text.isEmpty) return;

    final activity = Activity(
      id: widget.activity?.id,
      title: _titleController.text,
      description: _descController.text,
      time: _selectedTime,
      isAlarmEnabled: _isAlarmEnabled,
      date: widget.activity?.date ?? DateFormat('yyyy-MM-dd').format(DateTime.now()),
    );

    if (widget.activity == null) {
      ref.read(activityProvider.notifier).addActivity(activity);
    } else {
      ref.read(activityProvider.notifier).updateActivity(activity);
    }

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.activity == null ? 'Tambah Kegiatan' : 'Edit Kegiatan'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: AppColors.textDarkBlue,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTextField('Judul Kegiatan', _titleController),
            const SizedBox(height: 20),
            _buildTextField('Deskripsi', _descController, maxLines: 3),
            const SizedBox(height: 32),
            Text('Waktu Pengingat', style: Theme.of(context).textTheme.titleSmall),
            const SizedBox(height: 12),
            InkWell(
              onTap: _pickTime,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                decoration: BoxDecoration(
                  color: AppColors.cardPaleBlue,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.borderColor),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _selectedTime.format(context),
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            color: AppColors.textDarkBlue,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const Icon(Icons.access_time_rounded, color: AppColors.textDarkBlue),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Aktifkan Alarm', style: Theme.of(context).textTheme.titleMedium),
                Switch(
                  value: _isAlarmEnabled,
                  onChanged: (val) => setState(() => _isAlarmEnabled = val),
                  activeColor: AppColors.ctaAqua,
                ),
              ],
            ),
            const SizedBox(height: 48),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _save,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.ctaAqua,
                  foregroundColor: AppColors.textDarkBlue,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 0,
                ),
                child: const Text('Simpan Kegiatan', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
            if (widget.activity != null) ...[
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: TextButton(
                  onPressed: () {
                    ref.read(activityProvider.notifier).deleteActivity(widget.activity!.id!);
                    Navigator.pop(context);
                  },
                  child: const Text('Hapus Kegiatan', style: TextStyle(color: Colors.redAccent)),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller, {int maxLines = 1}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: Theme.of(context).textTheme.titleSmall),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          maxLines: maxLines,
          decoration: InputDecoration(
            filled: true,
            fillColor: AppColors.cardPaleBlue.withOpacity(0.3),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: AppColors.borderColor),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: AppColors.borderColor),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: AppColors.ctaAqua, width: 2),
            ),
          ),
        ),
      ],
    );
  }
}
