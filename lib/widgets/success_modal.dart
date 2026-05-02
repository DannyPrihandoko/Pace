import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SuccessModal extends StatefulWidget {
  final String title;
  final String message;

  const SuccessModal({
    super.key,
    required this.title,
    this.message = 'Aksi Anda berhasil diproses.',
  });

  static Future<void> show(BuildContext context, {required String title, String? message}) {
    return showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => SuccessModal(title: title, message: message ?? 'Aksi Anda berhasil diproses.'),
    );
  }

  @override
  State<SuccessModal> createState() => _SuccessModalState();
}

class _SuccessModalState extends State<SuccessModal> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    // Flat straightforward slide up without bouncy elastic effect
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.15), 
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut, // Simple ease out
    ));
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // 2D Flat Palette
    const black = Colors.black;
    const bgWhite = Colors.white;
    const accentGreen = Color(0xFF10B981); // Emerald Green
    const accentYellow = Color(0xFFFEF08A); // Bright Yellow for action button

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)), // Flat shape
      elevation: 0, // No shadow from the dialog
      backgroundColor: Colors.transparent,
      child: FadeTransition(
        opacity: _controller,
        child: SlideTransition(
          position: _slideAnimation,
          child: Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: bgWhite,
              borderRadius: BorderRadius.circular(4), // Sharp corners
              border: Border.all(color: black, width: 3.0), // Thick black border
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // 2D Flat Icon Box
                Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    color: accentGreen,
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: black, width: 3.0), // Hard border on icon
                  ),
                  child: const Icon(
                    Icons.check, // Simple solid check icon
                    color: black, // Black icon to match the flat aesthetic
                    size: 48,
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  widget.title.toUpperCase(),
                  textAlign: TextAlign.center,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    color: black,
                    letterSpacing: 1.0,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  widget.message,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: black.withOpacity(0.8),
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 32),
                // Flat Action Button
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: accentYellow, // Bright accent
                      foregroundColor: black, // Black text
                      elevation: 0, // No button shadow
                      shadowColor: Colors.transparent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4), // Sharp button corners
                        side: const BorderSide(color: black, width: 3.0), // Thick button border
                      ),
                    ),
                    child: Text(
                      'LANJUT',
                      style: GoogleFonts.plusJakartaSans(
                        fontWeight: FontWeight.w900, // Extra bold
                        fontSize: 16,
                        letterSpacing: 1.5,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
