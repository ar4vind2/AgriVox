import 'dart:io';
import 'package:flutter/material.dart';
import '../../services/voice_assistant_service.dart';
import '../../services/voice_service.dart';
import 'result_screen.dart';

class VoiceAssistantScreen extends StatefulWidget {
  const VoiceAssistantScreen({super.key});

  @override
  State<VoiceAssistantScreen> createState() => _VoiceAssistantScreenState();
}

class _VoiceAssistantScreenState extends State<VoiceAssistantScreen> with SingleTickerProviderStateMixin {
  final AgronomyVoiceAssistantService _assistantService = AgronomyVoiceAssistantService();
  final VoiceService _voiceService = VoiceService();
  final TextEditingController _textController = TextEditingController();

  late AnimationController _animController;
  late Animation<double> _scaleAnimation;

  bool _isListening = false;
  bool _isProcessing = false;
  bool _isPlayingAudio = false;
  String _currentLocale = 'ml_IN';
  VoiceDiagnosisResult? _diagnosisResult;

  final List<String> _samplePrompts = [
    'വാഴയിൽ ഇലകൾ മഞ്ഞളിച്ച് ഒടിഞ്ഞുതൂങ്ങുന്നു',
    'നെല്ലിൽ കതിരുകൾ ഒടിഞ്ഞ് കുലവാട്ടം വരുന്നു',
    'തെങ്ങിന്റെ മണ്ട ചീഞ്ഞ് ദുർഗന്ധം വമിക്കുന്നു',
    'വെണ്ടയുടെ ഇലയിൽ മഞ്ഞ ഞരമ്പുകൾ കാണുന്നു',
    'തക്കാളി ഇലകളിൽ കരിഞ്ഞുണങ്ങൽ പടരുന്നു',
    'വഴുതനച്ചെടി പെട്ടെന്ന് വാടിപ്പോകുന്നു',
    'Tomato leaves have brown circular target spots',
    'Coconut trunk shows dark reddish fluid bleeding',
  ];

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);

    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.25).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeInOut),
    );

    _initAssistant();
  }

  Future<void> _initAssistant() async {
    await _assistantService.initSpeech();
    await _voiceService.init();
    _voiceService.setCompletionHandler(() {
      if (mounted) setState(() => _isPlayingAudio = false);
    });
  }

  @override
  void dispose() {
    _animController.dispose();
    _assistantService.stopListening();
    _voiceService.stop();
    _textController.dispose();
    super.dispose();
  }

  void _toggleListening() async {
    if (_isListening) {
      await _assistantService.stopListening();
      setState(() => _isListening = false);
      if (_textController.text.trim().isNotEmpty) {
        _runDiagnosis(_textController.text.trim());
      }
    } else {
      await _voiceService.stop();
      setState(() {
        _isListening = true;
        _isPlayingAudio = false;
      });

      await _assistantService.startListening(
        preferredLocale: _currentLocale,
        onResult: (text, isFinal) {
          if (mounted) {
            setState(() {
              _textController.text = text;
            });
            if (isFinal && text.trim().isNotEmpty) {
              setState(() => _isListening = false);
              _runDiagnosis(text.trim());
            }
          }
        },
      );
    }
  }

  Future<void> _runDiagnosis(String query) async {
    if (query.trim().isEmpty) return;
    setState(() => _isProcessing = true);

    final result = await _assistantService.analyzeSpeechSymptoms(query);

    if (mounted) {
      setState(() {
        _diagnosisResult = result;
        _isProcessing = false;
      });

      // Auto-play spoken Malayalam guidance
      _playAudioExplanation(result);
    }
  }

  void _playAudioExplanation(VoiceDiagnosisResult result) async {
    setState(() => _isPlayingAudio = true);
    if (_currentLocale.startsWith('ml')) {
      await _voiceService.speakMalayalam(result.spokenExplanationMl);
    } else {
      await _voiceService.speakEnglish(result.spokenExplanationEn);
    }
    if (mounted) setState(() => _isPlayingAudio = false);
  }

  void _openFullResultScreen(VoiceDiagnosisResult result) {
    // Generate empty dummy File or cached image for navigation contract
    final tempFile = File('/voice_rx_placeholder.jpg');
    if (!tempFile.existsSync()) {
      tempFile.writeAsBytesSync([0xFF, 0xD8, 0xFF, 0xE0, 0x00, 0x10, 0x4A, 0x46, 0x49, 0x46, 0x00, 0x01]);
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ResultScreen(
          croppedImage: tempFile,
          prescription: result.prescription,
          initialCrop: result.detectedCrop,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isMl = _currentLocale.startsWith('ml');

    return Scaffold(
      backgroundColor: const Color(0xFFF6F8F5),
      appBar: AppBar(
        title: Text(isMl ? 'കൃഷി വോയ്‌സ് അസിസ്റ്റന്റ്' : 'AgriVoice Copilot'),
        backgroundColor: Colors.green.shade800,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          // Language Switcher
          Container(
            margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: TextButton.icon(
              style: TextButton.styleFrom(
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 10),
              ),
              icon: const Icon(Icons.language, size: 16),
              label: Text(
                isMl ? 'മലയാളം' : 'English',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              onPressed: () {
                setState(() {
                  _currentLocale = isMl ? 'en_IN' : 'ml_IN';
                });
              },
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Explanatory Banner
            Card(
              elevation: 0,
              color: Colors.green.shade50,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(color: Colors.green.shade200),
              ),
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Row(
                  children: [
                    Icon(Icons.mic, color: Colors.green.shade800, size: 30),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        isMl
                            ? 'വിളയെയും രോഗലക്ഷണങ്ങളെയും കുറിച്ച് സംസാരിക്കൂ. അസിസ്റ്റന്റ് രോഗനിർണ്ണയവും പരിഹാരവും പറഞ്ഞുതരും.'
                            : 'Speak about your crop symptoms in Malayalam or English to get instant KAU diagnosis.',
                        style: TextStyle(
                          fontSize: 13.5,
                          color: Colors.green.shade900,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Animated Mic Center Stage
            Center(
              child: Column(
                children: [
                  GestureDetector(
                    onTap: _toggleListening,
                    child: AnimatedBuilder(
                      animation: _scaleAnimation,
                      builder: (context, child) {
                        return Transform.scale(
                          scale: _isListening ? _scaleAnimation.value : 1.0,
                          child: Container(
                            width: 90,
                            height: 90,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: LinearGradient(
                                colors: _isListening
                                    ? [Colors.red.shade400, Colors.red.shade700]
                                    : [Colors.green.shade600, Colors.green.shade900],
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: (_isListening ? Colors.red : Colors.green).withValues(alpha: 0.35),
                                  blurRadius: 18,
                                  spreadRadius: _isListening ? 6 : 2,
                                ),
                              ],
                            ),
                            child: Icon(
                              _isListening ? Icons.mic : Icons.mic_none,
                              color: Colors.white,
                              size: 42,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    _isListening
                        ? (isMl ? 'ശ്രദ്ധിക്കുന്നു... പറയൂ' : 'Listening... Speak now')
                        : (isMl ? 'സംസാരിക്കാൻ മൈക്ക് അമർത്തുക' : 'Tap microphone to speak'),
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: _isListening ? Colors.red.shade700 : Colors.grey.shade700,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Transcript Box with Manual Edit Option
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        isMl ? 'കർഷകൻ പറഞ്ഞത് / ചോദ്യം:' : 'Farmer Input:',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      if (_textController.text.isNotEmpty)
                        IconButton(
                          icon: const Icon(Icons.clear, size: 18),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                          onPressed: () {
                            setState(() {
                              _textController.clear();
                              _diagnosisResult = null;
                            });
                          },
                        ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  TextField(
                    controller: _textController,
                    maxLines: 2,
                    decoration: InputDecoration(
                      hintText: isMl
                          ? 'ഉദാ: വാഴയിൽ ഇലകൾ മഞ്ഞളിക്കുന്നു...'
                          : 'e.g. Banana leaves are turning yellow...',
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.zero,
                    ),
                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
                    onSubmitted: (text) => _runDiagnosis(text),
                  ),
                  if (!_isListening && _textController.text.trim().isNotEmpty) ...[
                    const Divider(height: 16),
                    Align(
                      alignment: Alignment.centerRight,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green.shade700,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        ),
                        onPressed: () => _runDiagnosis(_textController.text.trim()),
                        icon: const Icon(Icons.analytics_outlined, size: 16),
                        label: Text(isMl ? 'രോഗം കണ്ടെത്തൂ' : 'Analyze Symptoms'),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Quick Symptom Chips
            Text(
              isMl ? 'ലക്ഷണങ്ങൾ തിരഞ്ഞെടുക്കാം (Quick Chips):' : 'Or Tap Common Crop Symptoms:',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade700,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _samplePrompts.map((prompt) {
                return ActionChip(
                  label: Text(prompt, style: const TextStyle(fontSize: 12)),
                  backgroundColor: Colors.white,
                  side: BorderSide(color: Colors.green.shade200),
                  onPressed: () {
                    _textController.text = prompt;
                    _runDiagnosis(prompt);
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 20),

            // Loading Indicator
            if (_isProcessing) ...[
              const Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 24),
                  child: CircularProgressIndicator(),
                ),
              ),
            ],

            // Diagnosis Result Card
            if (_diagnosisResult != null && !_isProcessing) ...[
              _buildDiagnosisCard(_diagnosisResult!, isMl, theme),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildDiagnosisCard(VoiceDiagnosisResult result, bool isMl, ThemeData theme) {
    final rx = result.prescription;
    final dbRx = result.dbPrescription;
    final isUnmapped = result.diseaseKey == 'unmapped_pathology' || result.diseaseKey == 'Background_Noise';

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isUnmapped ? Colors.orange.shade300 : Colors.green.shade400,
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: (isUnmapped ? Colors.orange : Colors.green).withValues(alpha: 0.1),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row: Crop & Confidence
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.green.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  rx.cropName,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.green.shade900,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: isUnmapped ? Colors.orange.shade100 : Colors.blue.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '% Confidence',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: isUnmapped ? Colors.orange.shade900 : Colors.blue.shade900,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Disease Title & Voice Button
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      dbRx?.diseaseNameMl ?? rx.diseaseName,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: isUnmapped ? Colors.deepOrange : Colors.green.shade800,
                      ),
                    ),
                    Text(
                      dbRx?.diseaseNameEn ?? rx.scientificName,
                      style: TextStyle(fontSize: 13.5, color: Colors.grey.shade600),
                    ),
                  ],
                ),
              ),
              IconButton.filled(
                onPressed: () {
                  if (_isPlayingAudio) {
                    _voiceService.stop();
                    setState(() => _isPlayingAudio = false);
                  } else {
                    _playAudioExplanation(result);
                  }
                },
                icon: Icon(_isPlayingAudio ? Icons.stop : Icons.volume_up),
                style: IconButton.styleFrom(
                  backgroundColor: _isPlayingAudio ? Colors.red : Colors.green.shade700,
                ),
              ),
            ],
          ),
          const Divider(height: 24),

          // Treatment Box: Chemical & Organic
          Text(
            isMl ? 'പ്രതിവിധി നിർദ്ദേശം (KAU Advisory):' : 'Recommended Management:',
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
          ),
          const SizedBox(height: 8),

          // Chemical
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.red.shade50.withValues(alpha: 0.6),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.red.shade100),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.science, color: Colors.red.shade700, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isMl ? 'രാസ നിയന്ത്രണം (Chemical)' : 'Chemical Cure',
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.red.shade900),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        dbRx?.chemicalInstructionsMl ?? rx.chemicalTreatment,
                        style: const TextStyle(fontSize: 13),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),

          // Organic
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.green.shade50.withValues(alpha: 0.6),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.green.shade100),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.eco, color: Colors.green.shade700, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isMl ? 'ജൈവ നിയന്ത്രണം (Organic)' : 'Organic Control',
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.green.shade900),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        dbRx?.organicInstructionsMl ?? rx.organicTreatment,
                        style: const TextStyle(fontSize: 13),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Full details and dosage math CTA button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green.shade800,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: () => _openFullResultScreen(result),
              icon: const Icon(Icons.calculate_outlined),
              label: Text(
                isMl ? 'ടാങ്ക് അളവും വിശദാംശങ്ങളും കാണുക' : 'View Knapsack Dosage Calculator',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
