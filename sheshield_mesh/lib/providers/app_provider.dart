import 'dart:async';
import 'package:flutter/foundation.dart';
import '../models/models.dart';
import '../services/geolocation_service.dart';
import '../services/ai_voice_service.dart';
import '../services/api_service.dart';

class AppProvider extends ChangeNotifier {
  AppProvider() {
    _loadInitialState();
  }

  Future<void> _loadInitialState() async {
    try {
      final state = await ApiService.fetchState();
      if (state.isNotEmpty) {
        if (state['activeAlert'] != null) {
          _currentAlert = AlertModel.fromJson(state['activeAlert'] as Map<String, dynamic>);
        } else {
          _currentAlert = null;
        }
        
        if (state['contacts'] != null) {
          final List<dynamic> contactsJson = state['contacts'] as List<dynamic>;
          _contacts = contactsJson
              .map((c) => ContactModel.fromJson(c as Map<String, dynamic>))
              .toList();
        }
        
        if (state['history'] != null) {
          final List<dynamic> historyJson = state['history'] as List<dynamic>;
          _history = historyJson
              .map((h) => AlertModel.fromJson(h as Map<String, dynamic>))
              .toList();
        }
        notifyListeners();
      }
    } catch (e) {
      debugPrint("AppProvider failed to load initial state: $e");
    }
  }

  // Network Status
  bool _isOnline = false;
  bool get isOnline => _isOnline;

  // Live location
  String _liveLocation = '28.6139° N, 77.2090° E';
  String get liveLocation => _liveLocation;
  bool _locationFetching = false;
  bool get locationFetching => _locationFetching;
  String? _locationError;
  String? get locationError => _locationError;
  bool _isLastLocationIpFallback = false;
  bool get isLastLocationIpFallback => _isLastLocationIpFallback;

  // Current Alert
  AlertModel? _currentAlert;
  AlertModel? get currentAlert => _currentAlert;

  // Contacts
  List<ContactModel> _contacts = List.from(sampleContacts);
  List<ContactModel> get contacts => _contacts;

  // History
  List<AlertModel> _history = List.from(sampleHistory);
  List<AlertModel> get history => _history;

  // Safe Beacon Mode state
  bool _isSafeBeaconActive = false;
  bool get isSafeBeaconActive => _isSafeBeaconActive;

  Timer? _safeBeaconTimer;
  int _safeBeaconElapsedSeconds = 0;
  int get safeBeaconElapsedSeconds => _safeBeaconElapsedSeconds;
  DateTime? _safeBeaconStartTime;

  String get safeBeaconElapsedTime {
    final minutes = _safeBeaconElapsedSeconds ~/ 60;
    final seconds = _safeBeaconElapsedSeconds % 60;
    final minutesStr = minutes.toString().padLeft(2, '0');
    final secondsStr = seconds.toString().padLeft(2, '0');
    return '$minutesStr:$secondsStr';
  }

  String get safeBeaconStartTimeText {
    if (_safeBeaconStartTime == null) return '';
    final hour = _safeBeaconStartTime!.hour;
    final minute = _safeBeaconStartTime!.minute;
    final ampm = hour >= 12 ? 'PM' : 'AM';
    final formattedHour = hour % 12 == 0 ? 12 : hour % 12;
    final formattedMinute = minute.toString().padLeft(2, '0');
    return 'started $formattedHour:$formattedMinute $ampm';
  }

  void toggleSafeBeacon() {
    _isSafeBeaconActive = !_isSafeBeaconActive;
    if (_isSafeBeaconActive) {
      _safeBeaconStartTime = DateTime.now();
      _safeBeaconElapsedSeconds = 0;
      _safeBeaconTimer?.cancel();
      _safeBeaconTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
        _safeBeaconElapsedSeconds++;
        notifyListeners();
      });
    } else {
      _safeBeaconTimer?.cancel();
      _safeBeaconTimer = null;
      _safeBeaconStartTime = null;
      _safeBeaconElapsedSeconds = 0;
    }
    notifyListeners();
  }

  void setOnline(bool value) {
    _isOnline = value;
    notifyListeners();
  }

  Future<void> fetchLiveLocation() async {
    _locationFetching = true;
    _locationError = null;
    _isLastLocationIpFallback = false;
    notifyListeners();
    try {
      final result = await GeolocationService.getCurrentPosition();
      _liveLocation = result.formattedWithAccuracy;
      _isLastLocationIpFallback = result.isIpFallback;
      _locationError = null;
    } catch (e) {
      _locationError = e.toString();
      // Keep the last known / default location as fallback
    } finally {
      _locationFetching = false;
      notifyListeners();
    }
  }

  void setManualLocation(String location) {
    _liveLocation = location;
    _locationError = null;
    _isLastLocationIpFallback = false;
    notifyListeners();
  }

  Timer? _simulationTimer;
  int _simulationStage = 0;

  void createNewAlert() async {
    _currentAlert = AlertModel.generate(location: _liveLocation);
    notifyListeners();

    // Sync to API backend
    await ApiService.createAlert(_currentAlert!);

    // Reset voice service memory
    AiVoiceService().clearMemory();

    // Trigger voice announcement for SOS activation
    AiVoiceService().speak(
      "Emergency SOS activated. Your location has been recorded and encrypted offline. Relaying alert through nearby mesh devices."
    );

    // Start background simulation loop
    _simulationStage = 0;
    _simulationTimer?.cancel();
    _simulationTimer = Timer.periodic(const Duration(seconds: 5), (timer) async {
      _simulationStage++;
      if (_currentAlert == null) {
        timer.cancel();
        return;
      }

      if (_simulationStage == 1) {
        // Step 1: Relay successful
        await updateAlertStatus('Relay In Progress');
        await updateAlertRelayCount(1);
        AiVoiceService().speak("Your emergency alert has been relayed successfully.");
      } else if (_simulationStage == 2) {
        // Step 2: Connectivity found
        await updateAlertStatus('Connectivity Found');
        // Let's set online true to simulate network restored
        setOnline(true);
        AiVoiceService().speak("Internet connectivity restored. Syncing your alert.");
      } else if (_simulationStage == 3) {
        // Step 3: Delivered
        await deliverAlert();
        timer.cancel();
      }
    });
  }

  Future<void> updateAlertStatus(String status) async {
    if (_currentAlert != null) {
      _currentAlert = _currentAlert!.copyWith(status: status);
      notifyListeners();
      await ApiService.updateAlert({'status': status});
    }
  }

  Future<void> updateAlertRelayCount(int count) async {
    if (_currentAlert != null) {
      _currentAlert = _currentAlert!.copyWith(relayCount: count);
      notifyListeners();
      await ApiService.updateAlert({'relayCount': count});
    }
  }

  Future<void> deliverAlert() async {
    if (_currentAlert != null) {
      _currentAlert = _currentAlert!.copyWith(
        status: 'Delivered',
        relayCount: 1,
        deliveredAt: DateTime.now(),
      );
      _history.insert(0, _currentAlert!);
      notifyListeners();

      await ApiService.updateAlert({
        'status': 'Delivered',
        'relayCount': 1,
        'deliveredAt': _currentAlert!.deliveredAt!.toIso8601String(),
      });

      // Trigger delivery announcement
      AiVoiceService().speak("Your emergency alert has reached trusted contacts.");
    }
  }

  void clearCurrentAlert() async {
    _simulationTimer?.cancel();
    _currentAlert = null;
    notifyListeners();
    await ApiService.clearActiveAlert();
  }

  void addContact(ContactModel contact) async {
    _contacts.add(contact);
    notifyListeners();
    await ApiService.addContact(contact);
  }

  void updateContact(String id, ContactModel updated) async {
    final idx = _contacts.indexWhere((c) => c.id == id);
    if (idx != -1) {
      _contacts[idx] = updated;
      notifyListeners();
      await ApiService.updateContact(updated);
    }
  }

  void deleteContact(String id) async {
    _contacts.removeWhere((c) => c.id == id);
    notifyListeners();
    await ApiService.deleteContact(id);
  }

  @override
  void dispose() {
    _simulationTimer?.cancel();
    _safeBeaconTimer?.cancel();
    super.dispose();
  }
}
