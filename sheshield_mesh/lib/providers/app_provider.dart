import 'dart:async';
import 'package:flutter/foundation.dart';
import '../models/models.dart';
import '../services/geolocation_service.dart';
import '../services/ai_voice_service.dart';

class AppProvider extends ChangeNotifier {
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

  // Current Alert
  AlertModel? _currentAlert;
  AlertModel? get currentAlert => _currentAlert;

  // Contacts
  List<ContactModel> _contacts = List.from(sampleContacts);
  List<ContactModel> get contacts => _contacts;

  // History
  List<AlertModel> _history = List.from(sampleHistory);
  List<AlertModel> get history => _history;

  void setOnline(bool value) {
    _isOnline = value;
    notifyListeners();
  }

  Future<void> fetchLiveLocation() async {
    _locationFetching = true;
    _locationError = null;
    notifyListeners();
    try {
      final result = await GeolocationService.getCurrentPosition();
      _liveLocation = result.formattedWithAccuracy;
      _locationError = null;
    } catch (e) {
      _locationError = e.toString();
      // Keep the last known / default location as fallback
    } finally {
      _locationFetching = false;
      notifyListeners();
    }
  }

  void createNewAlert() {
    _currentAlert = AlertModel.generate(location: _liveLocation);
    notifyListeners();

    // Reset voice service memory
    AiVoiceService().clearMemory();
  }

  void updateAlertStatus(String status) {
    if (_currentAlert != null) {
      _currentAlert = _currentAlert!.copyWith(status: status);
      notifyListeners();
    }
  }

  void updateAlertRelayCount(int count) {
    if (_currentAlert != null) {
      _currentAlert = _currentAlert!.copyWith(relayCount: count);
      notifyListeners();
      if (count == 1) {
        AiVoiceService().speak("Your emergency alert has been relayed successfully.");
      }
    }
  }

  void deliverAlert() {
    if (_currentAlert != null) {
      _currentAlert = _currentAlert!.copyWith(
        status: 'Delivered',
        relayCount: 1,
        deliveredAt: DateTime.now(),
      );
      _history.insert(0, _currentAlert!);
      notifyListeners();

      // Trigger delivery announcement
      AiVoiceService().speak("Your emergency alert has reached trusted contacts.");
    }
  }

  void clearCurrentAlert() {
    _currentAlert = null;
    notifyListeners();
  }

  void addContact(ContactModel contact) {
    _contacts.add(contact);
    notifyListeners();
  }

  void updateContact(String id, ContactModel updated) {
    final idx = _contacts.indexWhere((c) => c.id == id);
    if (idx != -1) {
      _contacts[idx] = updated;
      notifyListeners();
    }
  }

  void deleteContact(String id) {
    _contacts.removeWhere((c) => c.id == id);
    notifyListeners();
  }
}
