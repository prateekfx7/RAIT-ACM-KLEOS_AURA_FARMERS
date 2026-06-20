// lib/services/evidence/evidence_vault_service_stub.dart
class EvidenceVaultService {
  static void startRecording() {}
  static void stopRecording() {}
  static Future<String> getAudioData() async {
    return "";
  }
  static void playAudio(String base64Data) {}
  static void stopAudio() {}
}
