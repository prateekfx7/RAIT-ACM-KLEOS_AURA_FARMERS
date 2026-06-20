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
  bool _isTyping = false;
  String _currentStatusText = "Aria is ready to help";

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
    if (mounted) {
      setState(() {
        final isHindi = _voiceService.currentLanguageCode.startsWith("hi");
        _currentStatusText = isHindi ? "आरिया मदद के लिए तैयार है" : "Aria is ready to help";
      });
    }
  }

  void _introduceIfEmpty() {
    final isHindi = _voiceService.currentLanguageCode.startsWith("hi");
    if (_voiceService.memory.isEmpty) {
      setState(() {
        _waveState = 2;
        _currentStatusText = isHindi ? "आरिया बोल रही है..." : "Aria is speaking...";
      });

      final greeting = isHindi
          ? "नमस्ते, मैं आरिया हूँ, आपकी ऑफलाइन सुरक्षा सहायक। मैं आपातकालीन चरणों में आपका मार्गदर्शन कर सकती हूँ या आपके एसओएस रिले की स्थिति की जांच कर सकती हूँ। बोलें या नीचे दिए गए प्रश्नों में से चुनें।"
          : "Hi, I'm Aria, your offline safety assistant. I can guide you through emergency steps or check your SOS relay status. Speak or choose a question below.";
      
      _voiceService.generateGemma3nResponse(isHindi ? "नमस्ते" : "hello", _getSosStatus());
      
      _voiceService.speak(
        greeting,
        onStart: () {
          if (mounted) {
            setState(() {
              _waveState = 2;
              _currentStatusText = isHindi ? "आरिया बोल रही है..." : "Aria is speaking...";
            });
          }
        },
        onComplete: () {
          if (mounted) {
            setState(() {
              _waveState = 0;
              _currentStatusText = isHindi ? "आरिया तैयार है" : "Aria is ready/idle";
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
    final isHindi = _voiceService.currentLanguageCode.startsWith("hi");

    setState(() {
      _isTyping = true;
      _currentStatusText = isHindi ? "जेम्मा ३एन सोच रहा है..." : "Gemma 3n is thinking...";
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
              _waveState = 2;
              _currentStatusText = isHindi ? "आरिया बोल रही है..." : "Aria is speaking...";
            });
          }
        },
        onComplete: () {
          if (mounted) {
            setState(() {
              _waveState = 0;
              _currentStatusText = isHindi ? "आरिया तैयार है" : "Aria is ready";
            });
          }
        },
      );
    });
  }

  // Voice trigger
  void _toggleListening() async {
    _voiceService.stopSpeaking();
    final isHindi = _voiceService.currentLanguageCode.startsWith("hi");

    if (_isListening) {
      // Stop listening
      await _voiceService.stopListening();
      setState(() {
        _isListening = false;
        _waveState = 0;
        _currentStatusText = isHindi ? "आरिया तैयार है" : "Aria is ready";
      });
    } else {
      // Start listening
      setState(() {
        _isListening = true;
        _waveState = 1;
        _currentStatusText = isHindi ? "सुन रहा हूँ..." : "Listening...";
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
              _currentStatusText = isHindi ? "आरिया तैयार है" : "Aria is ready";
            });
            _showSimulatedVoiceDialog();
          }
        }
      } else {
        // Fallback: Show choices for simulating voice
        setState(() {
          _isListening = false;
          _waveState = 0;
          _currentStatusText = isHindi ? "आरिया तैयार है" : "Aria is ready";
        });
        _showSimulatedVoiceDialog();
      }
    }
  }

  // Simulation voice trigger modal
  void _showSimulatedVoiceDialog() {
    final isHindi = _voiceService.currentLanguageCode.startsWith("hi");
    final sampleQuestions = isHindi
        ? [
            "मुझे डर लग रहा है।",
            "क्या मेरा एसओएस भेजा गया है?",
            "मुझे अब क्या करना चाहिए?",
            "सुरक्षित जगह कैसे पहुँचें?",
            "एसओएस के बाद क्या होता है?",
          ]
        : [
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
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
              Row(
                children: [
                  const Icon(Icons.keyboard_voice_rounded, color: AppColors.primary),
                  const SizedBox(width: 10),
                  Text(
                    isHindi ? 'आवाज इनपुट का अनुकरण करें' : 'Simulate Speech Input',
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
                isHindi
                    ? 'माइक्रोफोन अनुपलब्ध/अवरुद्ध है। आरिया से बात करने का अनुकरण करने के लिए एक प्रश्न चुनें:'
                    : 'Microphone is unavailable/blocked (or running on web demo). Select a query to simulate speaking it to Aria:',
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
                      _currentStatusText = isHindi ? "आरिया सुन रही है..." : "Aria is listening...";
                    });
                    
                    Future.delayed(const Duration(milliseconds: 1500), () {
                      if (mounted) {
                        setState(() {
                          _isListening = false;
                          _waveState = 0;
                          _currentStatusText = isHindi ? "आरिया तैयार है" : "Aria is ready";
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
        ),
      );
    },
    );
  }

  // Language Selector bar
  Widget _buildLanguageSelector() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildLanguageChip("en-US", "🇬🇧 English"),
          const SizedBox(width: 12),
          _buildLanguageChip("hi-IN", "🇮🇳 हिन्दी"),
        ],
      ),
    );
  }

  Widget _buildLanguageChip(String langCode, String label) {
    final isSelected = _voiceService.currentLanguageCode == langCode;
    return GestureDetector(
      onTap: () async {
        await _voiceService.setLanguage(langCode);
        
        // Reset greeting and introductory messages if memory is empty or only contains the first hello response
        if (_voiceService.memory.isEmpty || _voiceService.memory.length <= 2) {
          _voiceService.clearMemory();
          _introduceIfEmpty();
        } else {
          setState(() {
            _currentStatusText = langCode.startsWith("hi")
                ? "भाषा बदलकर हिन्दी कर दी गई है"
                : "Language switched to English";
          });
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.greenMain : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.ink, width: 1.5),
          boxShadow: isSelected
              ? null
              : const [
                  BoxShadow(
                    color: AppColors.ink,
                    blurRadius: 0,
                    offset: Offset(2, 2),
                  )
                ],
        ),
        child: Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 12,
            fontWeight: FontWeight.w800,
            color: AppColors.ink,
          ),
        ),
      ),
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
              color: AppColors.greenLight,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.ink, width: 1),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.wifi_off_rounded,
                  size: 11,
                  color: AppColors.greenDarker,
                ),
                const SizedBox(width: 4),
                Text(
                  _voiceService.currentLanguageCode.startsWith("hi") ? 'ऑफलाइन मोड' : 'Offline Mode',
                  style: GoogleFonts.inter(
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                    color: AppColors.greenDarker,
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

            // Language Selector Bar
            _buildLanguageSelector(),

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
                    _voiceService.currentLanguageCode.startsWith("hi")
                        ? 'स्थानीय रूप से सक्रिय · इंटरनेट की आवश्यकता नहीं'
                        : 'Running Locally · No Internet Required',
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
    Color statusBg = AppColors.white;
    Color statusAccent = AppColors.ink;
    double progress = 0.25;

    switch (alert.status.toLowerCase()) {
      case 'stored offline':
        statusBg = AppColors.redLight;
        statusAccent = AppColors.redMain;
        progress = 0.25;
        break;
      case 'relay in progress':
        statusBg = const Color(0xFFF3E8FF);
        statusAccent = const Color(0xFF8B5CF6);
        progress = 0.6;
        break;
      case 'connectivity found':
        statusBg = AppColors.redLight;
        statusAccent = AppColors.redMain;
        progress = 0.8;
        break;
      case 'delivered':
        statusBg = AppColors.greenLight;
        statusAccent = AppColors.greenText;
        progress = 1.0;
        break;
    }

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: statusBg,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.ink, width: 1.5),
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
                      color: statusAccent.withValues(
                        alpha: alert.status.toLowerCase() == 'delivered' ? 1.0 : 0.4 + _micGlowController.value * 0.6,
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
                  fontWeight: FontWeight.w900,
                  color: AppColors.ink,
                ),
              ),
              const Spacer(),
              Text(
                'Relays: ${alert.relayCount}',
                style: GoogleFonts.inter(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: AppColors.ink,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Container(
            height: 6,
            decoration: BoxDecoration(
              color: AppColors.canvas,
              borderRadius: BorderRadius.circular(3),
              border: Border.all(color: AppColors.ink, width: 1),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(2),
              child: LinearProgressIndicator(
                value: progress,
                backgroundColor: Colors.transparent,
                valueColor: AlwaysStoppedAnimation<Color>(statusAccent),
                minHeight: 6,
              ),
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
                    fontWeight: FontWeight.w700,
                    color: AppColors.textMuted,
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
                      fontWeight: FontWeight.w900,
                      color: AppColors.redMain,
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
    final isHindi = _voiceService.currentLanguageCode.startsWith("hi");
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: AppColors.greenMain,
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.ink, width: 1.5),
            ),
            child: const Icon(
              Icons.shield_rounded,
              color: AppColors.ink,
              size: 32,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            isHindi ? 'आरिया सुरक्षा सहायक' : 'Aria Safety Assistant',
            style: GoogleFonts.inter(
              fontSize: 18,
              fontWeight: FontWeight.w900,
              color: AppColors.ink,
            ),
          ),
          const SizedBox(height: 6),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Text(
              isHindi
                  ? 'जेम्मा ३एन आपके डिवाइस पर ऑफलाइन काम कर रहा है। बोलने के लिए माइक दबाएं, या नीचे प्रश्न टाइप करें।'
                  : 'Gemma 3n running locally to protect you when offline. Tap microphone to speak, or type your question below.',
              style: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: AppColors.textMuted,
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
              decoration: BoxDecoration(
                color: AppColors.greenMain,
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.ink, width: 1),
              ),
              child: const Center(
                child: Icon(Icons.shield_rounded, color: AppColors.ink, size: 14),
              ),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: isUser ? Colors.white : AppColors.greenLight,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(16),
                  topRight: const Radius.circular(16),
                  bottomLeft: isUser ? const Radius.circular(16) : Radius.zero,
                  bottomRight: isUser ? Radius.zero : const Radius.circular(16),
                ),
                border: Border.all(color: AppColors.ink, width: 1.5),
              ),
              child: Text(
                text,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppColors.ink,
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
                color: AppColors.canvas,
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.ink, width: 1),
              ),
              child: const Center(
                child: Icon(Icons.person_rounded, color: AppColors.ink, size: 14),
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
            decoration: BoxDecoration(
              color: AppColors.greenMain,
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.ink, width: 1),
            ),
            child: const Center(
              child: Icon(Icons.shield_rounded, color: AppColors.ink, size: 14),
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.greenLight,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
                bottomRight: Radius.circular(16),
              ),
              border: Border.all(color: AppColors.ink, width: 1.5),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: List.generate(3, (i) {
                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 2),
                  width: 6,
                  height: 6,
                  decoration: const BoxDecoration(
                    color: AppColors.greenDarker,
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
                color: AppColors.white,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: AppColors.ink, width: 1.5),
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
                      style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.ink),
                      decoration: InputDecoration(
                        hintText: _voiceService.currentLanguageCode.startsWith("hi") ? "कुछ पूछें..." : "Type a question...",
                        hintStyle: const TextStyle(color: AppColors.textLight, fontWeight: FontWeight.w700),
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        contentPadding: EdgeInsets.zero,
                        filled: false,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.send_rounded, color: AppColors.ink, size: 18),
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

          // Microphone voice trigger button
          GestureDetector(
            onTap: _toggleListening,
            child: AnimatedBuilder(
              animation: _micGlowController,
              builder: (context, child) {
                return Container(
                  width: 54,
                  height: 54,
                  decoration: BoxDecoration(
                    color: _isListening ? AppColors.redMain : AppColors.greenMain,
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.ink, width: 1.5),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.ink,
                        blurRadius: 0,
                        offset: Offset(
                          2.0 + _micGlowController.value * 2.0,
                          2.0 + _micGlowController.value * 2.0,
                        ),
                      ),
                    ],
                  ),
                  child: Icon(
                    _isListening ? Icons.stop_rounded : Icons.mic_rounded,
                    color: AppColors.ink,
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
    const int barCount = 19;
    final double spacing = size.width / (barCount - 1);

    for (int i = 0; i < barCount; i++) {
      double amplitude = 3;

      if (waveState == 1) {
        // Listening - chaotic high amplitude waves
        amplitude = 12 + sin((animationValue * 2 * pi) + (i * 0.7)) * 12;
        paint.color = AppColors.redMain;
      } else if (waveState == 2) {
        // Speaking - smooth flowing sine wave
        amplitude = 6 + sin((animationValue * 2 * pi) + (i * 0.4)) * 14;
        paint.color = AppColors.greenText;
      } else {
        // Idle - flat line with tiny movement
        amplitude = 2 + sin((animationValue * 2 * pi) + (i * 0.2)) * 1.5;
        paint.color = AppColors.textLight.withValues(alpha: 0.5);
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
