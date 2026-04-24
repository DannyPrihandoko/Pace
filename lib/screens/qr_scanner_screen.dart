import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../providers/activity_provider.dart';
import '../models/activity.dart';
import '../theme/colors.dart';
import 'package:intl/intl.dart';

class QRScannerScreen extends ConsumerStatefulWidget {
  const QRScannerScreen({super.key});

  @override
  ConsumerState<QRScannerScreen> createState() => _QRScannerScreenState();
}

class _QRScannerScreenState extends ConsumerState<QRScannerScreen> {
  final MobileScannerController controller = MobileScannerController();
  bool _isProcessing = false;

  void _onDetect(BarcodeCapture capture) async {
    if (_isProcessing) return;
    final List<Barcode> barcodes = capture.barcodes;
    
    for (final barcode in barcodes) {
      if (barcode.rawValue != null) {
        setState(() => _isProcessing = true);
        try {
          final data = jsonDecode(barcode.rawValue!);
          if (data['type'] == 'schedule_share') {
            await _showAdoptDialog(data['user'], data['activities']);
          } else {
            _showError('Format kode tidak dikenali');
            setState(() => _isProcessing = false);
          }
        } catch (e) {
          _showError('Gagal membaca data: $e');
          setState(() => _isProcessing = false);
        }
        break;
      }
    }
  }

  Future<void> _showAdoptDialog(String userName, List<dynamic> activitiesJson) async {
    final List<Activity> newActivities = activitiesJson.map((e) => Activity.fromMap(e)).toList();

    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text('Adopsi Jadwal $userName?'),
        content: Text('Terdapat ${newActivities.length} kegiatan yang akan ditambahkan ke jadwal hari ini.'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() => _isProcessing = false);
            },
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () async {
              final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
              for (var act in newActivities) {
                // Ensure act is for today and has no ID (to create new entries)
                final cleanAct = act.copyWith(id: null, date: today);
                await ref.read(activityProvider.notifier).addActivity(cleanAct);
              }
              if (mounted) {
                Navigator.pop(context); // Close dialog
                Navigator.pop(context); // Return from scanner
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Berhasil mengadopsi jadwal $userName'),
                    backgroundColor: AppColors.success,
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
            child: const Text('Adopsi'),
          ),
        ],
      ),
    );
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: AppColors.error),
    );
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scan Jadwal'),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
      ),
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          MobileScanner(
            controller: controller,
            onDetect: _onDetect,
          ),
          // Scanner Overlay
          Center(
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.white, width: 2),
                borderRadius: BorderRadius.circular(20),
              ),
            ),
          ),
          if (_isProcessing)
            const Center(child: CircularProgressIndicator(color: AppColors.primary)),
          Positioned(
            bottom: 40,
            left: 0,
            right: 0,
            child: Center(
              child: Text(
                'Arahkan kamera ke kode QR teman',
                style: const TextStyle(color: Colors.white70, fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
