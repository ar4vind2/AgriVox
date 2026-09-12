import 'dart:io';
import 'package:flutter/material.dart';
import '../../models/disease_prescription.dart';
import '../../services/prescription_repository.dart';
import '../../services/dosage_calculator.dart';
import '../../services/voice_service.dart';

class ResultScreen extends StatefulWidget {
  final File croppedImage;
  final DiseasePrescription prescription;
  final Map<String, double>? classProbabilities;
  final String? initialCrop;

  const ResultScreen({
    super.key,
    required this.croppedImage,
    required this.prescription,
    this.classProbabilities,
    this.initialCrop,
  });

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen> {
  final VoiceService _voiceService = VoiceService();
  final PrescriptionRepository _repository = PrescriptionRepository();

  late DiseasePrescription _activePrescription;
  late String _currentCrop;
  Prescription? _dbPrescription;
  bool _isPlayingMalayalam = false;
  bool _isPlayingEnglish = false;
  int _selectedTankVolume = 16;

  @override
  void initState() {
    super.initState();
    _activePrescription = widget.prescription;
    _currentCrop = widget.initialCrop ?? 'All';
    if (_currentCrop == 'All') {
      if (_activePrescription.cropName.toLowerCase().contains('pepper')) {
        _currentCrop = 'Pepper';
      } else if (_activePrescription.cropName.toLowerCase().contains('potato')) {
        _currentCrop = 'Potato';
      } else {
        _currentCrop = 'Tomato';
      }
    }
    _initServices();
  }

  Future<void> _initServices() async {
    await _voiceService.init();
    _voiceService.setCompletionHandler(() {
      if (mounted) {
        setState(() {
          _isPlayingMalayalam = false;
          _isPlayingEnglish = false;
        });
      }
    });

    await _loadDbPrescription(_activePrescription.diseaseId);
  }

  Future<void> _loadDbPrescription(String diseaseId) async {
    try {
      final dbResult = await _repository.getPrescription(diseaseId);
      if (mounted) {
        setState(() {
          _dbPrescription = dbResult;
        });
      }
    } catch (e) {
      debugPrint("SQLite DB lookup error: $e");
    }
  }

  Future<void> _switchCrop(String cropKey) async {
    if (_currentCrop.toLowerCase() == cropKey.toLowerCase()) return;
    await _voiceService.stop();

    setState(() {
      _isPlayingMalayalam = false;
      _isPlayingEnglish = false;
      _currentCrop = cropKey;
    });

    final probs = widget.classProbabilities;
    if (probs != null && probs.isNotEmpty) {
      final candidateEntries = probs.entries
          .where((e) => e.key.toLowerCase().contains(cropKey.toLowerCase()))
          .toList();

      if (candidateEntries.isNotEmpty) {
        candidateEntries.sort((a, b) => b.value.compareTo(a.value));
        final best = candidateEntries.first;
        final sumCrop = candidateEntries.fold<double>(0.0, (sum, e) => sum + e.value);
        final normalizedConf = sumCrop > 0 ? (best.value / sumCrop).clamp(0.0, 1.0) : 0.90;

        final newPrescription = DiseasePrescription.fromLabel(best.key, normalizedConf);
        setState(() {
          _activePrescription = newPrescription;
        });
        await _loadDbPrescription(newPrescription.diseaseId);
        return;
      }
    }

    String fallbackLabel;
    if (cropKey.toLowerCase() == 'pepper') {
      fallbackLabel = 'Pepper_bell_Bacterial_spot';
    } else if (cropKey.toLowerCase() == 'potato') {
      fallbackLabel = 'Potato_Early_blight';
    } else {
      fallbackLabel = 'Tomato_Early_blight';
    }
    final newPrescription = DiseasePrescription.fromLabel(fallbackLabel, 0.92);
    setState(() {
      _activePrescription = newPrescription;
    });
    await _loadDbPrescription(fallbackLabel);
  }

  @override
  void dispose() {
    _voiceService.stop();
    super.dispose();
  }

  Future<void> _toggleMalayalamVoice() async {
    if (_isPlayingMalayalam) {
      await _voiceService.stop();
      setState(() {
        _isPlayingMalayalam = false;
      });
      return;
    }

    setState(() {
      _isPlayingMalayalam = true;
      _isPlayingEnglish = false;
    });

    if (_dbPrescription != null) {
      await _voiceService.speakPrescription(
        diseaseMl: _dbPrescription!.diseaseNameMl,
        chemicalTreatmentMl: _dbPrescription!.chemicalInstructionsMl,
        organicTreatmentMl: _dbPrescription!.organicInstructionsMl,
      );
    } else {
      await _voiceService.speakMalayalam(_activePrescription.malayalamAudioText);
    }
  }

  Future<void> _toggleEnglishVoice() async {
    if (_isPlayingEnglish) {
      await _voiceService.stop();
      setState(() {
        _isPlayingEnglish = false;
      });
      return;
    }

    setState(() {
      _isPlayingEnglish = true;
      _isPlayingMalayalam = false;
    });

    await _voiceService.speakEnglish(_activePrescription.englishAudioText);
  }

  @override
  Widget build(BuildContext context) {
    final prescription = _activePrescription;
    final isHealthy = prescription.severity == SeverityLevel.healthy;
    final isSevere = prescription.severity == SeverityLevel.severe;
    final severityColor = isHealthy
        ? Colors.green
        : isSevere
            ? Colors.red.shade700
            : Colors.amber.shade800;

    return Scaffold(
      backgroundColor: const Color(0xFFF6F8F5),
      appBar: AppBar(
        title: Row(
          children: [
            Image.asset(
              'assets/icon/app_icon_no_bg.png',
              width: 26,
              height: 26,
              fit: BoxFit.contain,
            ),
            const SizedBox(width: 8),
            const Text("Diagnostic Report", style: TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0.5,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Cropped Leaf Lesion Thumbnail & Diagnostic Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.grey.shade200),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(14),
                  child: Image.file(
                    widget.croppedImage,
                    width: 100,
                    height: 100,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: severityColor.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          isHealthy ? "HEALTHY LEAF" : "DISEASE DETECTED",
                          style: TextStyle(
                            color: severityColor,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        _dbPrescription?.diseaseNameEn ?? prescription.diseaseName,
                        style: const TextStyle(fontSize: 19, fontWeight: FontWeight.bold, height: 1.2),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        _dbPrescription?.cropName ?? prescription.cropName,
                        style: TextStyle(fontSize: 13, color: Colors.grey.shade700),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.green.shade50,
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(color: Colors.green.shade200),
                            ),
                            child: Text(
                              "${(prescription.confidence * 100).toStringAsFixed(1)}% Confidence",
                              style: TextStyle(color: Colors.green.shade800, fontSize: 11, fontWeight: FontWeight.bold),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              prescription.scientificName,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(fontStyle: FontStyle.italic, color: Colors.grey.shade600, fontSize: 11),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // Crop Context Switcher Card
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.tune, size: 16, color: Colors.green.shade700),
                    const SizedBox(width: 6),
                    Text(
                      "Scanning a different crop? Switch view:",
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey.shade800),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildCropSwitchChip('Pepper', '🌶️ Bell Pepper (കാപ്സിക്കം)'),
                      const SizedBox(width: 8),
                      _buildCropSwitchChip('Tomato', '🍅 Tomato (തക്കാളി)'),
                      const SizedBox(width: 8),
                      _buildCropSwitchChip('Potato', '🥔 Potato (ഉരുളക്കിഴങ്ങ്)'),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Low-Confidence Diagnostic Guardrail Warning (<60%)
          if (prescription.confidence < 0.60) ...[
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFFFFFBEB),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFF59E0B), width: 1.5),
                boxShadow: [
                  BoxShadow(
                    color: Colors.amber.withValues(alpha: 0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.warning_amber_rounded, color: Color(0xFFD97706), size: 24),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Low-Confidence Scan (<60%)",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            color: Color(0xFFB45309),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "The leaf lesion may be indistinct, poorly illuminated, or out of focus. Recommended: Wipe the camera lens, ensure bright diffuse lighting, hold the phone 15–20cm from the leaf, and re-scan for higher accuracy.",
                          style: TextStyle(
                            fontSize: 12.5,
                            height: 1.35,
                            color: Colors.brown.shade800,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],

          // Voice Copilot Audio Card (Offline Indic Malayalam & English TTS)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.green.shade800, Colors.teal.shade700],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.green.shade900.withValues(alpha: 0.2),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(
                          _isPlayingMalayalam || _isPlayingEnglish ? Icons.graphic_eq : Icons.volume_up,
                          color: Colors.white,
                          size: 22,
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          "Voice Copilot (Offline TTS)",
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15),
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.25),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        _isPlayingMalayalam
                            ? "Playing ML..."
                            : _isPlayingEnglish
                                ? "Playing EN..."
                                : "മലയാളം / EN",
                        style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  _dbPrescription?.diseaseNameMl ?? prescription.malayalamAudioText,
                  style: const TextStyle(color: Colors.white, fontSize: 14, height: 1.4),
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _isPlayingMalayalam ? Colors.amber.shade300 : Colors.white,
                          foregroundColor: Colors.green.shade900,
                          elevation: 0,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          padding: const EdgeInsets.symmetric(vertical: 10),
                        ),
                        icon: Icon(_isPlayingMalayalam ? Icons.stop : Icons.play_arrow, size: 20),
                        label: Text(
                          _isPlayingMalayalam ? "നിർത്തുക (Stop)" : "കേൾക്കുക (Malayalam)",
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                        ),
                        onPressed: _toggleMalayalamVoice,
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      style: IconButton.styleFrom(
                        backgroundColor: _isPlayingEnglish ? Colors.amber.shade300 : Colors.white.withValues(alpha: 0.25),
                        foregroundColor: Colors.white,
                      ),
                      icon: Icon(_isPlayingEnglish ? Icons.stop : Icons.volume_up, size: 20),
                      tooltip: "Listen in English",
                      onPressed: _toggleEnglishVoice,
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Symptoms & Diagnostic Indicators
          _buildInfoCard(
            title: "Symptoms & Diagnostic Indicators",
            icon: Icons.biotech,
            color: Colors.indigo,
            content: prescription.symptoms,
          ),

          const SizedBox(height: 12),

          // Chemical Spray & Treatment (from KAU Package of Practices SQLite Database)
          _buildInfoCard(
            title: "Chemical Treatment (KAU Practices)",
            icon: Icons.science,
            color: Colors.blue.shade800,
            content: _dbPrescription != null
                ? "${_dbPrescription!.chemicalCure} (${_dbPrescription!.dosagePerLiter}g/L)\n\n${_dbPrescription!.chemicalInstructionsMl}"
                : prescription.chemicalTreatment,
          ),

          const SizedBox(height: 12),

          // Spray Tank Dosage Calculator (Dynamic Knapsack Math: 10L, 12L, 16L, 20L)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.amber.shade300, width: 1.5),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.calculate, color: Colors.amber.shade900, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          "Knapsack Tank Preparation (${_selectedTankVolume}L)",
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.amber.shade900),
                        ),
                      ],
                    ),
                    if (_dbPrescription != null && _dbPrescription!.waitingPeriodDays > 0)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: Colors.red.shade50,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.red.shade200),
                        ),
                        child: Text(
                          "Wait: ${_dbPrescription!.waitingPeriodDays} Days",
                          style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.red.shade800),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 12),
                // Tank Volume Slider with live indicator
                Row(
                  children: [
                    Text(
                      "Volume: ",
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.grey.shade800),
                    ),
                    Expanded(
                      child: Slider(
                        value: _selectedTankVolume.toDouble(),
                        min: 5,
                        max: 25,
                        divisions: 20,
                        activeColor: Colors.amber.shade800,
                        inactiveColor: Colors.amber.shade100,
                        label: "${_selectedTankVolume}L",
                        onChanged: (val) {
                          setState(() {
                            _selectedTankVolume = val.round();
                          });
                        },
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: Colors.amber.shade100,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        "$_selectedTankVolume L",
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.amber.shade900),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                // Quick-select preset Tank Volume Chips
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [8, 10, 12, 16, 20].map((volume) {
                      final isSelected = _selectedTankVolume == volume;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: ChoiceChip(
                          label: Text("${volume}L Tank"),
                          selected: isSelected,
                          selectedColor: Colors.amber.shade200,
                          backgroundColor: Colors.grey.shade100,
                          side: BorderSide(
                            color: isSelected ? Colors.amber.shade700 : Colors.grey.shade300,
                          ),
                          labelStyle: TextStyle(
                            color: isSelected ? Colors.amber.shade900 : Colors.black87,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                            fontSize: 12,
                          ),
                          onSelected: (selected) {
                            if (selected) {
                              setState(() {
                                _selectedTankVolume = volume;
                              });
                            }
                          },
                        ),
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.amber.shade50,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.amber.shade200),
                  ),
                  child: Text(
                    _getDosageText(prescription),
                    style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w600, color: Colors.black87, height: 1.35),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // Organic & Bio-Control Alternative
          _buildInfoCard(
            title: "Organic & Bio-Control Alternative",
            icon: Icons.eco,
            color: Colors.green.shade800,
            content: _dbPrescription != null && _dbPrescription!.organicCure != 'None'
                ? "${_dbPrescription!.organicCure}\n\n${_dbPrescription!.organicInstructionsMl}"
                : prescription.organicTreatment,
          ),

          const SizedBox(height: 24),

          // Bottom Action: Scan Another Leaf
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green.shade900,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              icon: const Icon(Icons.camera_alt),
              label: const Text("Scan Another Leaf", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildInfoCard({
    required String title,
    required IconData icon,
    required Color color,
    required String content,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            content,
            style: const TextStyle(fontSize: 13.5, height: 1.4, color: Colors.black87),
          ),
        ],
      ),
    );
  }

  String _getDosageText(DiseasePrescription prescription) {
    if (_dbPrescription != null && _dbPrescription!.dosagePerLiter > 0) {
      final calc = DosageCalculator.calculateByTankVolume(
        tankVolumeLiters: _selectedTankVolume.toDouble(),
        dosagePerLiter: _dbPrescription!.dosagePerLiter,
        chemicalName: _dbPrescription!.chemicalCure,
      );
      return "${calc.dosageSummaryMl}\n(Concentration: ${_dbPrescription!.dosagePerLiter}g/L • Total required: ${calc.totalProductGramsOrMl.toStringAsFixed(1)} ${calc.unit})";
    }

    if (prescription.severity == SeverityLevel.healthy) {
      return "No chemical application required. Maintain normal field irrigation.";
    }

    final match = RegExp(r'(\d+(\.\d+)?)').firstMatch(prescription.knapsackTankDosage);
    if (match != null) {
      final base16Val = double.tryParse(match.group(1)!);
      if (base16Val != null) {
        final scaled = ((base16Val / 16.0) * _selectedTankVolume).toStringAsFixed(1);
        return "$scaled g in ${_selectedTankVolume}L knapsack sprayer tank. (Calculated dynamically for ${_selectedTankVolume}L capacity).";
      }
    }

    return "${prescription.knapsackTankDosage} (Adjusted for ${_selectedTankVolume}L tank)";
  }

  Widget _buildCropSwitchChip(String cropKey, String label) {
    final isSelected = _currentCrop.toLowerCase() == cropKey.toLowerCase();
    return GestureDetector(
      onTap: () => _switchCrop(cropKey),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          color: isSelected ? Colors.green.shade700 : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? Colors.green.shade700 : Colors.grey.shade300,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.black87,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
            fontSize: 12,
          ),
        ),
      ),
    );
  }
}
