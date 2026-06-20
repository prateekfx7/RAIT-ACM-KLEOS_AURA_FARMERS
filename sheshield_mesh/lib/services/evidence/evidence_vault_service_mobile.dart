// lib/services/evidence/evidence_vault_service_mobile.dart
class EvidenceVaultService {
  static void startRecording() {
    print("Evidence Vault: start audio recording on mobile stub");
  }
  static void stopRecording() {
    print("Evidence Vault: stop audio recording on mobile stub");
  }
  static Future<String> getAudioData() async {
    // Return a dummy base64 string on mobile stub
    return "TW9iaWxlIEF1ZGlvIFN0dWI=";
  }
  static void playAudio(String base64Data) {
    print("Evidence Vault: play audio on mobile stub");
  }
  static void stopAudio() {
    print("Evidence Vault: stop audio on mobile stub");
  }
}
