import 'dart:async';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:flutter_tts/flutter_tts.dart';
import '../models/models.dart'; // import existing models if needed

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

  bool get isSpeechAvailable => _isSpeechInitialized;
  bool get isTtsAvailable => _isTtsInitialized;
  bool get isListening => _isListening;

  // Local memory cache for Gemma 3n (last 5-10 messages)
  final List<GemmaMessage> _memory = [];
  List<GemmaMessage> get memory => List.unmodifiable(_memory);

  // Initialize service (STT and TTS)
  Future<void> initialize() async {
    // 1. Initialize TTS
    try {
      if (!_isTtsInitialized) {
        if (!kIsWeb) {
          // On mobile platforms we can set extra parameters
          await _tts.setSharedInstance(true);
        }
        await _tts.setLanguage("en-US");
        await _tts.setSpeechRate(0.5); // Calm, reassuring pace
        await _tts.setVolume(1.0);
        await _tts.setPitch(1.15); // Slightly higher pitch for a clear female safety assistant voice

        // Attempt to find and set a smooth female voice
        try {
          List<dynamic>? voices = await _tts.getVoices;
          if (voices != null && voices.isNotEmpty) {
            dynamic selectedVoice;
            for (var voice in voices) {
              if (voice is Map) {
                final String name = (voice["name"] ?? "").toString().toLowerCase();
                final String locale = (voice["locale"] ?? "").toString().toLowerCase();
                // Filter for English (US or GB) female-sounding voice profiles
                if (locale.contains("en-us") || locale.contains("en-gb")) {
                  if (name.contains("female") || 
                      name.contains("zira") || 
                      name.contains("samantha") || 
                      name.contains("google") || 
                      name.contains("sfg") || 
                      name.contains("hazel")) {
                    selectedVoice = voice;
                    break;
                  }
                }
              }
            }
            if (selectedVoice != null) {
              await _tts.setVoice({
                "name": selectedVoice["name"].toString(),
                "locale": selectedVoice["locale"].toString()
              });
              debugPrint("Selected female voice: ${selectedVoice['name']}");
            }
          }
        } catch (voiceError) {
          debugPrint("Failed to set specific voice, using default English profile: $voiceError");
        }

        _isTtsInitialized = true;
        debugPrint("TTS initialized successfully.");
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
    // Fallback simulation when TTS is not active or fails due to autoplay blocks
    debugPrint("Simulating speech output for: \"$text\"");
    if (onStart != null) onStart();
    final wordCount = text.split(' ').length;
    final duration = Duration(milliseconds: (wordCount * 220) + 400);
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
    String response = "";

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
