// lib/services/alarm/alarm_service_web.dart
import 'dart:js' as js;

class AlarmService {
  static void play() {
    try {
      js.context.callMethod('eval', ["""
        if (!window.sirenAudioCtx) {
          window.sirenAudioCtx = new (window.AudioContext || window.webkitAudioContext)();
          window.sirenOscillator = window.sirenAudioCtx.createOscillator();
          window.sirenModulator = window.sirenAudioCtx.createOscillator();
          window.sirenModulatorGain = window.sirenAudioCtx.createGain();
          window.sirenGainNode = window.sirenAudioCtx.createGain();

          window.sirenOscillator.type = 'sawtooth';
          window.sirenOscillator.frequency.value = 800;

          window.sirenModulator.frequency.value = 2.0;
          window.sirenModulatorGain.gain.value = 350;

          window.sirenModulator.connect(window.sirenModulatorGain);
          window.sirenModulatorGain.connect(window.sirenOscillator.frequency);

          window.sirenOscillator.connect(window.sirenGainNode);
          window.sirenGainNode.connect(window.sirenAudioCtx.destination);

          window.sirenGainNode.gain.value = 1.0;

          window.sirenOscillator.start();
          window.sirenModulator.start();
        }
      """]);
    } catch (e) {
      print("Failed to play Web Audio siren: $e");
    }
  }

  static void stop() {
    try {
      js.context.callMethod('eval', ["""
        if (window.sirenOscillator) {
          try { window.sirenOscillator.stop(); } catch(e){}
          try { window.sirenModulator.stop(); } catch(e){}
          try { window.sirenAudioCtx.close(); } catch(e){}
          
          window.sirenOscillator = null;
          window.sirenModulator = null;
          window.sirenModulatorGain = null;
          window.sirenGainNode = null;
          window.sirenAudioCtx = null;
        }
      """]);
    } catch (e) {
      print("Failed to stop Web Audio siren: $e");
    }
  }
}
