import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/mood.dart';
import '../services/database_service.dart';

final moodProvider = StateNotifierProvider<MoodNotifier, Mood?>((ref) {
  return MoodNotifier();
});

class MoodNotifier extends StateNotifier<Mood?> {
  MoodNotifier() : super(null) {
    loadTodayMood();
  }

  Future<void> loadTodayMood() async {
    final today = DateTime.now().toIso8601String().split('T')[0];
    final moodMap = await DatabaseService.instance.getMoodByDate(today);
    if (moodMap != null) {
      state = Mood.fromMap(moodMap);
    } else {
      state = null;
    }
  }

  Future<void> saveMood(int score, {String? comment}) async {
    final today = DateTime.now().toIso8601String().split('T')[0];
    final mood = Mood(
      score: score,
      date: today,
      comment: comment,
    );
    await DatabaseService.instance.saveMood(mood.toMap());
    state = mood;
  }

  void clearState() {
    state = null;
  }
}

final hasMoodForTodayProvider = Provider<bool>((ref) {
  final mood = ref.watch(moodProvider);
  return mood != null;
});
