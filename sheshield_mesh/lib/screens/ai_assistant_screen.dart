import 'dart:async';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';
import '../providers/app_provider.dart';
import '../models/models.dart';
import '../services/ai_voice_service.dart';

class AiAssistantScreen extends StatefulWidget {
  const AiAssistantScreen({super.key});

  @override
  State<AiAssistantScreen> createState() => _AiAssistantScreenState();
}

class _AiAssistantScreenState extends State<AiAssistantScreen>
    with TickerProviderStateMixin {
  final AiVoiceService _voiceService = AiVoiceService();
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _textController = TextEditingController();

  late AnimationController _waveformController;
  late AnimationController _micGlowController;

  bool _isListening = false;
  bool _isSpeaking = false;
  bool _isTyping = false;
  String _currentStatusText = "Aria is ready to help";
  String _simulatedSpeechResult = "";

  // Voice wave status
  // 0 = idle, 1 = listening, 2 = speaking
  int _waveState = 0;

  @override
  void initState() {
    super.initState();

    _waveformController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();

    _micGlowController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);

    // Initialize voice services
    _initVoice();

    // Scroll to bottom after layout
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToBottom();
      _introduceIfEmpty();
    });
  }

  Future<void> _initVoice() async {
    await _voiceService.initialize();
  }

  void _introduceIfEmpty() {
    if (_voiceService.memory.isEmpty) {
      setState(() {
        _isSpeaking = true;
        _waveState = 2;
        _currentStatusText = "Aria is speaking...";
      });

      final greeting = "Hi, I'm Aria, your offline safety assistant. I can guide you through emergency steps or check your SOS relay status. Speak or choose a question below.";
      
      _voiceService.generateGemma3nResponse("hello", _getSosStatus());
      
      _voiceService.speak(
        greeting,
        onStart: () {
          if (mounted) {
            setState(() {
              _isSpeaking = true;
              _waveState = 2;
              _currentStatusText = "Aria is speaking...";
            });
          }
        },
        onComplete: () {
          if (mounted) {
            setState(() {
              _isSpeaking = false;
              _waveState = 0;
              _currentStatusText = "Aria is listening/idle";
            });
          }
        },
      );
    }
  }

  String? _getSosStatus() {
    final provider = context.read<AppProvider>();
    return provider.currentAlert?.status;
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      Timer(const Duration(milliseconds: 100), () {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      });
    }
  }

  @override
  void dispose() {
    _waveformController.dispose();
    _micGlowController.dispose();
    _scrollController.dispose();
    _textController.dispose();
    _voiceService.stopSpeaking();
    super.dispose();
  }

  // Handle User Input Submission (both text and speech)
  void _handleInput(String input) {
    if (input.trim().isEmpty) return;

    _voiceService.stopSpeaking();

    setState(() {
      _isTyping = true;
      _currentStatusText = "Gemma 3n is thinking...";
    });
    _scrollToBottom();

    // Process with Gemma 3n
    final sosStatus = _getSosStatus();
    final response = _voiceService.generateGemma3nResponse(input, sosStatus);

    // Simulate small local latency
    Future.delayed(const Duration(milliseconds: 800), () {
      if (!mounted) return;
      setState(() {
        _isTyping = false;
      });
      _scrollToBottom();

      // Speak response using TTS
      _voiceService.speak(
        response,
        onStart: () {
          if (mounted) {
            setState(() {
              _isSpeaking = true;
              _waveState = 2;
              _currentStatusText = "Aria is speaking...";
            });
          }
        },
        onComplete: () {
          if (mounted) {
            setState(() {
              _isSpeaking = false;
              _waveState = 0;
              _currentStatusText = "Aria is ready";
            });
          }
        },
      );
    });
  }

  // Voice trigger
  void _toggleListening() async {
    _voiceService.stopSpeaking();

    if (_isListening) {
      // Stop listening
      await _voiceService.stopListening();
      setState(() {
        _isListening = false;
        _waveState = 0;
        _currentStatusText = "Aria is ready";
      });
    } else {
      // Start listening
      setState(() {
        _isListening = true;
        _waveState = 1;
        _currentStatusText = "Listening...";
      });

      // Force mock simulation on web due to browser microphone sandbox limits
      if (_voiceService.isSpeechAvailable && !kIsWeb) {
        try {
          await _voiceService.startListening(
            onResult: (text) {
              if (mounted) {
                setState(() {
                  _isListening = false;
                  _waveState = 0;
                });
                _handleInput(text);
              }
            },
            onStop: () {
              if (mounted) {
                setState(() {
                  _isListening = false;
                  _waveState = 0;
                });
              }
            },
          );
        } catch (e) {
          debugPrint("Failed to start voice listening: $e");
          if (mounted) {
            setState(() {
              _isListening = false;
              _waveState = 0;
              _currentStatusText = "Aria is ready";
            });
            _showSimulatedVoiceDialog();
          }
        }
      } else {
        // Fallback: Show choices for simulating voice
        setState(() {
          _isListening = false;
          _waveState = 0;
          _currentStatusText = "Aria is ready";
        });
        _showSimulatedVoiceDialog();
      }
    }
  }

  // Simulation voice trigger modal
  void _showSimulatedVoiceDialog() {
    final sampleQuestions = [
      "I am scared.",
      "Has my SOS been sent?",
      "What should I do now?",
      "How can I reach a safe location?",
      "What happens after SOS?",
    ];

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.keyboard_voice_rounded, color: AppColors.primary),
                  const SizedBox(width: 10),
                  Text(
                    'Simulate Speech Input',
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppColors.ink,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'Microphone is unavailable/blocked (or running on web demo). Select a query to simulate speaking it to Aria:',
                style: GoogleFonts.inter(fontSize: 12, color: AppColors.muted),
              ),
              const SizedBox(height: 16),
              ...sampleQuestions.map((q) {
                return ListTile(
                  title: Text(
                    q,
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary,
                    ),
                  ),
                  trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14),
                  onTap: () {
                    Navigator.of(ctx).pop();
                    // Animate microphone listening simulation
                    setState(() {
                      _isListening = true;
                      _waveState = 1;
                      _currentStatusText = "Aria is listening...";
                    });
                    
                    Future.delayed(const Duration(milliseconds: 1500), () {
                      if (mounted) {
                        setState(() {
                          _isListening = false;
                          _waveState = 0;
                          _currentStatusText = "Aria is ready";
                        });
                        _handleInput(q);
                      }
                    });
                  },
                );
              }),
              const SizedBox(height: 12),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    final activeAlert = provider.currentAlert;
    final messages = _voiceService.memory;

    return Scaffold(
      backgroundColor: Colors.white, // White background
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.ink),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Row(
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: const BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              'Aria Safety AI',
              style: GoogleFonts.inter(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: AppColors.ink,
                letterSpacing: -0.5,
              ),
            ),
          ],
        ),
        actions: [
          // Offline Badge at top
          Container(
            margin: const EdgeInsets.only(right: 16),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.primaryLight,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.primary.withOpacity(0.2)),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.wifi_off_rounded,
                  size: 11,
                  color: AppColors.primary,
                ),
                const SizedBox(width: 4),
                Text(
                  'Offline Mode',
                  style: GoogleFonts.inter(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Active SOS status header banner (if active alert exists)
            if (activeAlert != null) _buildActiveSosStatusCard(activeAlert),

            // Chat area
            Expanded(
              child: messages.isEmpty
                  ? _buildEmptyState()
                  : ListView.builder(
                      controller: _scrollController,
                      padding: const EdgeInsets.all(16),
                      itemCount: messages.length + (_isTyping ? 1 : 0),
                      itemBuilder: (context, index) {
                        if (index == messages.length && _isTyping) {
                          return _buildTypingIndicator();
                        }
                        final message = messages[index];
                        final isUser = message.role == 'user';
                        return _buildChatBubble(message.text, isUser);
                      },
                    ),
            ),

            // Sound Waveform Animation Area
            _buildWaveformArea(),

            // Text status indicator
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Text(
                _currentStatusText,
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.muted,
                ),
              ),
            ),

            // Large microphone button & manual keyboard trigger
            _buildActionFooter(),

            // Device running status message
            Padding(
              padding: const EdgeInsets.only(bottom: 12, top: 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.memory_rounded,
                    size: 12,
                    color: AppColors.mutedSoft,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Running Locally · No Internet Required',
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: AppColors.mutedSoft,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Custom Active SOS status card
  Widget _buildActiveSosStatusCard(AlertModel alert) {
    Color statusColor = AppColors.primary;
    double progress = 0.25;

    switch (alert.status.toLowerCase()) {
      case 'stored offline':
        statusColor = AppColors.primary;
        progress = 0.25;
        break;
      case 'relay in progress':
        statusColor = const Color(0xFF8B5CF6);
        progress = 0.6;
        break;
      case 'connectivity found':
        statusColor = AppColors.warning;
        progress = 0.8;
        break;
      case 'delivered':
        statusColor = AppColors.success;
        progress = 1.0;
        break;
    }

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: statusColor.withOpacity(0.06),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: statusColor.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              AnimatedBuilder(
                animation: _micGlowController,
                builder: (context, child) {
                  return Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(
                        alert.status.toLowerCase() == 'delivered' ? 1.0 : 0.4 + _micGlowController.value * 0.6,
                      ),
                      shape: BoxShape.circle,
                    ),
                  );
                },
              ),
              const SizedBox(width: 8),
              Text(
                'Active SOS Status: ${alert.status}',
                style: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: statusColor,
                ),
              ),
              const Spacer(),
              Text(
                'Relays: ${alert.relayCount}',
                style: GoogleFonts.inter(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: AppColors.muted,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 4,
              backgroundColor: AppColors.hairlineSoft,
              valueColor: AlwaysStoppedAnimation<Color>(statusColor),
            ),
          ),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  'ID: ${alert.id} · Loc: ${alert.location}',
                  style: GoogleFonts.inter(
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                    color: AppColors.muted,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (alert.status.toLowerCase() == 'delivered')
                GestureDetector(
                  onTap: () {
                    context.read<AppProvider>().clearCurrentAlert();
                    Navigator.of(context).pushReplacementNamed('/home');
                  },
                  child: Text(
                    'Dismiss SOS',
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: AppColors.success,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: AppColors.primaryLight,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.shield_rounded,
              color: AppColors.primary,
              size: 32,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Aria Safety Assistant',
            style: GoogleFonts.inter(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: AppColors.ink,
            ),
          ),
          const SizedBox(height: 6),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Text(
              'Gemma 3n running locally to protect you when offline. Tap microphone to speak, or type your question below.',
              style: GoogleFonts.inter(
                fontSize: 13,
                color: AppColors.muted,
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChatBubble(String text, bool isUser) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          if (!isUser) ...[
            Container(
              width: 28,
              height: 28,
              decoration: const BoxDecoration(
                color: AppColors.primaryLight,
                shape: BoxShape.circle,
              ),
              child: const Center(
                child: Icon(Icons.shield_rounded, color: AppColors.primary, size: 14),
              ),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: isUser ? Colors.white : AppColors.primaryLight,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(16),
                  topRight: const Radius.circular(16),
                  bottomLeft: isUser ? const Radius.circular(16) : Radius.zero,
                  bottomRight: isUser ? Radius.zero : const Radius.circular(16),
                ),
                border: isUser ? Border.all(color: AppColors.hairline) : null,
              ),
              child: Text(
                text,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: isUser ? FontWeight.w500 : FontWeight.w600,
                  color: isUser ? AppColors.ink : AppColors.primaryDark,
                  height: 1.4,
                ),
              ),
            ),
          ),
          if (isUser) ...[
            const SizedBox(width: 8),
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: AppColors.hairlineSoft,
                shape: BoxShape.circle,
              ),
              child: const Center(
                child: Icon(Icons.person_rounded, color: AppColors.body, size: 14),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTypingIndicator() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: const BoxDecoration(
              color: AppColors.primaryLight,
              shape: BoxShape.circle,
            ),
            child: const Center(
              child: Icon(Icons.shield_rounded, color: AppColors.primary, size: 14),
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: const BoxDecoration(
              color: AppColors.primaryLight,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
                bottomRight: Radius.circular(16),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: List.generate(3, (i) {
                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 2),
                  width: 6,
                  height: 6,
                  decoration: const BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }

  // Waveform drawing
  Widget _buildWaveformArea() {
    return Container(
      height: 60,
      width: double.infinity,
      alignment: Alignment.center,
      child: AnimatedBuilder(
        animation: _waveformController,
        builder: (context, _) {
          return CustomPaint(
            size: const Size(200, 50),
            painter: WaveformPainter(
              waveState: _waveState,
              animationValue: _waveformController.value,
            ),
          );
        },
      ),
    );
  }

  Widget _buildActionFooter() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Row(
        children: [
          // Keyboard manual input trigger
          Expanded(
            child: Container(
              height: 48,
              decoration: BoxDecoration(
                color: AppColors.surfaceSoft,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: AppColors.hairline),
              ),
              child: Row(
                children: [
                  const SizedBox(width: 14),
                  Expanded(
                    child: TextField(
                      controller: _textController,
                      onSubmitted: (val) {
                        if (val.trim().isNotEmpty) {
                          _textController.clear();
                          _handleInput(val);
                        }
                      },
                      style: GoogleFonts.inter(fontSize: 14, color: AppColors.ink),
                      decoration: const InputDecoration(
                        hintText: "Type a question...",
                        hintStyle: TextStyle(color: AppColors.mutedSoft),
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        contentPadding: EdgeInsets.zero,
                        filled: false,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.send_rounded, color: AppColors.primary, size: 18),
                    onPressed: () {
                      final val = _textController.text;
                      if (val.trim().isNotEmpty) {
                        _textController.clear();
                        _handleInput(val);
                      }
                    },
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 12),

          // Microhpone voice trigger button
          GestureDetector(
            onTap: _toggleListening,
            child: AnimatedBuilder(
              animation: _micGlowController,
              builder: (context, child) {
                return Container(
                  width: 54,
                  height: 54,
                  decoration: BoxDecoration(
                    color: _isListening ? AppColors.error : AppColors.primary,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: (_isListening ? AppColors.error : AppColors.primary).withOpacity(
                          0.2 + _micGlowController.value * 0.3,
                        ),
                        blurRadius: 10 + _micGlowController.value * 10,
                        spreadRadius: 2 + _micGlowController.value * 4,
                      ),
                    ],
                  ),
                  child: Icon(
                    _isListening ? Icons.stop_rounded : Icons.mic_rounded,
                    color: Colors.white,
                    size: 26,
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// Waveform painter
class WaveformPainter extends CustomPainter {
  final int waveState; // 0 = idle, 1 = listening, 2 = speaking
  final double animationValue;

  WaveformPainter({required this.waveState, required this.animationValue});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 3;

    final double midY = size.height / 2;
    final int barCount = 19;
    final double spacing = size.width / (barCount - 1);

    for (int i = 0; i < barCount; i++) {
      double amplitude = 3;
      double frequencyMultiplier = 1.0;

      if (waveState == 1) {
        // Listening - chaotic high amplitude waves
        amplitude = 12 + sin((animationValue * 2 * pi) + (i * 0.7)) * 12;
        paint.color = AppColors.error.withOpacity(0.8);
      } else if (waveState == 2) {
        // Speaking - smooth flowing sine wave
        amplitude = 6 + sin((animationValue * 2 * pi) + (i * 0.4)) * 14;
        paint.color = AppColors.primary.withOpacity(0.8);
      } else {
        // Idle - flat line with tiny movement
        amplitude = 2 + sin((animationValue * 2 * pi) + (i * 0.2)) * 1.5;
        paint.color = AppColors.mutedSoft.withOpacity(0.5);
      }

      // Mirror the bars around center
      double distanceToCenter = (i - (barCount - 1) / 2).abs() / ((barCount - 1) / 2);
      // Reduce height near edges
      double heightFactor = (1.0 - distanceToCenter).clamp(0.2, 1.0);
      double barHeight = amplitude * heightFactor;

      double x = i * spacing;
      canvas.drawLine(
        Offset(x, midY - barHeight),
        Offset(x, midY + barHeight),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant WaveformPainter oldDelegate) {
    return oldDelegate.waveState != waveState || oldDelegate.animationValue != animationValue;
  }
}
