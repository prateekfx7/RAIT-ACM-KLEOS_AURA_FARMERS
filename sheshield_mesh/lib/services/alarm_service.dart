// lib/services/alarm_service.dart
export 'alarm/alarm_service_stub.dart'
    if (dart.library.js_util) 'alarm/alarm_service_web.dart'
    if (dart.library.io) 'alarm/alarm_service_mobile.dart';
