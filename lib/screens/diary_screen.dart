import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/mood_provider.dart';

class DiaryScreen extends ConsumerStatefulWidget {
  const DiaryScreen({super.key});

  @override
  ConsumerState<DiaryScreen> createState() => _DiaryScreenState();
}

class _DiaryScreenState extends ConsumerState<DiaryScreen> {
  final TextEditingController _diaryController = TextEditingController();
  int? _selectedMood;

  @override
  void initState() {
    super.initState();
    // Load existing mood/comment if available
    Future.microtask(() {
      final currentMood = ref.read(moodProvider);
      if (currentMood != null) {
        setState(() {
          _selectedMood = currentMood.score;
          _diaryController.text = currentMood.comment ?? '';
        });
      }
    });
  }

  @override
  void dispose() {
    _diaryController.dispose();
    super.dispose();
  }

  void _saveDiary() async {
    if (_selectedMood == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pilih mood kamu dulu ya!')),
      );
      return;
    }

    // Call provider to save
    await ref.read(moodProvider.notifier).saveMood(
      _selectedMood!,
      comment: _diaryController.text,
    );

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Diary berhasil disimpan! ✨'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFF6366F1); // Indigo 500
    const bgColor = Color(0xFFF8FAFC);
    const cardColor = Colors.white;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        title: Text(
          'Diary & Mood',
          style: GoogleFonts.plusJakartaSans(
            fontWeight: FontWeight.w800,
            color: Colors.black87,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Mood Tracker Section
            Text(
              'Bagaimana perasaanmu hari ini?',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Ceritakan sedikit suasana hatimu.',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 14,
                color: Colors.black54,
              ),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildMoodItem(1, '😫', 'Buruk'),
                _buildMoodItem(2, '😕', 'Sedih'),
                _buildMoodItem(3, '😐', 'Biasa'),
                _buildMoodItem(4, '🙂', 'Senang'),
                _buildMoodItem(5, '🤩', 'Hebat'),
              ],
            ),

            const SizedBox(height: 40),

            // 2. Diary Section
            Text(
              'Tuliskan ceritamu',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: TextField(
                controller: _diaryController,
                maxLines: 10,
                style: GoogleFonts.plusJakartaSans(fontSize: 16),
                decoration: InputDecoration(
                  hintText: 'Apa yang terjadi hari ini? Tuliskan di sini...',
                  hintStyle: GoogleFonts.plusJakartaSans(color: Colors.black26),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.all(24),
                ),
              ),
            ),

            const SizedBox(height: 40),

            // 3. Save Button
            SizedBox(
              width: double.infinity,
              height: 60,
              child: ElevatedButton(
                onPressed: _saveDiary,
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 0,
                ),
                child: Text(
                  'Simpan Catatan',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMoodItem(int score, String emoji, String label) {
    final isSelected = _selectedMood == score;
    const selectedColor = Color(0xFF6366F1);

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedMood = score;
        });
      },
      child: Column(
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOutBack,
            width: isSelected ? 65 : 55,
            height: isSelected ? 65 : 55,
            decoration: BoxDecoration(
              color: isSelected ? selectedColor.withOpacity(0.1) : Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: isSelected ? selectedColor : Colors.black12,
                width: isSelected ? 2 : 1,
              ),
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: selectedColor.withOpacity(0.2),
                        blurRadius: 15,
                        offset: const Offset(0, 8),
                      )
                    ]
                  : [],
            ),
            child: Center(
              child: Text(
                emoji,
                style: TextStyle(
                  fontSize: isSelected ? 32 : 28,
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 12,
              fontWeight: isSelected ? FontWeight.w800 : FontWeight.w500,
              color: isSelected ? selectedColor : Colors.black45,
            ),
          ),
        ],
      ),
    );
  }
}
