import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../theme/colors.dart';

/// A reusable widget to display QR codes with optimal visibility.
/// Ensures a "quiet zone" and high contrast for reliable scanning.
class QrContainer extends StatelessWidget {
  final String data;
  final double size;
  final String? title;
  final String? subtitle;

  const QrContainer({
    super.key,
    required this.data,
    this.size = 200.0,
    this.title,
    this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white, // Solid white for maximum QR contrast
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 30,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (title != null) ...[
            Text(
              title!,
              style: const TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 4),
          ],
          if (subtitle != null) ...[
            Text(
              subtitle!,
              style: TextStyle(
                color: Colors.black.withOpacity(0.5),
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 20),
          ],
          // The QR Code itself
          Container(
            padding: const EdgeInsets.all(12), // Quiet zone
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: QrImageView(
              data: data,
              version: QrVersions.auto,
              size: size,
              eyeStyle: const QrEyeStyle(
                eyeShape: QrEyeShape.circle,
                color: Color(0xFF1A1A1A), // Near black for contrast
              ),
              dataModuleStyle: const QrDataModuleStyle(
                dataModuleShape: QrDataModuleShape.circle,
                color: Color(0xFF1A1A1A),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
