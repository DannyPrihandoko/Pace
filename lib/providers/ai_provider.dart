import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/ai_model.dart';
import '../services/ai_engine.dart';
import 'activity_provider.dart';
import 'habit_provider.dart';
import 'sleep_provider.dart';

class AiChatState {
  final List<AiMessage> messages;
  final bool isThinking;

  AiChatState({required this.messages, this.isThinking = false});

  AiChatState copyWith({List<AiMessage>? messages, bool? isThinking}) =>
      AiChatState(
        messages: messages ?? this.messages,
        isThinking: isThinking ?? this.isThinking,
      );
}

class AiChatNotifier extends StateNotifier<AiChatState> {
  final Ref _ref;

  AiChatNotifier(this._ref) : super(AiChatState(messages: [])) {
    // Send welcome message on init
    _sendWelcome();
  }

  void _sendWelcome() {
    final ctx = _buildContext();
    final welcome = AiMessage.fromAssistant(
      '${ctx.greeting}! 👋 Saya **PACE AI**, asisten cerdas Anda.\n\nSaya bisa membantu Anda dengan jadwal, habit, alarm, dan tips produktivitas — semuanya **tanpa koneksi internet**! ✨',
      quickReplies: ['Jadwal hari ini', 'Cek habit saya', 'Tips produktivitas'],
    );
    state = state.copyWith(messages: [welcome]);
  }

  AiContext _buildContext() {
    final activities = _ref.read(todayActivitiesProvider);
    final habits = _ref.read(habitProvider);
    final sleepSched = _ref.read(sleepProvider);
    final now = DateTime.now();

    return AiContext(
      currentDate: now,
      currentTime: TimeOfDay.now(),
      todayActivities: activities
          .map((a) => AiActivitySnapshot(
                title: a.title,
                hour: a.time.hour,
                minute: a.time.minute,
                category: a.category,
                hasAlarm: a.isAlarmEnabled,
              ))
          .toList(),
      habits: habits
          .map((h) => AiHabitSnapshot(
                title: h.title,
                streak: h.streak,
                isCompleted: h.isCompleted,
                progress: h.currentProgress,
                target: h.targetProgress,
              ))
          .toList(),
      sleepSchedule: AiSleepSnapshot(
        bedtime:
            '${sleepSched.bedtime.hour.toString().padLeft(2, '0')}:${sleepSched.bedtime.minute.toString().padLeft(2, '0')}',
        wakeupTime:
            '${sleepSched.wakeupTime.hour.toString().padLeft(2, '0')}:${sleepSched.wakeupTime.minute.toString().padLeft(2, '0')}',
        durationHours: sleepSched.calculateDuration(),
        windDownEnabled: sleepSched.isWindDownEnabled,
      ),
    );
  }

  Future<void> sendMessage(String input) async {
    if (input.trim().isEmpty) return;

    // Add user message
    final userMsg = AiMessage.fromUser(input.trim());
    state = state.copyWith(
      messages: [...state.messages, userMsg],
      isThinking: true,
    );

    // Simulate AI thinking delay (150–600ms for realism)
    await Future.delayed(
        Duration(milliseconds: 150 + (input.length * 8).clamp(0, 450)));

    // Classify + generate response
    final intent = IntentClassifier.classify(input);
    final ctx = _buildContext();
    final response = ResponseGenerator.generate(intent, ctx);

    state = state.copyWith(
      messages: [...state.messages, response],
      isThinking: false,
    );
  }

  void clearChat() {
    state = AiChatState(messages: []);
    _sendWelcome();
  }
}

final aiChatProvider = StateNotifierProvider<AiChatNotifier, AiChatState>((ref) {
  return AiChatNotifier(ref);
});
