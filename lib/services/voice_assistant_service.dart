import 'dart:math' as math;
import 'package:flutter/foundation.dart';
import 'package:speech_to_text/speech_to_text.dart';
import '../models/disease_prescription.dart';
import 'prescription_repository.dart';

class VoiceDiagnosisResult {
  final String queryText;
  final String detectedCrop;
  final String diseaseKey;
  final double confidence;
  final DiseasePrescription prescription;
  final Prescription? dbPrescription;
  final String spokenExplanationMl;
  final String spokenExplanationEn;
  final List<String> matchedKeywords;

  VoiceDiagnosisResult({
    required this.queryText,
    required this.detectedCrop,
    required this.diseaseKey,
    required this.confidence,
    required this.prescription,
    this.dbPrescription,
    required this.spokenExplanationMl,
    required this.spokenExplanationEn,
    required this.matchedKeywords,
  });
}

class AgronomyVoiceAssistantService {
  static final AgronomyVoiceAssistantService _instance = AgronomyVoiceAssistantService._internal();
  factory AgronomyVoiceAssistantService() => _instance;
  AgronomyVoiceAssistantService._internal();

  final SpeechToText _speechToText = SpeechToText();
  final PrescriptionRepository _repository = PrescriptionRepository();

  bool _isSpeechInitialized = false;
  bool _isListening = false;
  String _currentLocaleId = 'ml_IN';

  bool get isSpeechInitialized => _isSpeechInitialized;
  bool get isListening => _isListening;
  String get currentLocaleId => _currentLocaleId;

  Future<bool> initSpeech() async {
    if (_isSpeechInitialized) return true;
    try {
      _isSpeechInitialized = await _speechToText.initialize(
        onError: (error) {
          debugPrint('SpeechToText Error: ');
          _isListening = false;
        },
        onStatus: (status) {
          debugPrint('SpeechToText Status: ');
          if (status == 'done' || status == 'notListening') {
            _isListening = false;
          }
        },
      );

      if (_isSpeechInitialized) {
        final locales = await _speechToText.locales();
        final hasMalayalam = locales.any((l) => l.localeId.toLowerCase().startsWith('ml'));
        if (hasMalayalam) {
          _currentLocaleId = locales.firstWhere((l) => l.localeId.toLowerCase().startsWith('ml')).localeId;
        } else {
          final hasIndianEnglish = locales.any((l) => l.localeId.toLowerCase().contains('in'));
          if (hasIndianEnglish) {
            _currentLocaleId = locales.firstWhere((l) => l.localeId.toLowerCase().contains('in')).localeId;
          } else {
            _currentLocaleId = locales.isNotEmpty ? locales.first.localeId : 'en_US';
          }
        }
      }
      return _isSpeechInitialized;
    } catch (e) {
      debugPrint('SpeechToText initialization failed: ');
      _isSpeechInitialized = false;
      return false;
    }
  }

  Future<void> startListening({
    required Function(String recognizedWords, bool isFinal) onResult,
    String? preferredLocale,
  }) async {
    if (!_isSpeechInitialized) {
      final ok = await initSpeech();
      if (!ok) return;
    }

    _isListening = true;
    try {
      await _speechToText.listen(
        onResult: (result) {
          onResult(result.recognizedWords, result.finalResult);
          if (result.finalResult) {
            _isListening = false;
          }
        },
        listenOptions: SpeechListenOptions(
          cancelOnError: true,
          partialResults: true,
          listenFor: const Duration(seconds: 20),
          pauseFor: const Duration(seconds: 4),
          localeId: preferredLocale ?? _currentLocaleId,
        ),
      );
    } catch (e) {
      debugPrint('Speech listen error: ');
      _isListening = false;
    }
  }

  Future<void> stopListening() async {
    try {
      await _speechToText.stop();
    } catch (_) {}
    _isListening = false;
  }

  Future<void> cancelListening() async {
    try {
      await _speechToText.cancel();
    } catch (_) {}
    _isListening = false;
  }

  /// Symptom reasoning engine that matches natural spoken Malayalam and English to KAU crop diseases
  Future<VoiceDiagnosisResult> analyzeSpeechSymptoms(String query) async {
    final lowerQuery = query.toLowerCase().trim();
    if (lowerQuery.isEmpty) {
      final fallbackRx = DiseasePrescription.fromLabel('Background_Noise', 0.15);
      return VoiceDiagnosisResult(
        queryText: query,
        detectedCrop: 'None',
        diseaseKey: 'Background_Noise',
        confidence: 0.15,
        prescription: fallbackRx,
        spokenExplanationMl: 'ശബ്ദം വ്യക്തമല്ല. ദയവായി രോഗലക്ഷണങ്ങൾ വ്യക്തമായി വീണ്ടും പറയുക.',
        spokenExplanationEn: 'No clear speech input detected. Please describe the symptoms again.',
        matchedKeywords: [],
      );
    }

    // Step 1: Detect candidate crops from text
    String? targetCrop;
    for (final entry in _cropSynonyms.entries) {
      if (entry.value.any((syn) => lowerQuery.contains(syn.toLowerCase()))) {
        targetCrop = entry.key;
        break;
      }
    }

    // Step 2: Score disease profiles based on symptom matches
    String bestDiseaseKey = 'unmapped_pathology';
    double highestScore = 0.0;
    List<String> matchedTokens = [];

    for (final profile in _symptomProfiles) {
      // If crop was explicitly detected, prioritize diseases of that crop
      if (targetCrop != null && profile.cropKey.toLowerCase() != targetCrop.toLowerCase()) {
        continue;
      }

      double currentScore = 0.0;
      final currentMatched = <String>[];

      for (final keyword in profile.symptomKeywords) {
        if (lowerQuery.contains(keyword.toLowerCase())) {
          currentScore += profile.weightPerKeyword;
          currentMatched.add(keyword);
        }
      }

      if (currentScore > highestScore) {
        highestScore = currentScore;
        bestDiseaseKey = profile.diseaseKey;
        matchedTokens = currentMatched;
        targetCrop ??= profile.cropKey;
      }
    }

    // Fallback if crop was specified but no symptom matched
    if (highestScore == 0.0 && targetCrop != null) {
      final defaultForCrop = _defaultDiseaseForCrop[targetCrop] ?? 'unmapped_pathology';
      bestDiseaseKey = defaultForCrop;
      highestScore = 0.70;
      matchedTokens.add(targetCrop);
    } else if (highestScore == 0.0) {
      // Scan without crop constraint
      for (final profile in _symptomProfiles) {
        double score = 0.0;
        final currentMatched = <String>[];
        for (final keyword in profile.symptomKeywords) {
          if (lowerQuery.contains(keyword.toLowerCase())) {
            score += profile.weightPerKeyword;
            currentMatched.add(keyword);
          }
        }
        if (score > highestScore) {
          highestScore = score;
          bestDiseaseKey = profile.diseaseKey;
          matchedTokens = currentMatched;
          targetCrop = profile.cropKey;
        }
      }
    }

    final calculatedConfidence = (0.75 + math.min(0.23, highestScore * 0.12)).clamp(0.40, 0.98);

    final finalKey = (highestScore > 0.0) ? bestDiseaseKey : 'unmapped_pathology';
    final prescription = DiseasePrescription.fromLabel(finalKey, calculatedConfidence);
    Prescription? dbRx;
    try {
      dbRx = await _repository.getPrescription(finalKey);
    } catch (e) {
      debugPrint("VoiceAssistant DB query note: $e");
    }

    final String speechMl;
    final String speechEn;

    if (finalKey == 'unmapped_pathology' || highestScore == 0.0) {
      speechMl = 'നിങ്ങൾ പറഞ്ഞ ലക്ഷണങ്ങൾ പൂർണ്ണമായി തിരിച്ചറിയാൻ കഴിഞ്ഞിട്ടില്ല. കൃഷിഭവൻ ഉദ്യോഗസ്ഥരുമായി ബന്ധപ്പെടുക.';
      speechEn = 'Could not match exact symptoms to known disease patterns. Please verify symptoms or take a leaf photo.';
    } else {
      final diseaseTitle = dbRx?.diseaseNameMl ?? prescription.malayalamAudioText;
      final treatment = dbRx?.chemicalInstructionsMl ?? prescription.chemicalTreatment;
      speechMl = 'കണ്ടെത്തിയ രോഗം: $diseaseTitle. പ്രതിവിധി: $treatment. കൂടുതൽ വിവരങ്ങൾ സ്ക്രീനിൽ കാണാം.';
      speechEn = 'Probable diagnosis: ${prescription.diseaseName} on ${prescription.cropName}. Recommended cure: ${prescription.chemicalTreatment}.';
    }

    return VoiceDiagnosisResult(
      queryText: query,
      detectedCrop: targetCrop ?? 'Unknown Crop',
      diseaseKey: finalKey,
      confidence: calculatedConfidence,
      prescription: prescription,
      dbPrescription: dbRx,
      spokenExplanationMl: speechMl,
      spokenExplanationEn: speechEn,
      matchedKeywords: matchedTokens,
    );
  }

  static const Map<String, List<String>> _cropSynonyms = {
    'Paddy': ['നെല്ല്', 'നെൽ', 'നെല്ലിലെ', 'വയൽ', 'കതിർ', 'nellu', 'paddy', 'rice'],
    'Coconut': ['തെങ്ങ്', 'തേങ്ങ', 'തെങ്ങിലെ', 'മണ്ട', 'കുള്ളൻ തെങ്ങ്', 'thengu', 'coconut', 'palm'],
    'Banana': ['വാഴ', 'വാഴയിലെ', 'ഏത്തവാഴ', 'ഞാലിപ്പൂവൻ', 'vazha', 'banana', 'plantain'],
    'Brinjal': ['വഴുതന', 'വഴുതനയിലെ', 'കത്തിരി', 'vazhuthana', 'brinjal', 'eggplant'],
    'Okra': ['വെണ്ട', 'വെണ്ടയിലെ', 'വെണ്ടയ്ക്ക', 'venda', 'okra', 'ladies finger', 'ladyfinger', 'bhendi'],
    'Tomato': ['തക്കാളി', 'തക്കാളിയിലെ', 'thakkali', 'tomato'],
    'Potato': ['ഉരുളക്കിഴങ്ങ്', 'കിഴങ്ങ്', 'potato'],
    'Pepper': ['മുളക്', 'മുളകിലെ', 'കാപ്സിക്കം', 'pepper', 'chilli', 'capsicum'],
  };

  static const Map<String, String> _defaultDiseaseForCrop = {
    'Paddy': 'Rice_Blast',
    'Coconut': 'Coconut_Bud_Rot',
    'Banana': 'Banana_Sigatoka_Leaf_Spot',
    'Brinjal': 'Brinjal_Bacterial_Wilt',
    'Okra': 'Okra_Yellow_Vein_Mosaic',
    'Tomato': 'Tomato_Early_blight',
    'Potato': 'Potato_Late_blight',
    'Pepper': 'Pepper_bell_Bacterial_spot',
  };

  static final List<_SymptomProfile> _symptomProfiles = [
    // 1. Paddy Diseases
    _SymptomProfile(
      diseaseKey: 'Rice_Blast',
      cropKey: 'Paddy',
      symptomKeywords: [
        'ബ്ലാസ്റ്റ്', 'കുലവാട്ടം', 'കഴുത്തൊടിയൽ', 'കതിരൊടിയൽ', 'കതിർ ഒടിയുന്നു',
        'നൂൽ പുള്ളി', 'ചാരനിറമുള്ള പുള്ളി', 'blast', 'spindle', 'neck rot', 'eye shaped'
      ],
      weightPerKeyword: 1.0,
    ),
    _SymptomProfile(
      diseaseKey: 'Rice_Bacterial_Blight',
      cropKey: 'Paddy',
      symptomKeywords: [
        'ബാക്ടീരിയൽ', 'ഇലകരിച്ചിൽ', 'ഇല കരിയുന്നു', 'മഞ്ഞ വരകൾ', 'അഗ്രം ഉണങ്ങുന്നു',
        'bacterial blight', 'leaf drying', 'wavy stripes', 'bacterial ooze'
      ],
      weightPerKeyword: 1.0,
    ),
    _SymptomProfile(
      diseaseKey: 'Rice_healthy',
      cropKey: 'Paddy',
      symptomKeywords: ['ആരോഗ്യം', 'പച്ചപ്പ്', 'നല്ല നെല്ല്', 'രോഗമില്ല', 'healthy paddy', 'green tillers'],
      weightPerKeyword: 1.0,
    ),

    // 2. Coconut Diseases
    _SymptomProfile(
      diseaseKey: 'Coconut_Bud_Rot',
      cropKey: 'Coconut',
      symptomKeywords: [
        'മണ്ടയഴുകൽ', 'മണ്ട ചീയുന്നു', 'നാമ്പോമ്പ് ചീയൽ', 'കൂമ്പ് ചീയൽ', 'നാമ്പ് ഒടിയുന്നു',
        'ദുർഗന്ധം', 'ഓലകൾ മഞ്ഞളിക്കുന്നു', 'bud rot', 'spear leaf', 'crown rot', 'foul odor'
      ],
      weightPerKeyword: 1.0,
    ),
    _SymptomProfile(
      diseaseKey: 'Coconut_Stem_Bleeding',
      cropKey: 'Coconut',
      symptomKeywords: [
        'തടി ഒഴുക്ക്', 'തടിയിൽ വിള്ളൽ', 'ചുവന്ന കറ', 'കറയൊഴുക്ക്', 'തടി ചീയൽ',
        'കറുത്ത നീര്', 'stem bleeding', 'exudate', 'bark crack', 'trunk bleeding'
      ],
      weightPerKeyword: 1.0,
    ),
    _SymptomProfile(
      diseaseKey: 'Coconut_healthy',
      cropKey: 'Coconut',
      symptomKeywords: ['ആരോഗ്യമുള്ള തെങ്ങ്', 'നല്ല വിളവ്', 'പച്ചപ്പ്', 'healthy palm'],
      weightPerKeyword: 1.0,
    ),

    // 3. Banana Diseases
    _SymptomProfile(
      diseaseKey: 'Banana_Panama_Wilt',
      cropKey: 'Banana',
      symptomKeywords: [
        'പനാമ വാട്ടം', 'പനാമ', 'വാട്ടം', 'ഇല ഒടിഞ്ഞുതൂങ്ങുന്നു', 'ഒടിഞ്ഞു തൂങ്ങൽ',
        'താഴത്തെ ഇലകൾ മഞ്ഞളിക്കുന്നു', 'ചുവട്ടിൽ വിള്ളൽ', 'panama', 'wilt', 'skirt', 'wilting', 'yellowing leaves'
      ],
      weightPerKeyword: 1.0,
    ),
    _SymptomProfile(
      diseaseKey: 'Banana_Sigatoka_Leaf_Spot',
      cropKey: 'Banana',
      symptomKeywords: [
        'സിഗാറ്റോക്ക', 'ഇലപ്പുള്ളി', 'തവിട്ടു പുള്ളി', 'ഇല ഉണങ്ങുന്നു', 'കരിഞ്ഞുപോകുന്നു',
        'sigatoka', 'leaf spot', 'streaks', 'spotted leaves'
      ],
      weightPerKeyword: 1.0,
    ),
    _SymptomProfile(
      diseaseKey: 'Banana_healthy',
      cropKey: 'Banana',
      symptomKeywords: ['ആരോഗ്യമുള്ള വാഴ', 'നല്ല ഇല', 'പച്ചപ്പ്', 'healthy banana'],
      weightPerKeyword: 1.0,
    ),

    // 4. Brinjal Diseases
    _SymptomProfile(
      diseaseKey: 'Brinjal_Bacterial_Wilt',
      cropKey: 'Brinjal',
      symptomKeywords: [
        'ബാക്ടീരിയൽ വാട്ടം', 'വാട്ടം', 'ചെടി പെട്ടെന്ന് വാടുന്നു', 'ഇലകൾ തളരുന്നു',
        'bacterial wilt', 'sudden collapse', 'wilting plant'
      ],
      weightPerKeyword: 1.0,
    ),
    _SymptomProfile(
      diseaseKey: 'Brinjal_Little_Leaf',
      cropKey: 'Brinjal',
      symptomKeywords: [
        'ചെറു ഇല', 'ഇല ചെറുതാകുന്നു', 'ചെറുതാവുന്നു', 'കൂട്ടം കൂടുന്നു', 'പൂവിടുന്നില്ല',
        'little leaf', 'small leaves', 'stunted growth', 'bushy'
      ],
      weightPerKeyword: 1.0,
    ),
    _SymptomProfile(
      diseaseKey: 'Brinjal_healthy',
      cropKey: 'Brinjal',
      symptomKeywords: ['ആരോഗ്യമുള്ള വഴുതന', 'നല്ല ചെടി', 'healthy brinjal'],
      weightPerKeyword: 1.0,
    ),

    // 5. Okra Diseases
    _SymptomProfile(
      diseaseKey: 'Okra_Yellow_Vein_Mosaic',
      cropKey: 'Okra',
      symptomKeywords: [
        'മഞ്ഞ ഞരമ്പ്', 'ഞരമ്പ് മഞ്ഞളിപ്പ്', 'ഇല മഞ്ഞളിക്കുന്നു', 'വെള്ളീച്ച', 'മഞ്ഞനിറം',
        'yellow vein', 'mosaic', 'vein clearing', 'yellow okra'
      ],
      weightPerKeyword: 1.0,
    ),
    _SymptomProfile(
      diseaseKey: 'Okra_Powdery_Mildew',
      cropKey: 'Okra',
      symptomKeywords: [
        'ചാരരോഗം', 'വെള്ളപ്പൊടി', 'പൊടി രൂപത്തിൽ', 'ഇലയിൽ വെളുത്ത പാടുകൾ',
        'powdery mildew', 'white powder', 'mildew spots'
      ],
      weightPerKeyword: 1.0,
    ),
    _SymptomProfile(
      diseaseKey: 'Okra_healthy',
      cropKey: 'Okra',
      symptomKeywords: ['ആരോഗ്യമുള്ള വെണ്ട', 'നല്ല പച്ചപ്പ്', 'healthy okra'],
      weightPerKeyword: 1.0,
    ),

    // 6. Tomato Diseases
    _SymptomProfile(
      diseaseKey: 'Tomato_Late_blight',
      cropKey: 'Tomato',
      symptomKeywords: [
        'ലേറ്റ് ബ്ലൈറ്റ്', 'കരിഞ്ഞുണങ്ങൽ', 'ഇല കരിയുന്നു', 'തണ്ട് കറുക്കുന്നു', 'വെള്ളം നനഞ്ഞ പാട്',
        'late blight', 'dark lesions', 'water soaked rot'
      ],
      weightPerKeyword: 1.0,
    ),
    _SymptomProfile(
      diseaseKey: 'Tomato_Early_blight',
      cropKey: 'Tomato',
      symptomKeywords: [
        'ഏർലി ബ്ലൈറ്റ്', 'വളയപ്പുള്ളി', 'കറുത്ത വളയങ്ങൾ', 'ഉണങ്ങിയ പുള്ളികൾ',
        'early blight', 'concentric rings', 'target spot'
      ],
      weightPerKeyword: 1.0,
    ),
    _SymptomProfile(
      diseaseKey: 'Tomato_Leaf_Mold',
      cropKey: 'Tomato',
      symptomKeywords: [
        'ലീഫ് മോൾഡ്', 'ഇലപ്പൂപ്പ്', 'ഇലയുടെ അടിയിൽ പൂപ്പ്', 'മഞ്ഞപ്പുള്ളി',
        'leaf mold', 'velvet mold', 'yellow patches'
      ],
      weightPerKeyword: 1.0,
    ),
    _SymptomProfile(
      diseaseKey: 'Tomato_Septoria_leaf_spot',
      cropKey: 'Tomato',
      symptomKeywords: ['സെപ്റ്റോറിയ', 'ഇലപ്പുള്ളി', 'ചെറിയ പുള്ളികൾ', 'septoria'],
      weightPerKeyword: 1.0,
    ),
    _SymptomProfile(
      diseaseKey: 'Tomato_healthy',
      cropKey: 'Tomato',
      symptomKeywords: ['ആരോഗ്യമുള്ള തക്കാളി', 'healthy tomato'],
      weightPerKeyword: 1.0,
    ),

    // 7. Potato Diseases
    _SymptomProfile(
      diseaseKey: 'Potato_Late_blight',
      cropKey: 'Potato',
      symptomKeywords: ['ലേറ്റ് ബ്ലൈറ്റ്', 'കരിഞ്ഞുണങ്ങൽ', 'കിഴങ്ങ് അഴുകൽ', 'late blight potato'],
      weightPerKeyword: 1.0,
    ),
    _SymptomProfile(
      diseaseKey: 'Potato_Early_blight',
      cropKey: 'Potato',
      symptomKeywords: ['ഏർലി ബ്ലൈറ്റ്', 'വളയപ്പുള്ളി', 'early blight potato'],
      weightPerKeyword: 1.0,
    ),
    _SymptomProfile(
      diseaseKey: 'Potato_healthy',
      cropKey: 'Potato',
      symptomKeywords: ['ആരോഗ്യമുള്ള ഉരുളക്കിഴങ്ങ്', 'healthy potato'],
      weightPerKeyword: 1.0,
    ),

    // 8. Pepper Diseases
    _SymptomProfile(
      diseaseKey: 'Pepper_bell_Bacterial_spot',
      cropKey: 'Pepper',
      symptomKeywords: ['ബാക്ടീരിയൽ ഇലപ്പുള്ളി', 'കറുത്ത പുള്ളി', 'ഇല കൊഴിച്ചിൽ', 'bacterial spot pepper'],
      weightPerKeyword: 1.0,
    ),
    _SymptomProfile(
      diseaseKey: 'Pepper_bell_healthy',
      cropKey: 'Pepper',
      symptomKeywords: ['ആരോഗ്യമുള്ള മുളക്', 'healthy pepper'],
      weightPerKeyword: 1.0,
    ),
  ];
}

class _SymptomProfile {
  final String diseaseKey;
  final String cropKey;
  final List<String> symptomKeywords;
  final double weightPerKeyword;

  const _SymptomProfile({
    required this.diseaseKey,
    required this.cropKey,
    required this.symptomKeywords,
    required this.weightPerKeyword,
  });
}
