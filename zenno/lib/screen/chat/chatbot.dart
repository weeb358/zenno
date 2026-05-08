import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:zenno/widgets/gaming_widgets.dart';

// Replace with your Groq API key from https://console.groq.com
const _groqApiKey = 'YOUR_GROQ_API_KEY_HERE';
const _groqModel = 'llama-3.3-70b-versatile';

const _systemPrompt =
    'You are ZennoBot, an AI game recommendation assistant for Zenno — a premium gaming platform similar to Steam. '
    'Recommend games based on the user\'s mood, preferences, or interests. '
    'Keep responses concise (2-4 sentences), enthusiastic, and gaming-focused. '
    'Mood mappings: Sad/lonely → cozy games, story-driven RPGs; Excited → FPS, racing, action; '
    'Scared → horror, survival; Relaxed → puzzle, simulation, casual; '
    'Competitive → MOBAs, battle royale; Creative → sandbox, city builders; '
    'Adventurous → open-world RPGs, exploration. '
    'Always end with: "Browse these in the Zenno Store!" '
    'If asked something unrelated, gently redirect to game recommendations.';

class ChatbotScreen extends StatefulWidget {
  const ChatbotScreen({super.key});

  @override
  State<ChatbotScreen> createState() => _ChatbotScreenState();
}

class _ChatbotScreenState extends State<ChatbotScreen> with TickerProviderStateMixin {
  final _messageController = TextEditingController();
  final _scrollController = ScrollController();
  final _focusNode = FocusNode();
  bool _isLoading = false;
  bool _isFocused = false;
  late AnimationController _avatarPulseController;
  late Animation<double> _avatarPulse;

  final List<Map<String, String>> _messages = [
    {
      'sender': 'bot',
      'message': "Hey Gamer! 👾 I'm ZennoBot, your personal AI game advisor.\n\nTell me how you're feeling right now and I'll find the perfect game for your mood!",
    },
  ];

  final List<Map<String, String>> _history = [];

  @override
  void initState() {
    super.initState();
    _avatarPulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
    _avatarPulse = Tween<double>(begin: 0.4, end: 1.0).animate(
      CurvedAnimation(parent: _avatarPulseController, curve: Curves.easeInOut),
    );
    _focusNode.addListener(() {
      setState(() => _isFocused = _focusNode.hasFocus);
    });
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    _focusNode.dispose();
    _avatarPulseController.dispose();
    super.dispose();
  }

  Future<void> _sendMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty || _isLoading) return;

    _messageController.clear();
    _focusNode.unfocus();
    setState(() {
      _messages.add({'sender': 'user', 'message': text});
      _isLoading = true;
    });
    _scrollToBottom();

    try {
      final reply = await _callGroq(text);
      if (mounted) {
        setState(() {
          _messages.add({'sender': 'bot', 'message': reply});
          _isLoading = false;
        });
        _scrollToBottom();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _messages.add({
            'sender': 'bot',
            'message': e.toString().replaceAll('Exception: ', ''),
          });
          _isLoading = false;
        });
      }
    }
  }

  Future<String> _callGroq(String userMessage) async {
    _history.add({'role': 'user', 'content': userMessage});

    final response = await http.post(
      Uri.parse('https://api.groq.com/openai/v1/chat/completions'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $_groqApiKey',
      },
      body: jsonEncode({
        'model': _groqModel,
        'messages': [
          {'role': 'system', 'content': _systemPrompt},
          ..._history,
        ],
        'max_tokens': 300,
        'temperature': 0.8,
      }),
    ).timeout(const Duration(seconds: 15));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final reply = data['choices']?[0]?['message']?['content'] as String? ?? 'No response';
      _history.add({'role': 'assistant', 'content': reply});
      return reply;
    } else {
      final errorData = jsonDecode(response.body) as Map<String, dynamic>;
      final msg = errorData['error']?['message'] as String? ?? 'Unknown error';
      if (response.statusCode == 429) throw Exception('Too many requests. Please wait a moment and try again.');
      if (response.statusCode == 401) throw Exception('Invalid API key. Check your Groq key.');
      throw Exception('Error ${response.statusCode}: $msg');
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 350),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kSteamBg,
      appBar: _buildAppBar(),
      body: GamingGradientBackground(
        child: Column(
          children: [
            _buildMoodBar(),
            Expanded(child: _buildMessageList()),
            _buildInputBar(),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: kSteamDark,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new, color: kSteamAccent, size: 20),
        onPressed: () => Navigator.of(context).pop(),
      ),
      title: Row(
        children: [
          // Pulsing bot avatar
          AnimatedBuilder(
            animation: _avatarPulse,
            builder: (_, _) => Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: kSteamMed,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: kSteamAccent.withValues(alpha: _avatarPulse.value * 0.6),
                    blurRadius: 14,
                    spreadRadius: 2,
                  ),
                ],
                border: Border.all(
                  color: kSteamAccent.withValues(alpha: _avatarPulse.value),
                  width: 1.5,
                ),
              ),
              child: const Icon(Icons.smart_toy, color: kSteamAccent, size: 22),
            ),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'ZENNOBOT',
                style: GoogleFonts.rajdhani(
                  color: kSteamAccent,
                  fontWeight: FontWeight.w800,
                  fontSize: 16,
                  letterSpacing: 2.5,
                ),
              ),
              Row(
                children: [
                  Container(
                    width: 7,
                    height: 7,
                    decoration: BoxDecoration(
                      color: kSteamGreen,
                      shape: BoxShape.circle,
                      boxShadow: [BoxShadow(color: kSteamGreen.withValues(alpha: 0.7), blurRadius: 4)],
                    ),
                  ),
                  const SizedBox(width: 5),
                  Text(
                    'Online • AI Game Advisor',
                    style: GoogleFonts.rajdhani(color: kSteamSubtext, fontSize: 11, letterSpacing: 0.5),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 12),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: kSteamMed,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: kSteamAccent.withValues(alpha: 0.3)),
            ),
            child: Text(
              'AI',
              style: GoogleFonts.rajdhani(color: kSteamAccent, fontSize: 11, fontWeight: FontWeight.w800, letterSpacing: 1),
            ),
          ),
        ),
      ],
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Container(
          height: 1,
          decoration: const BoxDecoration(
            gradient: LinearGradient(colors: [Colors.transparent, kSteamAccent, Colors.transparent]),
          ),
        ),
      ),
    );
  }

  Widget _buildMoodBar() {
    final moods = [
      ('😊', 'Happy', 'I am feeling happy and energetic!', const Color(0xFFFFD700)),
      ('😢', 'Sad', 'I am feeling sad and lonely', kSteamAccent),
      ('😱', 'Scared', 'I want something scary and thrilling', const Color(0xFFFF6B6B)),
      ('😴', 'Chill', 'I want something chill and relaxing', kSteamGreen),
      ('⚔️', 'Epic', 'I want an epic adventure', const Color(0xFFFF8C00)),
      ('🏆', 'Compete', 'I want something competitive', const Color(0xFFBF5FFF)),
    ];

    return Container(
      decoration: BoxDecoration(
        color: kSteamDark,
        border: const Border(bottom: BorderSide(color: kSteamMed, width: 1)),
      ),
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 6),
            child: Text(
              'HOW ARE YOU FEELING?',
              style: GoogleFonts.rajdhani(color: kSteamSubtext, fontSize: 10, letterSpacing: 1.5, fontWeight: FontWeight.w700),
            ),
          ),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: moods.map((mood) {
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: GestureDetector(
                    onTap: () {
                      _messageController.text = mood.$3;
                      _sendMessage();
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [kSteamMed, kSteamDark],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: mood.$4.withValues(alpha: 0.5), width: 1.2),
                        boxShadow: [BoxShadow(color: mood.$4.withValues(alpha: 0.2), blurRadius: 6)],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(mood.$1, style: const TextStyle(fontSize: 14)),
                          const SizedBox(width: 5),
                          Text(
                            mood.$2,
                            style: GoogleFonts.rajdhani(color: mood.$4, fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: 0.5),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageList() {
    return Stack(
      children: [
        // Subtle circuit-board pattern overlay
        Positioned.fill(
          child: CustomPaint(painter: _CircuitPainter()),
        ),
        ListView.builder(
          controller: _scrollController,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
          itemCount: _messages.length + (_isLoading ? 1 : 0),
          itemBuilder: (context, index) {
            if (index == _messages.length) return const _TypingIndicator();
            final msg = _messages[index];
            final isUser = msg['sender'] == 'user';
            return _buildMessage(msg['message']!, isUser, index);
          },
        ),
      ],
    );
  }

  Widget _buildMessage(String message, bool isUser, int index) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
      builder: (_, value, child) => Opacity(
        opacity: value,
        child: Transform.translate(
          offset: Offset(isUser ? 20 * (1 - value) : -20 * (1 - value), 0),
          child: child,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: Row(
          mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            if (!isUser) ...[
              _botAvatar(),
              const SizedBox(width: 8),
            ],
            Flexible(
              child: Container(
                constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.72),
                decoration: BoxDecoration(
                  gradient: isUser
                      ? const LinearGradient(
                          colors: [kSteamMed, Color(0xFF1e3a4f)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        )
                      : const LinearGradient(
                          colors: [Color(0xFF1b2838), Color(0xFF16202d)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                  borderRadius: BorderRadius.only(
                    topLeft: const Radius.circular(16),
                    topRight: const Radius.circular(16),
                    bottomLeft: Radius.circular(isUser ? 16 : 4),
                    bottomRight: Radius.circular(isUser ? 4 : 16),
                  ),
                  border: Border.all(
                    color: isUser ? kSteamAccent.withValues(alpha: 0.4) : kSteamMed.withValues(alpha: 0.8),
                    width: 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: isUser ? kSteamAccent.withValues(alpha: 0.12) : Colors.black.withValues(alpha: 0.3),
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (!isUser)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                        decoration: BoxDecoration(
                          color: kSteamAccent.withValues(alpha: 0.08),
                          borderRadius: const BorderRadius.only(topLeft: Radius.circular(16), topRight: Radius.circular(16)),
                          border: const Border(bottom: BorderSide(color: kSteamMed, width: 0.5)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.smart_toy, color: kSteamAccent, size: 11),
                            const SizedBox(width: 4),
                            Text(
                              'ZennoBot',
                              style: GoogleFonts.rajdhani(color: kSteamAccent, fontSize: 10, fontWeight: FontWeight.w700, letterSpacing: 1),
                            ),
                          ],
                        ),
                      ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      child: Text(
                        message,
                        style: GoogleFonts.rajdhani(
                          color: isUser ? kSteamText : const Color(0xFFd0dce8),
                          fontSize: 14,
                          height: 1.5,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (isUser) ...[
              const SizedBox(width: 8),
              _userAvatar(),
            ],
          ],
        ),
      ),
    );
  }

  Widget _botAvatar() {
    return Container(
      width: 30,
      height: 30,
      decoration: BoxDecoration(
        color: kSteamMed,
        shape: BoxShape.circle,
        border: Border.all(color: kSteamAccent.withValues(alpha: 0.5), width: 1),
        boxShadow: [BoxShadow(color: kSteamAccent.withValues(alpha: 0.2), blurRadius: 6)],
      ),
      child: const Icon(Icons.smart_toy, color: kSteamAccent, size: 16),
    );
  }

  Widget _userAvatar() {
    return Container(
      width: 30,
      height: 30,
      decoration: BoxDecoration(
        color: kSteamMed,
        shape: BoxShape.circle,
        border: Border.all(color: kSteamAccent.withValues(alpha: 0.4), width: 1),
      ),
      child: const Icon(Icons.person, color: kSteamSubtext, size: 16),
    );
  }

  Widget _buildInputBar() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      decoration: BoxDecoration(
        color: kSteamDark,
        border: Border(
          top: BorderSide(
            color: _isFocused ? kSteamAccent.withValues(alpha: 0.5) : kSteamMed,
            width: _isFocused ? 1.5 : 1,
          ),
        ),
        boxShadow: _isFocused
            ? [BoxShadow(color: kSteamAccent.withValues(alpha: 0.08), blurRadius: 16, offset: const Offset(0, -4))]
            : [],
      ),
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: kSteamBg,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: _isFocused ? kSteamAccent.withValues(alpha: 0.6) : kSteamMed,
                    width: 1.2,
                  ),
                  boxShadow: _isFocused
                      ? [BoxShadow(color: kSteamAccent.withValues(alpha: 0.12), blurRadius: 8)]
                      : [],
                ),
                child: Row(
                  children: [
                    const SizedBox(width: 14),
                    const Icon(Icons.gamepad_outlined, color: kSteamSubtext, size: 18),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        controller: _messageController,
                        focusNode: _focusNode,
                        style: GoogleFonts.rajdhani(color: kSteamText, fontSize: 14),
                        decoration: InputDecoration(
                          hintText: 'Tell me your mood...',
                          hintStyle: GoogleFonts.rajdhani(color: kSteamSubtext, fontSize: 13),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        onSubmitted: (_) => _sendMessage(),
                      ),
                    ),
                    const SizedBox(width: 8),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 10),
            GestureDetector(
              onTap: _isLoading ? null : _sendMessage,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: _isLoading
                        ? [kSteamMed, kSteamMed]
                        : [kSteamAccent.withValues(alpha: 0.9), kSteamMed],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: _isLoading ? kSteamMed : kSteamAccent,
                    width: 1.5,
                  ),
                  boxShadow: _isLoading
                      ? []
                      : [BoxShadow(color: kSteamAccent.withValues(alpha: 0.4), blurRadius: 12, spreadRadius: 1)],
                ),
                child: Icon(
                  _isLoading ? Icons.hourglass_empty : Icons.send_rounded,
                  color: _isLoading ? kSteamSubtext : kSteamDark,
                  size: 20,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Animated typing dots ──────────────────────────────────────────────────────

class _TypingIndicator extends StatefulWidget {
  const _TypingIndicator();

  @override
  State<_TypingIndicator> createState() => _TypingIndicatorState();
}

class _TypingIndicatorState extends State<_TypingIndicator> with TickerProviderStateMixin {
  late List<AnimationController> _controllers;
  late List<Animation<double>> _animations;

  @override
  void initState() {
    super.initState();
    _controllers = List.generate(3, (i) => AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    ));
    _animations = _controllers.map((c) => Tween<double>(begin: 0, end: -8).animate(
      CurvedAnimation(parent: c, curve: Curves.easeInOut),
    )).toList();

    for (int i = 0; i < 3; i++) {
      Future.delayed(Duration(milliseconds: i * 160), () {
        if (mounted) _controllers[i].repeat(reverse: true);
      });
    }
  }

  @override
  void dispose() {
    for (final c in _controllers) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // Bot avatar
          Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              color: kSteamMed,
              shape: BoxShape.circle,
              border: Border.all(color: kSteamAccent.withValues(alpha: 0.5), width: 1),
              boxShadow: [BoxShadow(color: kSteamAccent.withValues(alpha: 0.2), blurRadius: 6)],
            ),
            child: const Icon(Icons.smart_toy, color: kSteamAccent, size: 16),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF1b2838), Color(0xFF16202d)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
                bottomRight: Radius.circular(16),
                bottomLeft: Radius.circular(4),
              ),
              border: Border.all(color: kSteamMed.withValues(alpha: 0.8)),
              boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.3), blurRadius: 10, offset: const Offset(0, 3))],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: List.generate(3, (i) {
                return AnimatedBuilder(
                  animation: _animations[i],
                  builder: (_, _) => Transform.translate(
                    offset: Offset(0, _animations[i].value),
                    child: Container(
                      width: 7,
                      height: 7,
                      margin: const EdgeInsets.symmetric(horizontal: 3),
                      decoration: BoxDecoration(
                        color: i == 0
                            ? kSteamAccent
                            : i == 1
                                ? kSteamAccent.withValues(alpha: 0.7)
                                : kSteamAccent.withValues(alpha: 0.4),
                        shape: BoxShape.circle,
                        boxShadow: [BoxShadow(color: kSteamAccent.withValues(alpha: 0.5), blurRadius: 4)],
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Subtle circuit-board background painter ───────────────────────────────────

class _CircuitPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF66c0f4).withValues(alpha: 0.025)
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;

    final rng = Random(42);
    for (int i = 0; i < 12; i++) {
      final x = rng.nextDouble() * size.width;
      final y = rng.nextDouble() * size.height;
      final len = 40.0 + rng.nextDouble() * 80;
      final isHoriz = rng.nextBool();
      canvas.drawLine(
        Offset(x, y),
        Offset(isHoriz ? x + len : x, isHoriz ? y : y + len),
        paint,
      );
      canvas.drawCircle(Offset(isHoriz ? x + len : x, isHoriz ? y : y + len), 2.5, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
