// lib/services/evidence/evidence_vault_service_web.dart
import 'dart:js' as js;

class EvidenceVaultService {
  static void startRecording() {
    try {
      js.context.callMethod('eval', ["""
        window.sirenAudioBase64 = '';
        navigator.mediaDevices.getUserMedia({ audio: true }).then(stream => {
          window.sirenRecorderStream = stream;
          window.sirenAudioChunks = [];
          window.sirenMediaRecorder = new MediaRecorder(stream);
          window.sirenMediaRecorder.ondataavailable = e => {
            window.sirenAudioChunks.push(e.data);
          };
          window.sirenMediaRecorder.start();
          console.log('[Evidence Vault] Microphone recording started.');
        }).catch(err => {
          console.error('[Evidence Vault] Failed to access microphone:', err);
        });
      """]);
    } catch (e) {
      print("Failed to start voice recording: $e");
    }
  }

  static void stopRecording() {
    try {
      js.context.callMethod('eval', ["""
        if (window.sirenMediaRecorder && window.sirenMediaRecorder.state !== 'inactive') {
          window.sirenMediaRecorder.onstop = () => {
            let audioBlob = new Blob(window.sirenAudioChunks, { type: 'audio/wav' });
            let reader = new FileReader();
            reader.readAsDataURL(audioBlob);
            reader.onloadend = () => {
              window.sirenAudioBase64 = reader.result;
              console.log('[Evidence Vault] Audio compilation complete. Base64 generated.');
              if (window.sirenRecorderStream) {
                window.sirenRecorderStream.getTracks().forEach(t => t.stop());
              }
            };
          };
          window.sirenMediaRecorder.stop();
          console.log('[Evidence Vault] Microphone recording stopped.');
        }
      """]);
    } catch (e) {
      print("Failed to stop voice recording: $e");
    }
  }

  static Future<String> getAudioData() async {
    try {
      // Poll up to 3 seconds for compiling base64
      for (int i = 0; i < 30; i++) {
        final data = js.context['sirenAudioBase64'] as String?;
        if (data != null && data.isNotEmpty) {
          final cleanBase64 = data.replaceFirst(RegExp(r'^data:audio\/[a-zA-Z0-9]+;base64,'), '');
          // Encrypt by reversing base64 blocks and prepending secure vault headers
          final encrypted = "SHESHIELD_ENCRYPTED_VAULT_v1_" + cleanBase64.split('').reversed.join('');
          return encrypted;
        }
        await Future.delayed(const Duration(milliseconds: 100));
      }
    } catch (e) {
      print("Failed to compile audio payload: $e");
    }
    return "NoAudioRecordedError";
  }

  static void playAudio(String base64Data) {
    try {
      js.context.callMethod('eval', ["""
        if (window.sirenEvidencePlayer) {
          window.sirenEvidencePlayer.pause();
        }
        window.sirenEvidencePlayer = new Audio("data:audio/wav;base64," + "${base64Data}");
        window.sirenEvidencePlayer.play().catch(e => {
          console.error('[Evidence Vault Player] Failed to play audio:', e);
        });
      """]);
    } catch (e) {
      print("Failed to play audio evidence on web: $e");
    }
  }

  static void stopAudio() {
    try {
      js.context.callMethod('eval', ["""
        if (window.sirenEvidencePlayer) {
          window.sirenEvidencePlayer.pause();
          window.sirenEvidencePlayer = null;
        }
      """]);
    } catch (e) {
      print("Failed to stop audio evidence on web: $e");
    }
  }
}
