import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/ai_model.dart';
import '../providers/ai_provider.dart';

class AiChatScreen extends ConsumerStatefulWidget {
  const AiChatScreen({super.key});

  @override
  ConsumerState<AiChatScreen> createState() => _AiChatScreenState();
}

class _AiChatScreenState extends ConsumerState<AiChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  // ── Color Palette (AI Dark Mode) ──────────────────────────────────────────
  static const _bg = Color(0xFF0D1117);
  static const _surface = Color(0xFF161B22);
  static const _border = Color(0xFF30363D);
  static const _accent = Color(0xFF4F9CF9);
  static const _userBubble = Color(0xFF1F6FEB);
  static const _aiBubble = Color(0xFF21262D);
  static const _textPrimary = Color(0xFFE6EDF3);
  static const _textMuted = Color(0xFF8B949E);

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _send(String text) {
    if (text.trim().isEmpty) return;
    _controller.clear();
    ref.read(aiChatProvider.notifier).sendMessage(text);
    _scrollToBottom();
  }

  @override
  Widget build(BuildContext context) {
    final chatState = ref.watch(aiChatProvider);

    // Auto-scroll on new message
    if (chatState.messages.isNotEmpty) {
      _scrollToBottom();
    }

    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: _surface,
        elevation: 0,
        title: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: _accent.withOpacity(0.15),
                shape: BoxShape.circle,
                border: Border.all(color: _accent.withOpacity(0.3)),
              ),
              child: const Icon(Icons.auto_awesome_rounded, color: _accent, size: 18),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'PACE AI',
                  style: GoogleFonts.plusJakartaSans(
                    fontWeight: FontWeight.w900,
                    fontSize: 15,
                    color: _textPrimary,
                  ),
                ),
                Row(
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      margin: const EdgeInsets.only(right: 5),
                      decoration: const BoxDecoration(
                        color: Color(0xFF3FB950),
                        shape: BoxShape.circle,
                      ),
                    ),
                    Text(
                      'Offline · Siap membantu',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 11,
                        color: _textMuted,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            onPressed: () => ref.read(aiChatProvider.notifier).clearChat(),
            icon: const Icon(Icons.refresh_rounded, color: _textMuted),
            tooltip: 'Reset chat',
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: _border),
        ),
      ),
      body: Column(
        children: [
          // ── Message List ───────────────────────────────────────────────
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.symmetric(vertical: 16),
              itemCount: chatState.messages.length + (chatState.isThinking ? 1 : 0),
              itemBuilder: (context, index) {
                if (chatState.isThinking && index == chatState.messages.length) {
                  return const _TypingIndicator();
                }
                final msg = chatState.messages[index];
                return _MessageBubble(msg: msg, onQuickReply: _send);
              },
            ),
          ),
          // ── Input Bar ─────────────────────────────────────────────────
          Container(
            decoration: BoxDecoration(
              color: _surface,
              border: Border(top: BorderSide(color: _border)),
            ),
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: _bg,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: _border),
                    ),
                    child: TextField(
                      controller: _controller,
                      style: GoogleFonts.plusJakartaSans(
                        color: _textPrimary,
                        fontSize: 14,
                      ),
                      onSubmitted: _send,
                      textInputAction: TextInputAction.send,
                      maxLines: 3,
                      minLines: 1,
                      decoration: InputDecoration(
                        hintText: 'Tanya sesuatu...',
                        hintStyle: GoogleFonts.plusJakartaSans(color: _textMuted, fontSize: 14),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                GestureDetector(
                  onTap: () => _send(_controller.text),
                  child: Container(
                    width: 48,
                    height: 48,
                    decoration: const BoxDecoration(
                      color: _userBubble,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.send_rounded, color: Colors.white, size: 20),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Message Bubble ───────────────────────────────────────────────────────────

class _MessageBubble extends StatelessWidget {
  final AiMessage msg;
  final void Function(String) onQuickReply;

  static const _userBubble = Color(0xFF1F6FEB);
  static const _aiBubble = Color(0xFF21262D);
  static const _accent = Color(0xFF4F9CF9);
  static const _textPrimary = Color(0xFFE6EDF3);
  static const _textMuted = Color(0xFF8B949E);

  const _MessageBubble({required this.msg, required this.onQuickReply});

  @override
  Widget build(BuildContext context) {
    final isUser = msg.role == AiMessageRole.user;

    return Padding(
      padding: EdgeInsets.only(
        left: isUser ? 64 : 16,
        right: isUser ? 16 : 64,
        bottom: 12,
      ),
      child: Column(
        crossAxisAlignment:
            isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: isUser ? _userBubble : _aiBubble,
              borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(18),
                topRight: const Radius.circular(18),
                bottomLeft: Radius.circular(isUser ? 18 : 4),
                bottomRight: Radius.circular(isUser ? 4 : 18),
              ),
            ),
            child: _buildText(msg.text),
          ),
          if (!isUser && msg.quickReplies.isNotEmpty) ...[
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: msg.quickReplies.map((qr) {
                return GestureDetector(
                  onTap: () => onQuickReply(qr),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.transparent,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: _accent.withOpacity(0.5)),
                    ),
                    child: Text(
                      qr,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12,
                        color: _accent,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
          const SizedBox(height: 4),
          Text(
            '${msg.timestamp.hour.toString().padLeft(2, '0')}:${msg.timestamp.minute.toString().padLeft(2, '0')}',
            style: GoogleFonts.plusJakartaSans(fontSize: 10, color: _textMuted),
          ),
        ],
      ),
    );
  }

  Widget _buildText(String text) {
    // Simple bold parsing for **text**
    final spans = <TextSpan>[];
    final parts = text.split('**');
    for (int i = 0; i < parts.length; i++) {
      spans.add(TextSpan(
        text: parts[i],
        style: TextStyle(
          fontWeight: i.isOdd ? FontWeight.w800 : FontWeight.normal,
          color: _textPrimary,
          fontSize: 14,
          height: 1.6,
        ),
      ));
    }
    return RichText(
      text: TextSpan(
        children: spans,
        style: GoogleFonts.plusJakartaSans(),
      ),
    );
  }
}

// ─── Typing Indicator ─────────────────────────────────────────────────────────

class _TypingIndicator extends StatefulWidget {
  const _TypingIndicator();

  @override
  State<_TypingIndicator> createState() => _TypingIndicatorState();
}

class _TypingIndicatorState extends State<_TypingIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1200))
      ..repeat();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 16, bottom: 12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: const Color(0xFF21262D),
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(18),
            topRight: Radius.circular(18),
            bottomRight: Radius.circular(18),
            bottomLeft: Radius.circular(4),
          ),
        ),
        child: AnimatedBuilder(
          animation: _ctrl,
          builder: (_, __) {
            return Row(
              mainAxisSize: MainAxisSize.min,
              children: List.generate(3, (i) {
                final offset = ((_ctrl.value * 3) - i).clamp(0.0, 1.0);
                final scale = 0.6 + (0.4 * (1 - (offset - 0.5).abs() * 2).clamp(0.0, 1.0));
                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  width: 8 * scale,
                  height: 8 * scale,
                  decoration: const BoxDecoration(
                    color: Color(0xFF8B949E),
                    shape: BoxShape.circle,
                  ),
                );
              }),
            );
          },
        ),
      ),
    );
  }
}
