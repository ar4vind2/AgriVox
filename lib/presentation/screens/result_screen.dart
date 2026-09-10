import 'dart:io';
import 'package:flutter/material.dart';
import '../../models/disease_prescription.dart';
import '../../services/prescription_repository.dart';
import '../../services/voice_service.dart';

class ResultScreen extends StatefulWidget {
  final File croppedImage;
  final DiseasePrescription prescription;

  const ResultScreen({
    super.key,
    required this.croppedImage,
    required this.prescription,
  });

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen> {
  final VoiceService _voiceService = VoiceService();
  final PrescriptionRepository _repository = PrescriptionRepository();

  Prescription? _dbPrescription;
  bool _isPlayingMalayalam = false;
  bool _isPlayingEnglish = false;

  @override
  void initState() {
    super.initState();
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

    try {
      final dbResult = await _repository.getPrescription(widget.prescription.diseaseId);
      if (mounted) {
        setState(() {
          _dbPrescription = dbResult;
        });
      }
    } catch (e) {
      debugPrint("SQLite DB lookup error: $e");
    }
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
      await _voiceService.speakMalayalam(widget.prescription.malayalamAudioText);
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

    await _voiceService.speakEnglish(widget.prescription.englishAudioText);
  }

  @override
  Widget build(BuildContext context) {
    final prescription = widget.prescription;
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
        title: const Text("Diagnostic Report", style: TextStyle(fontWeight: FontWeight.bold)),
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

          const SizedBox(height: 16),

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

          // Spray Tank Dosage Calculator
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
                          "Knapsack Tank Preparation (16L)",
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
                const SizedBox(height: 8),
                Text(
                  _dbPrescription != null && _dbPrescription!.dosagePerLiter > 0
                      ? "${(_dbPrescription!.dosagePerLiter * 16).toStringAsFixed(1)}g / ml of ${_dbPrescription!.chemicalCure} in 16L knapsack tank. (Concentration: ${_dbPrescription!.dosagePerLiter}g per liter)."
                      : prescription.knapsackTankDosage,
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.black87),
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
}
