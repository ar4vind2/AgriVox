import 'package:flutter_tts/flutter_tts.dart';

class VoiceService {
  static final VoiceService _instance = VoiceService._internal();
  factory VoiceService() => _instance;
  VoiceService._internal();

  final FlutterTts _flutterTts = FlutterTts();
  bool _isInitialized = false;

  Future<void> init() async {
    if (_isInitialized) return;

    // Configure default language for Malayalam (India)
    await _flutterTts.setLanguage("ml-IN");
    await _flutterTts.setSpeechRate(0.42);
    await _flutterTts.setPitch(1.0);
    await _flutterTts.setVolume(1.0);

    _isInitialized = true;
  }

  void setCompletionHandler(void Function() onComplete) {
    _flutterTts.setCompletionHandler(onComplete);
    _flutterTts.setCancelHandler(onComplete);
  }

  Future<void> speakPrescription({
    required String diseaseMl,
    required String chemicalTreatmentMl,
    required String organicTreatmentMl,
    bool preferOrganic = false,
  }) async {
    await init();
    await _flutterTts.setLanguage("ml-IN");
    await _flutterTts.setSpeechRate(0.42);

    String speechText = "കണ്ടെത്തിയ രോഗം: $diseaseMl. ";
    if (preferOrganic) {
      speechText += "ജൈവ നിയന്ത്രണ മാർഗ്ഗം: $organicTreatmentMl";
    } else {
      speechText += "രാസ നിയന്ത്രണ മാർഗ്ഗം: $chemicalTreatmentMl";
    }

    await _flutterTts.stop();
    await _flutterTts.speak(speechText);
  }

  Future<void> speakMalayalam(String text) async {
    await init();
    await _flutterTts.setLanguage("ml-IN");
    await _flutterTts.setSpeechRate(0.42);
    await _flutterTts.stop();
    await _flutterTts.speak(text);
  }

  Future<void> speakEnglish(String text) async {
    await init();
    await _flutterTts.setLanguage("en-IN");
    await _flutterTts.setSpeechRate(0.46);
    await _flutterTts.stop();
    await _flutterTts.speak(text);
  }

  Future<void> stop() async {
    await _flutterTts.stop();
  }
}