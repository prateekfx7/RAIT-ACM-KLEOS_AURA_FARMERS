import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:flutter_tts/flutter_tts.dart';

/// Gemma 3n Message representation for local memory cache (last 5-10 messages)
class GemmaMessage {
  final String role; // 'user' or 'assistant'
  final String text;
  final DateTime timestamp;

  GemmaMessage({
    required this.role,
    required this.text,
  }) : timestamp = DateTime.now();
}

class AiVoiceService {
  static final AiVoiceService _instance = AiVoiceService._internal();
  factory AiVoiceService() => _instance;
  AiVoiceService._internal();

  final stt.SpeechToText _speech = stt.SpeechToText();
  final FlutterTts _tts = FlutterTts();

  bool _isSpeechInitialized = false;
  bool _isTtsInitialized = false;
  bool _isListening = false;

  String _currentLanguageCode = "en-US";
  String get currentLanguageCode => _currentLanguageCode;

  bool get isSpeechAvailable => _isSpeechInitialized;
  bool get isTtsAvailable => _isTtsInitialized;
  bool get isListening => _isListening;

  // Local memory cache for Gemma 3n (last 5-10 messages)
  final List<GemmaMessage> _memory = [];
  List<GemmaMessage> get memory => List.unmodifiable(_memory);

  // Switch active language and re-apply voice profile
  Future<void> setLanguage(String langCode) async {
    _currentLanguageCode = langCode;
    if (_isTtsInitialized) {
      await _tts.setLanguage(langCode);
      await _applyVoiceProfileForLanguage(langCode);
    }
  }

  // Initialize service (STT and TTS)
  Future<void> initialize() async {
    // 1. Initialize TTS
    try {
      if (!_isTtsInitialized) {
        if (!kIsWeb) {
          // On mobile platforms we can set extra parameters
          await _tts.setSharedInstance(true);
        }
        
        // Basic configuration
        await _tts.setLanguage(_currentLanguageCode);
        await _tts.setSpeechRate(0.58); // Increased speech rate for more fluent and fast speech
        await _tts.setVolume(1.0);
        await _tts.setPitch(1.18); // Shift pitch up slightly for a clear tone
        
        // Search and apply appropriate voice profile
        await _applyVoiceProfileForLanguage(_currentLanguageCode);

        _isTtsInitialized = true;
        debugPrint("TTS initialized successfully with fluent voice profile.");
      }
    } catch (e) {
      debugPrint("TTS initialization failed: $e");
      _isTtsInitialized = false;
    }

    // 2. Initialize STT
    try {
      if (!_isSpeechInitialized) {
        bool available = await _speech.initialize(
          onStatus: (status) {
            debugPrint("Speech status: $status");
            if (status == 'done' || status == 'notListening') {
              _isListening = false;
            }
          },
          onError: (errorNotification) {
            debugPrint("Speech error: $errorNotification");
            _isListening = false;
          },
        );
        _isSpeechInitialized = available;
        debugPrint("STT initialized with status: $available");
      }
    } catch (e) {
      debugPrint("STT initialization failed: $e");
      _isSpeechInitialized = false;
    }
  }

  // Search and apply a voice profile from available system voices based on language code
  Future<void> _applyVoiceProfileForLanguage(String langCode) async {
    try {
      List<dynamic> voices = await _tts.getVoices;
      if (voices.isNotEmpty) {
        var selectedVoice = voices.firstWhere(
          (v) {
            final String name = (v["name"] ?? "").toString().toLowerCase();
            final String locale = (v["locale"] ?? "").toString().toLowerCase();
            
            if (langCode.startsWith("hi")) {
              // Match Hindi locales and typical Hindi voice names
              return (locale.contains("hi-") || locale == "hi") &&
                     (name.contains("lekha") ||
                      name.contains("google") ||
                      name.contains("female") ||
                      name.contains("hindi") ||
                      name.contains("hi"));
            } else {
              // Match English locales and typical premium female voice names
              return (locale.contains("en-") || locale == "en") &&
                     (name.contains("samantha") ||
                      name.contains("zira") ||
                      name.contains("female") ||
                      name.contains("karen") ||
                      name.contains("susan") ||
                      name.contains("tessa") ||
                      name.contains("google us english") ||
                      name.contains("siri"));
            }
          },
          orElse: () => null,
        );

        if (selectedVoice != null) {
          await _tts.setVoice({
            "name": selectedVoice["name"],
            "locale": selectedVoice["locale"],
          });
          debugPrint("Applied premium voice profile: ${selectedVoice['name']} for $langCode");
        } else {
          // Fallback: search just by locale
          var fallbackVoice = voices.firstWhere(
            (v) {
              final String locale = (v["locale"] ?? "").toString().toLowerCase();
              return locale.contains(langCode.substring(0, 2));
            },
            orElse: () => null,
          );
          if (fallbackVoice != null) {
            await _tts.setVoice({
              "name": fallbackVoice["name"],
              "locale": fallbackVoice["locale"],
            });
            debugPrint("Applied fallback locale voice: ${fallbackVoice['name']} for $langCode");
          }
        }
      }
    } catch (voiceErr) {
      debugPrint("Failed to set custom voice profile: $voiceErr");
    }
  }

  // Text-to-Speech speaking logic
  Future<void> speak(String text, {VoidCallback? onStart, VoidCallback? onComplete}) async {
    if (_isTtsInitialized) {
      try {
        await _tts.stop();
        _tts.setStartHandler(() {
          if (onStart != null) onStart();
        });
        _tts.setCompletionHandler(() {
          if (onComplete != null) onComplete();
        });
        _tts.setErrorHandler((msg) {
          debugPrint("TTS speaking error: $msg");
          if (onComplete != null) onComplete();
        });
        await _tts.speak(text);
      } catch (e) {
        debugPrint("TTS speak failed: $e. Using fallback simulation.");
        _fallbackSpeak(text, onStart, onComplete);
      }
    } else {
      _fallbackSpeak(text, onStart, onComplete);
    }
  }

  void _fallbackSpeak(String text, VoidCallback? onStart, VoidCallback? onComplete) {
    // Fallback simulation when TTS is not active or fails
    debugPrint("Simulating speech output for: \"$text\"");
    if (onStart != null) onStart();
    final wordCount = text.split(' ').length;
    // Adjusted word duration multiplier (170ms) to reflect the faster 0.58 speed
    final duration = Duration(milliseconds: (wordCount * 170) + 300);
    Future.delayed(duration, () {
      if (onComplete != null) onComplete();
    });
  }

  Future<void> stopSpeaking() async {
    if (_isTtsInitialized) {
      try {
        await _tts.stop();
      } catch (e) {
        debugPrint("TTS stop failed: $e");
      }
    }
  }

  // Speech-to-Text listening logic
  Future<void> startListening({
    required Function(String) onResult,
    required VoidCallback onStop,
  }) async {
    if (_isSpeechInitialized) {
      _isListening = true;
      try {
        await _speech.listen(
          onResult: (result) {
            if (result.finalResult) {
              _isListening = false;
              onResult(result.recognizedWords);
            }
          },
          localeId: _currentLanguageCode, // Direct voice capture in selected locale
          listenFor: const Duration(seconds: 12),
          pauseFor: const Duration(seconds: 4),
          cancelOnError: true,
          partialResults: false,
        );
      } catch (e) {
        debugPrint("Speech recognition start failed: $e");
        _isListening = false;
        onStop();
      }
    } else {
      debugPrint("Speech-to-Text is not active. Fallback to manual/simulated voice inputs.");
    }
  }

  Future<void> stopListening() async {
    if (_isSpeechInitialized) {
      try {
        await _speech.stop();
      } catch (e) {
        debugPrint("Speech stop failed: $e");
      }
      _isListening = false;
    }
  }

  // Gemma 3n On-Device Heuristic Engine
  // Keeps a rolling cache of the last 10 messages for lightweight on-device memory
  String generateGemma3nResponse(String userInput, String? currentSosStatus) {
    // Clean user input
    final input = userInput.toLowerCase().trim();
    final bool isHindi = _currentLanguageCode.startsWith("hi");
    String response = "";

    if (isHindi) {
      // 1. Exact match / containing match from the datasheet:
      if (input.contains("scared") || input.contains("i am scared") || input.contains("डर") || input.contains("डरा")) {
        response = "मैं समझ सकती हूँ। शांत रहें। आपका आपातकालीन अलर्ट सफलतापूर्वक बना दिया गया है। यदि आस-पास के उपकरण उपलब्ध हैं, तो कनेक्टिविटी बहाल होने तक आपके एसओएस (SOS) को आगे प्रसारित किया जा सकता है।";
      } 
      else if (input.contains("sent") || input.contains("has my sos been sent") || input.contains("is my sos sent") || input.contains("भेजा") || input.contains("गया")) {
        response = "आपका एसओएस (SOS) तैयार कर लिया गया है और इसे स्थानीय रूप से सहेज लिया गया है। वर्तमान स्थिति: प्रसारण या कनेक्टिविटी की प्रतीक्षा की जा रही है।";
      }
      else if (input.contains("what should i do") || input.contains("what should i do now") || input.contains("what to do now") || input.contains("क्या करूँ") || input.contains("क्या करना")) {
        response = "यदि सुरक्षित हो, तो किसी घनी आबादी वाले और अच्छी रोशनी वाले क्षेत्र की ओर बढ़ें। अपने फोन को अपने पास रखें और आसपास की परिस्थितियों से सावधान रहें।";
      }
      else if (input.contains("unsafe") || input.contains("i feel unsafe") || input.contains("असुरक्षित") || input.contains("खतरा")) {
        response = "मैं समझ सकती हूँ। शांत रहें। आपका आपातकालीन अलर्ट सफलतापूर्वक बना दिया गया है। यदि आस-पास के उपकरण उपलब्ध हैं, तो कनेक्टिविटी बहाल होने तक आपके एसओएस (SOS) को आगे प्रसारित किया जा सकता है।";
      }
      else if (input.contains("how can i reach") || input.contains("reach a safe location") || input.contains("safe location") || input.contains("सुरक्षित स्थान") || input.contains("सुरक्षित जगह")) {
        response = "यदि सुरक्षित हो, तो किसी घनी आबादी वाले और अच्छी रोशनी वाले क्षेत्र की ओर बढ़ें। अपने फोन को अपने पास रखें और आसपास की परिस्थितियों से सावधान रहें।";
      }
      else if (input.contains("what happens after sos") || input.contains("after sos") || input.contains("एसओएस के बाद")) {
        response = "आपका एसओएस (SOS) अलर्ट एन्क्रिप्टेड है और ब्लूटूथ के माध्यम से आस-पास के उपकरणों पर प्रसारित किया जाता है। यह एक डिवाइस से दूसरी डिवाइस पर तब तक जाता है जब तक कि किसी को इंटरनेट कनेक्टिविटी न मिल जाए ताकि आपके भरोसेमंद संपर्कों और आपातकालीन सहायकों को सूचित किया जा सके।";
      }
      // 2. Generic SOS status checks (if status contains other words)
      else if (_containsAny(input, ['status', 'relay', 'alert', 'progress', 'स्थिति', 'प्रसारण', 'अलर्ट', 'प्रगति'])) {
        if (currentSosStatus == null) {
          response = "आपका एसओएस (SOS) तैयार कर लिया गया है और इसे स्थानीय रूप से सहेज लिया गया है। वर्तमान स्थिति: प्रसारण या कनेक्टिविटी की प्रतीक्षा की जा रही है।";
        } else {
          switch (currentSosStatus.toLowerCase()) {
            case 'stored offline':
            case 'stored':
              response = "आपका एसओएस (SOS) तैयार कर लिया गया है और इसे स्थानीय रूप से सहेज लिया गया है। वर्तमान स्थिति: प्रसारण या कनेक्टिविटी की प्रतीक्षा की जा रही है।";
              break;
            case 'relay in progress':
            case 'relaying':
              response = "आपका आपातकालीन अलर्ट पास के उपकरणों पर सफलतापूर्वक रिले (प्रसारित) कर दिया गया है और यह मेश नेटवर्क के माध्यम से आगे बढ़ रहा है।";
              break;
            case 'connectivity found':
            case 'connectivity':
              response = "कनेक्टिविटी मिल गई है! आपका आपातकालीन अलर्ट रिस्पॉन्डर नेटवर्क पर अपलोड हो रहा है।";
              break;
            case 'delivered':
            case 'completed':
              response = "आपका आपातकालीन अलर्ट भरोसेमंद संपर्कों तक पहुँच गया है। सहायता आ रही है। सुरक्षित क्षेत्र में बने रहें।";
              break;
            default:
              response = "आपका आपातकालीन अलर्ट सक्रिय है। वर्तमान स्थिति: $currentSosStatus है। मैं आपको सूचित करती रहूँगी।";
          }
        }
      }
      // 3. Greetings
      else if (_containsAny(input, ['hi', 'hello', 'hey', 'greetings', 'नमस्ते', 'हेलो', 'हाय'])) {
        response = "नमस्ते। मैं आरिया हूँ, जो आपके डिवाइस पर ऑफलाइन काम कर रही हूँ। मैं आपातकालीन प्रक्रियाओं में आपका मार्गदर्शन कर सकती हूँ या आपके एसओएस की स्थिति की जांच कर सकती हूँ। सुरक्षित रहने में मैं आपकी क्या मदद कर सकती हूँ?";
      }
      // 4. Calm support fallback
      else {
        final calmingResponses = [
          "शांत रहें। किसी सुरक्षित, अच्छी रोशनी वाले स्थान पर जाएँ, अपने भरोसेमंद लोगों से संपर्क करें, और आपातकालीन प्रक्रियाओं का पालन करें। मैं आपके साथ हूँ।",
          "आपकी सुरक्षा मेरी प्राथमिकता है। कृपया शांत रहने की कोशिश करें और कोई सुरक्षित स्थान ढूँढें। यदि आपको सुरक्षा सुझाव चाहिए या एसओएस स्थिति देखनी है, तो मुझे बताएं।",
          "मैं यहाँ आपकी मदद के लिए ऑफलाइन उपलब्ध हूँ। यदि आप असुरक्षित महसूस कर रही हैं, तो घनी आबादी वाले क्षेत्रों की ओर बढ़ें और अपने फोन को अपने पास रखें।"
        ];
        final seed = input.length + (currentSosStatus?.length ?? 0);
        response = calmingResponses[seed % calmingResponses.length];
      }
    } else {
      // 1. Exact match / containing match from the datasheet:
      if (input.contains("scared") || input.contains("i am scared")) {
        response = "I understand. Stay calm. Your emergency alert has been created successfully. If nearby devices are available, your SOS can be relayed until connectivity is restored.";
      } 
      else if (input.contains("sent") || input.contains("has my sos been sent") || input.contains("is my sos sent")) {
        response = "Your SOS has been generated and stored locally. Current status: waiting for relay or connectivity.";
      }
      else if (input.contains("what should i do") || input.contains("what should i do now") || input.contains("what to do now")) {
        response = "If it is safe, move toward a populated and well-lit area. Keep your phone accessible and remain aware of your surroundings.";
      }
      else if (input.contains("unsafe") || input.contains("i feel unsafe")) {
        response = "I understand. Stay calm. Your emergency alert has been created successfully. If nearby devices are available, your SOS can be relayed until connectivity is restored.";
      }
      else if (input.contains("how can i reach") || input.contains("reach a safe location") || input.contains("safe location")) {
        response = "If it is safe, move toward a populated and well-lit area. Keep your phone accessible and remain aware of your surroundings.";
      }
      else if (input.contains("what happens after sos") || input.contains("after sos")) {
        response = "Your SOS alert is encrypted and broadcasted to nearby devices via Bluetooth. It hops from device to device until one finds internet connectivity to notify your trusted contacts and emergency responders.";
      }
      // 2. Generic SOS status checks (if status contains other words)
      else if (_containsAny(input, ['status', 'relay', 'alert', 'progress'])) {
        if (currentSosStatus == null) {
          response = "Your SOS has been generated and stored locally. Current status: waiting for relay or connectivity.";
        } else {
          switch (currentSosStatus.toLowerCase()) {
            case 'stored offline':
            case 'stored':
              response = "Your SOS has been generated and stored locally. Current status: waiting for relay or connectivity.";
              break;
            case 'relay in progress':
            case 'relaying':
              response = "Your emergency alert has been relayed successfully to nearby devices and is traveling through the mesh network.";
              break;
            case 'connectivity found':
            case 'connectivity':
              response = "Connectivity has been found! Your emergency alert is uploading to the responder network.";
              break;
            case 'delivered':
            case 'completed':
              response = "Your emergency alert has reached trusted contacts. Help is on the way. Remain in a safe area.";
              break;
            default:
              response = "Your emergency alert is active. Current status: $currentSosStatus. I will keep you updated.";
          }
        }
      }
      // 3. Greetings
      else if (_containsAny(input, ['hi', 'hello', 'hey', 'greetings'])) {
        response = "Hello. I'm Aria, running locally on your device. I can help guide you through emergency procedures or check your SOS status. How can I help you stay safe?";
      }
      // 4. Calm support fallback
      else {
        final calmingResponses = [
          "Stay calm. Move to a safer, well-lit location, contact trusted people, and follow emergency procedures. I am here with you.",
          "Your safety is my priority. Try to remain calm and find a secure spot. If you need safety tips or want to check SOS status, let me know.",
          "I am here to guide you offline. If you feel unsafe, make sure to move towards populated areas and keep your phone accessible."
        ];
        final seed = input.length + (currentSosStatus?.length ?? 0);
        response = calmingResponses[seed % calmingResponses.length];
      }
    }

    // Add to local memory (limit to 10 messages: 5 User + 5 AI)
    _memory.add(GemmaMessage(role: 'user', text: userInput));
    _memory.add(GemmaMessage(role: 'assistant', text: response));
    if (_memory.length > 10) {
      _memory.removeRange(0, _memory.length - 10);
    }

    return response;
  }

  // Clear memory cache
  void clearMemory() {
    _memory.clear();
  }

  bool _containsAny(String text, List<String> keywords) {
    return keywords.any((kw) => text.contains(kw));
  }
}
