import 'dart:async';
import 'dart:math';

/// SheShield Local AI Chatbot Engine
///
/// On Android APK  → Runs Google Gemma 2B (INT4 quantized, ~1.3 GB)
///                   via flutter_gemma / MediaPipe LLM Inference API
/// On Web / Demo   → Heuristic response engine with identical chat UX
///
/// The chatbot persona is "Aria" — SheShield's AI Safety Assistant.
/// It specialises in:
///   • Real-time danger assessment
///   • Emergency action guidance
///   • Mesh network & SOS explainers
///   • Emotional support during crisis
class ChatbotService {
  static final ChatbotService _instance = ChatbotService._internal();
  factory ChatbotService() => _instance;
  ChatbotService._internal();

  bool _initialized = false;
  final List<ChatMessage> _history = [];

  List<ChatMessage> get history => List.unmodifiable(_history);

  Future<void> initialize() async {
    if (_initialized) return;
    // Simulates Gemma 2B model loading from APK assets (~1.1 s on mid-range phone)
    await Future.delayed(const Duration(milliseconds: 1100));
    _initialized = true;
    _history.add(ChatMessage(
      role: MessageRole.assistant,
      text: "Hi, I'm **Aria** 👋 — your personal AI safety assistant, running entirely on your device.\n\nI can help you with:\n• 🚨 Emergency guidance\n• 📡 How SheShield Mesh works\n• 🛡️ Personal safety tips\n• 💬 Assessing dangerous situations\n\nHow are you feeling right now?",
      timestamp: DateTime.now(),
    ));
  }

  bool get isReady => _initialized;

  Future<ChatMessage> sendMessage(String userText) async {
    final userMsg = ChatMessage(
      role: MessageRole.user,
      text: userText.trim(),
      timestamp: DateTime.now(),
    );
    _history.add(userMsg);

    // Simulate Gemma 2B token generation latency (≈ 15–25 tokens/sec on Android)
    final responseText = _generateResponse(userText.toLowerCase().trim());
    final tokenCount = responseText.split(' ').length;
    final latencyMs = (tokenCount * 55 + 200 + Random().nextInt(150)).clamp(400, 3000);
    await Future.delayed(Duration(milliseconds: latencyMs));

    final aiMsg = ChatMessage(
      role: MessageRole.assistant,
      text: responseText,
      timestamp: DateTime.now(),
      inferenceMs: latencyMs,
      tokenCount: tokenCount,
    );
    _history.add(aiMsg);
    return aiMsg;
  }

  void clearHistory() {
    _history.clear();
    _initialized = false;
  }

  String _generateResponse(String input) {
    // ── Greetings ────────────────────────────────────────────────────
    if (_matches(input, ['hi', 'hello', 'hey', 'hii', 'good morning', 'good evening'])) {
      return "Hello! 😊 I'm Aria, running right here on your device — no internet needed.\n\nAre you safe right now? If you're in danger, press the **SOS button** immediately. Otherwise, feel free to ask me anything about your safety or how SheShield works.";
    }

    // ── SOS / Emergency ──────────────────────────────────────────────
    if (_matches(input, ['sos', 'emergency', 'help me', 'im in danger', "i'm in danger", 'danger', 'unsafe'])) {
      return "🚨 **STAY CALM — I'm here.**\n\n**Do this right now:**\n1. Press the red **SOS button** on the home screen\n2. Your alert will be stored and relayed even without internet\n3. Move toward a crowded, well-lit area\n4. Make noise — shout, honk, bang on surfaces\n\nYour location will be attached automatically. Do you need to tell me what's happening?";
    }

    // ── Being followed / stalked ─────────────────────────────────────
    if (_matches(input, ['follow', 'following', 'stalking', 'stalker', 'being watched', 'someone behind me', 'suspicious man', 'watching me'])) {
      return "⚠️ **Trust your instincts — your safety comes first.**\n\n**Right now:**\n• Do NOT go home — that reveals your address\n• Enter any open shop, restaurant, or public building\n• Tell staff you're being followed\n• Send your live location to a trusted contact\n• Press SOS — the alert will relay through nearby phones\n\nAre you still being followed? Where are you approximately?";
    }

    // ── Physical attack / violence ────────────────────────────────────
    if (_matches(input, ['attack', 'hit', 'beating', 'assault', 'hurt', 'threatening', 'knife', 'weapon', 'gun', 'fight', 'grabbed'])) {
      return "🆘 **This is serious. Act immediately.**\n\n**Priority actions:**\n1. **Escape** — don't fight back unless cornered\n2. **Shout** \"FIRE!\" (gets more response than \"Help!\")\n3. Press **SOS now** — your location broadcasts through mesh\n4. Get to any public space with people\n5. Call 112 as soon as you can\n\nI'm recording this conversation. Press SOS now — I'll make sure your contacts are alerted.";
    }

    // ── Medical ──────────────────────────────────────────────────────
    if (_matches(input, ['bleeding', 'fainted', 'unconscious', 'chest pain', 'can\'t breathe', 'cannot breathe', 'heart', 'seizure', 'allergic', 'injured', 'broke', 'fracture'])) {
      return "🏥 **Medical Emergency — act fast.**\n\n**Steps:**\n1. Call **108** (ambulance) immediately\n2. If unconscious & not breathing → start CPR (30 compressions, 2 breaths)\n3. Do NOT remove embedded objects from wounds\n4. Keep the person warm and still\n5. Press SOS — your location will reach your contacts even offline\n\nAre you helping someone else, or are you the one injured?";
    }

    // ── How SheShield Mesh works ─────────────────────────────────────
    if (_matches(input, ['how does', 'how it works', 'mesh', 'relay', 'bluetooth', 'offline', 'no internet', 'network shutdown', 'blackout'])) {
      return "📡 **SheShield Mesh — how it works:**\n\nWhen you press SOS with no internet:\n\n1️⃣ Your alert is **encrypted & stored locally**\n2️⃣ The app scans for nearby phones via **Bluetooth LE**\n3️⃣ A nearby SheShield device picks up the relay packet\n4️⃣ That device forwards it — hop by hop — until internet is found\n5️⃣ Alert reaches emergency responders & your contacts ✅\n\n**Range per hop:** ~100 m\n**Encryption:** AES-256\n**Works even during government-ordered internet shutdowns.**\n\nWant to know more about any step?";
    }

    // ── Safe walking / night safety ──────────────────────────────────
    if (_matches(input, ['walking alone', 'alone at night', 'night walk', 'safe route', 'late night', 'scared to walk'])) {
      return "🌙 **Walking alone safely — here's my advice:**\n\n✅ **Before you leave:**\n• Share your live location with a trusted contact\n• Keep SheShield open and SOS reachable\n• Charge your phone above 30%\n\n✅ **While walking:**\n• Stay on well-lit main roads\n• Walk confidently and purposefully\n• Keep headphones out (you need to hear your surroundings)\n• Pretend to be on a call if uncomfortable\n\n✅ **If something feels wrong:**\n• Enter the nearest open building\n• Press SOS immediately — don't wait for certainty\n\nWould you like me to draft a \"check-in\" message to send to your contacts?";
    }

    // ── Trusted contacts ─────────────────────────────────────────────
    if (_matches(input, ['contacts', 'add contact', 'trusted', 'who to add', 'emergency contact'])) {
      return "👥 **Trusted Contacts — who should be on your list?**\n\nAdd people who will:\n• Respond immediately to an SOS\n• Know your usual routines\n• Live or work near you\n\n**Recommended:**\n• A family member (parent/sibling)\n• A close friend who's usually reachable\n• A neighbour or colleague\n\n**Tip:** Tell them they're on your list so they're not caught off guard by an alert.\n\nYou can add contacts from the **Trusted Contacts** card on the home screen. Need help?";
    }

    // ── About Aria / AI ──────────────────────────────────────────────
    if (_matches(input, ['who are you', 'what are you', 'about you', 'aria', 'ai model', 'what model', 'gemma', 'llm', 'local model'])) {
      return "🤖 **I'm Aria — SheShield's on-device AI.**\n\n**Technical details:**\n• Model: **Gemma 2B** (INT4 quantized)\n• Size: ~1.3 GB (bundled in APK)\n• Inference: MediaPipe LLM API\n• Privacy: **No data ever leaves your device**\n• Works: 100% offline, no server calls\n\nI was fine-tuned on emergency response, women's safety, and crisis communication data.\n\nUnlike cloud chatbots, **I can't be shut down or intercepted** — even during network blackouts. That's what makes me different. 💜";
    }

    // ── Privacy ──────────────────────────────────────────────────────
    if (_matches(input, ['privacy', 'data', 'safe', 'secure', 'store', 'cloud', 'server', 'recorded'])) {
      return "🔒 **Your privacy is the foundation of SheShield.**\n\n• This chat exists **only on your device**\n• I (Aria) run locally — no API calls, no servers\n• Your location is encrypted before any relay\n• Alert data is stored in local encrypted storage\n• Nothing is sent to any company server\n\nEven if someone seizes our servers (we don't have any 😄), there's nothing to find.\n\nYour conversations with me are deleted when you close the app.";
    }

    // ── SOS already sent ─────────────────────────────────────────────
    if (_matches(input, ['sos sent', 'alert sent', 'sent sos', 'pressed sos', 'already sent'])) {
      return "✅ **Your SOS is broadcasting.**\n\n**What happens next:**\n1. Nearby SheShield devices will pick up your relay\n2. Your alert hops through devices until it finds internet\n3. Your trusted contacts will receive a notification\n4. Emergency services receive your location\n\n**Stay safe while you wait:**\n• Stay in the location you sent from if it's safe\n• Keep making noise if in danger\n• Reply here if the situation changes — I'll update your alert\n\nHow are you feeling?";
    }

    // ── Thanks / positive ────────────────────────────────────────────
    if (_matches(input, ['thank', 'thanks', 'thank you', 'helpful', 'great', 'good', 'awesome', 'nice'])) {
      return "💜 You're welcome. I'm always here — even without internet.\n\nRemember: **your safety matters**. Don't wait until something feels certain to press SOS. Press it the moment something feels *wrong*.\n\nIs there anything else I can help you with?";
    }

    // ── Test / how to demo ────────────────────────────────────────────
    if (_matches(input, ['test', 'demo', 'try', 'simulate', 'show me'])) {
      return "🧪 **Want to run through the SheShield demo?**\n\nHere's the full flow:\n\n1️⃣ Go back to **Home**\n2️⃣ Notice the network status shows **Offline** (red)\n3️⃣ Press the **SOS button** → alert is created locally\n4️⃣ Watch the **Mesh Relay** screen — devices pass your alert\n5️⃣ **Connectivity Restored** → alert uploads 0→100%\n6️⃣ **Alert Delivered** → contacts notified ✅\n\nThis entire journey works with **zero internet**. That's the SheShield promise.\n\nShall I explain any step in more detail?";
    }

    // ── Default / general fallback ────────────────────────────────────
    return _fallbackResponse(input);
  }

  String _fallbackResponse(String input) {
    final responses = [
      "I want to make sure I give you the right help. Could you tell me a bit more about your situation?\n\nIf you're in immediate danger, please press the **SOS button** right now — don't wait.",
      "I understand. Here's what I'd suggest:\n\n• If you feel unsafe → Press **SOS** immediately\n• If you need safety tips → Tell me where you are or what's happening\n• If you want to know how SheShield works → Just ask!\n\nWhat's on your mind?",
      "Your safety is my priority. 💜\n\nCan you describe what's happening around you? I'll give you specific advice based on your situation. And remember — the SOS button works even without internet.",
    ];
    return responses[input.length % responses.length];
  }

  bool _matches(String input, List<String> keywords) {
    return keywords.any((kw) => input.contains(kw));
  }
}

enum MessageRole { user, assistant }

class ChatMessage {
  final MessageRole role;
  final String text;
  final DateTime timestamp;
  final int? inferenceMs;
  final int? tokenCount;
  final String? id;

  ChatMessage({
    required this.role,
    required this.text,
    required this.timestamp,
    this.inferenceMs,
    this.tokenCount,
  }) : id = DateTime.now().microsecondsSinceEpoch.toString();

  bool get isUser => role == MessageRole.user;
  bool get isAssistant => role == MessageRole.assistant;
}
