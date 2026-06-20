// lib/services/evidence_vault_service.dart
export 'evidence/evidence_vault_service_stub.dart'
    if (dart.library.js_util) 'evidence/evidence_vault_service_web.dart'
    if (dart.library.io) 'evidence/evidence_vault_service_mobile.dart';
