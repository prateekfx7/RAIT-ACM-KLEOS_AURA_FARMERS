// lib/providers/mesh_provider.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import '../models/mesh_message.dart';
import '../services/ble_service.dart';
import '../services/api_service.dart';

enum DeviceRole { target, relay, fallback }

class MeshProvider with ChangeNotifier {
  final BleService _bleService;
  final ApiService _apiService;
  DeviceRole _role = DeviceRole.target;
  MeshMessage? _lastMessage;
  Timer? _fallbackTimer;

  MeshProvider(this._bleService, this._apiService) {
    _initialize();
  }

  DeviceRole get role => _role;
  MeshMessage? get lastMessage => _lastMessage;

  void setRole(DeviceRole role) {
    _role = role;
    _setupRole();
    notifyListeners();
  }

  Future<void> _initialize() async {
    await _bleService.initialize();
  }

  void _setupRole() {
    _cancelAll();
    switch (_role) {
      case DeviceRole.target:
        _startTarget();
        break;
      case DeviceRole.relay:
        _startRelay();
        break;
      case DeviceRole.fallback:
        _startFallback();
        break;
    }
  }

  void _cancelAll() {
    _fallbackTimer?.cancel();
    // TODO: stop scanning/advertising if needed
  }

  // ---------- Target ----------
  void _startTarget() {
    Timer.periodic(Duration(seconds: 15), (timer) async {
      Position pos = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
      final msg = MeshMessage(
        type: 'location',
        lat: pos.latitude,
        lng: pos.longitude,
        timestamp: DateTime.now().millisecondsSinceEpoch,
      );
      await _bleService.startAdvertising(msg);
    });
  }

  // ---------- Relay ----------
  void _startRelay() {
    _bleService.startScanning();
    _bleService.startListening();
    _bleService.messageStream.listen((msg) async {
      _lastMessage = msg;
      notifyListeners();
      await ApiService.sendLocation(msg);
    });
    // Reset fallback timer whenever a message is received
    _fallbackTimer = Timer.periodic(const Duration(seconds: 30), (_) {});
  }

  // ---------- Fallback ----------
  void _startFallback() {
    _fallbackTimer = Timer.periodic(const Duration(seconds: 60), (timer) async {
      await ApiService.triggerFallback();
    });
  }
}
