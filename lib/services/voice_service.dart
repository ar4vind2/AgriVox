import 'package:flutter/foundation.dart';
import 'package:flutter_tts/flutter_tts.dart';

class VoiceService {
  static final VoiceService _instance = VoiceService._internal();
  factory VoiceService() => _instance;
  VoiceService._internal();

  final FlutterTts _flutterTts = FlutterTts();
  bool _isInitialized = false;
  bool _isSpeaking = false;
  final List<void Function()> _completionCallbacks = [];

  bool get isSpeaking => _isSpeaking;

  Future<void> init() async {
    if (_isInitialized) return;

    try {
      // Configure language for Malayalam (India) with safe offline fallback
      try {
        final res = await _flutterTts.setLanguage("ml-IN");
        if (res != 1 && res != "1") {
          await _flutterTts.setLanguage("ml");
        }
      } catch (e) {
        debugPrint("Offline Malayalam TTS language setup note: $e");
      }

      // 0.40 - 0.45 provides a clear, natural cadence for regional audio instructions
      await _flutterTts.setSpeechRate(0.42);
      await _flutterTts.setPitch(1.0);
      await _flutterTts.setVolume(1.0);

      // Register lifecycle and state change handlers
      _flutterTts.setStartHandler(() {
        _isSpeaking = true;
      });

      _flutterTts.setCompletionHandler(() {
        _isSpeaking = false;
        _notifyCompletions();
      });

      _flutterTts.setCancelHandler(() {
        _isSpeaking = false;
        _notifyCompletions();
      });

      _flutterTts.setErrorHandler((msg) {
        debugPrint("TTS Error handler: $msg");
        _isSpeaking = false;
        _notifyCompletions();
      });

      _isInitialized = true;
    } catch (e) {
      debugPrint("VoiceService initialization error: $e");
    }
  }

  void _notifyCompletions() {
    for (final cb in List.of(_completionCallbacks)) {
      try {
        cb();
      } catch (_) {}
    }
  }

  void setCompletionHandler(void Function() onComplete) {
    _completionCallbacks.clear();
    _completionCallbacks.add(onComplete);
  }

  void addCompletionHandler(void Function() onComplete) {
    _completionCallbacks.add(onComplete);
  }

  Future<void> speakPrescription({
    required String diseaseMl,
    required String chemicalTreatmentMl,
    required String organicTreatmentMl,
    bool preferOrganic = false,
  }) async {
    await init();
    try {
      await _flutterTts.setLanguage("ml-IN");
    } catch (_) {}
    await _flutterTts.setSpeechRate(0.42);

    String speechText = "കണ്ടെത്തിയ രോഗം: $diseaseMl. ";
    if (preferOrganic) {
      speechText += "ജൈവ നിയന്ത്രണ മാർഗ്ഗം: $organicTreatmentMl";
    } else {
      speechText += "രാസ നിയന്ത്രണ മാർഗ്ഗം: $chemicalTreatmentMl";
    }

    try {
      await _flutterTts.stop();
      _isSpeaking = true;
      await _flutterTts.speak(speechText);
    } catch (e) {
      _isSpeaking = false;
      debugPrint("speakPrescription error: $e");
    }
  }

  Future<void> speakMalayalam(String text) async {
    await init();
    try {
      await _flutterTts.setLanguage("ml-IN");
    } catch (_) {}
    await _flutterTts.setSpeechRate(0.42);
    try {
      await _flutterTts.stop();
      _isSpeaking = true;
      await _flutterTts.speak(text);
    } catch (e) {
      _isSpeaking = false;
      debugPrint("speakMalayalam error: $e");
    }
  }

  Future<void> speakEnglish(String text) async {
    await init();
    try {
      await _flutterTts.setLanguage("en-IN");
    } catch (_) {
      try {
        await _flutterTts.setLanguage("en-US");
      } catch (_) {}
    }
    await _flutterTts.setSpeechRate(0.46);
    try {
      await _flutterTts.stop();
      _isSpeaking = true;
      await _flutterTts.speak(text);
    } catch (e) {
      _isSpeaking = false;
      debugPrint("speakEnglish error: $e");
    }
  }

  Future<void> stop() async {
    try {
      await _flutterTts.stop();
    } catch (_) {}
    _isSpeaking = false;
  }
}