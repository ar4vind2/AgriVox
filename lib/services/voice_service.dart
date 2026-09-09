import 'package:flutter_tts/flutter_tts.dart';

class VoiceService {
  final FlutterTts _flutterTts = FlutterTts();
  bool _isInitialized = false;

  Future<void> init() async {
    if (_isInitialized) return;

    // Configure language for Malayalam (India)
    await _flutterTts.setLanguage("ml-IN");
    
    // 0.40 - 0.45 provides a clear, natural cadence for regional audio instructions
    await _flutterTts.setSpeechRate(0.42);
    await _flutterTts.setPitch(1.0);
    await _flutterTts.setVolume(1.0);

    _isInitialized = true;
  }

  Future<void> speakPrescription({
    required String diseaseMl,
    required String chemicalTreatmentMl,
    required String organicTreatmentMl,
    bool preferOrganic = false,
  }) async {
    await init();

    String speechText = "കണ്ടെത്തിയ രോഗം: $diseaseMl. ";
    if (preferOrganic) {
      speechText += "ജൈവ നിയന്ത്രണ മാർഗ്ഗം: $organicTreatmentMl";
    } else {
      speechText += "രാസ നിയന്ത്രണ മാർഗ്ഗം: $chemicalTreatmentMl";
    }

    await _flutterTts.stop();
    await _flutterTts.speak(speechText);
  }

  Future<void> stop() async {
    await _flutterTts.stop();
  }
}