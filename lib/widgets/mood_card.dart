import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/mood_provider.dart';

class MoodCard extends ConsumerWidget {
  const MoodCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final todayMood = ref.watch(moodProvider);
    
    const black = Colors.black;
    const bgWhite = Colors.white;
    const pastelPink = Color(0xFFFBCFE8); // Pink 200
    const pastelYellow = Color(0xFFFEF08A);

    if (todayMood != null) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: pastelPink,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: black, width: 3.0),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: bgWhite,
                border: Border.all(color: black, width: 2.0),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                _getMoodEmoji(todayMood.score),
                style: const TextStyle(fontSize: 24),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'MOOD KAMU HARI INI',
                    style: GoogleFonts.plusJakartaSans(
                      color: black,
                      fontWeight: FontWeight.w900,
                      fontSize: 12,
                      letterSpacing: 2.0,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Kamu merasa ${_getMoodText(todayMood.score)}!',
                    style: GoogleFonts.plusJakartaSans(
                      color: black,
                      fontWeight: FontWeight.w900,
                      fontSize: 18,
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.edit_outlined, color: black, size: 20),
              onPressed: () {
                // To allow changing, we can just clear the state in the provider
                // but the provider's saveMood handles replacement (UNIQUE date).
                // For UI simplicity, we can just set state to null to show the selector again.
                ref.read(moodProvider.notifier).clearState();
              },
            ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: pastelYellow,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: black, width: 3.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'BAGAIMANA MOODMU HARI INI?',
            style: GoogleFonts.plusJakartaSans(
              color: black,
              fontWeight: FontWeight.w900,
              fontSize: 12,
              letterSpacing: 2.0,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(5, (index) {
              final score = index + 1;
              return GestureDetector(
                onTap: () {
                  ref.read(moodProvider.notifier).saveMood(score);
                },
                child: Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: bgWhite,
                    border: Border.all(color: black, width: 2.0),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Center(
                    child: Text(
                      _getMoodEmoji(score),
                      style: const TextStyle(fontSize: 24),
                    ),
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  String _getMoodEmoji(int score) {
    switch (score) {
      case 1: return '😫';
      case 2: return '😕';
      case 3: return '😐';
      case 4: return '🙂';
      case 5: return '🤩';
      default: return '😐';
    }
  }

  String _getMoodText(int score) {
    switch (score) {
      case 1: return 'Sangat Buruk';
      case 2: return 'Buruk';
      case 3: return 'Biasa Saja';
      case 4: return 'Baik';
      case 5: return 'Luar Biasa';
      default: return 'Biasa Saja';
    }
  }
}
