// lib/services/ble_service.dart
import 'dart:async';
import 'dart:convert';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:permission_handler/permission_handler.dart';
import '../models/mesh_message.dart';

class BleService {
  final FlutterReactiveBle _ble = FlutterReactiveBle();
  final _scanStreamController = StreamController<DiscoveredDevice>.broadcast();
  final _messageStreamController = StreamController<MeshMessage>.broadcast();

  // UUIDs for service and characteristic (randomly generated)
  static final Uuid serviceUuid = Uuid.parse("0000feed-0000-1000-8000-00805f9b34fb");
  static final Uuid characteristicUuid = Uuid.parse("0000beef-0000-1000-8000-00805f9b34fb");

  Stream<DiscoveredDevice> get scanStream => _scanStreamController.stream;
  Stream<MeshMessage> get messageStream => _messageStreamController.stream;

  Future<void> initialize() async {
    // Request permissions for location and BLE
    await [Permission.locationWhenInUse, Permission.bluetooth,
      Permission.bluetoothScan, Permission.bluetoothAdvertise]
        .request();
  }

  // Start scanning for peers
  void startScanning() {
    _ble.scanForDevices(withServices: [serviceUuid]).listen((device) {
      _scanStreamController.add(device);
    }, onError: (e) {
      // ignore errors for now
    });
  }

  // Advertise a MeshMessage payload
  Future<void> startAdvertising(MeshMessage message) async {
    final encoded = utf8.encode(jsonEncode(message.toJson()));
    print("BLE Advertising: $encoded");
  }

  // Listen for messages from other devices
  void startListening() {
    _ble.subscribeToCharacteristic(
      QualifiedCharacteristic(
        serviceId: serviceUuid,
        characteristicId: characteristicUuid,
        deviceId: "",
      ),
    ).listen((data) {
      try {
        final jsonString = utf8.decode(data);
        final map = jsonDecode(jsonString) as Map<String, dynamic>;
        final msg = MeshMessage.fromJson(map);
        _messageStreamController.add(msg);
      } catch (_) {}
    }, onError: (e) {});
  }
}
