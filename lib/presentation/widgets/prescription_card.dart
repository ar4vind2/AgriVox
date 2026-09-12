import 'package:flutter/material.dart';
import '../../services/prescription_repository.dart';
import '../../services/dosage_calculator.dart';
import '../../services/voice_service.dart';

class PrescriptionCard extends StatefulWidget {
  final Prescription prescription;
  final VoidCallback onDismiss;

  const PrescriptionCard({
    super.key,
    required this.prescription,
    required this.onDismiss,
  });

  @override
  State<PrescriptionCard> createState() => _PrescriptionCardState();
}

class _PrescriptionCardState extends State<PrescriptionCard> {
  final VoiceService _voiceService = VoiceService();
  double _tankVolume = 10.0; // Default 10 Liters
  bool _useOrganic = false;
  bool _isPlayingAudio = false;

  @override
  void initState() {
    super.initState();
    _voiceService.init();
    _voiceService.setCompletionHandler(() {
      if (mounted) setState(() => _isPlayingAudio = false);
    });
  }

  @override
  void dispose() {
    _voiceService.stop();
    super.dispose();
  }

  void _triggerVoice() async {
    setState(() => _isPlayingAudio = true);

    final calc = DosageCalculator.calculateByTankVolume(
      tankVolumeLiters: _tankVolume,
      dosagePerLiter: widget.prescription.dosagePerLiter,
      chemicalName: widget.prescription.chemicalCure,
    );

    final waitingClause = widget.prescription.waitingPeriodDays > 0
        ? " വിളവെടുപ്പിന് മുൻപ് ${widget.prescription.waitingPeriodDays} ദിവസം കാത്തിരിക്കുക."
        : " വിളവെടുപ്പ് ഇടവേള ബാധകമല്ല.";

    final instructions = _useOrganic
        ? (widget.prescription.organicInstructionsMl.isNotEmpty && widget.prescription.organicInstructionsMl.toLowerCase() != 'none'
            ? widget.prescription.organicInstructionsMl
            : "പ്രത്യേക ജൈവ കീടനാശിനി ആവശ്യമില്ല.")
        : (widget.prescription.chemicalCure.toLowerCase() == 'none'
            ? widget.prescription.chemicalInstructionsMl
            : "${calc.dosageSummaryMl}$waitingClause");

    await _voiceService.speakPrescription(
      diseaseMl: widget.prescription.diseaseNameMl,
      chemicalTreatmentMl: instructions,
      organicTreatmentMl: widget.prescription.organicInstructionsMl,
      preferOrganic: _useOrganic,
    );

    if (mounted) setState(() => _isPlayingAudio = false);
  }

  @override
  Widget build(BuildContext context) {
    final calc = DosageCalculator.calculateByTankVolume(
      tankVolumeLiters: _tankVolume,
      dosagePerLiter: widget.prescription.dosagePerLiter,
      chemicalName: widget.prescription.chemicalCure,
    );

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 10,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: Disease Name & Audio Button
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.prescription.diseaseNameMl,
                      style: const TextStyle(fontSize: 19, fontWeight: FontWeight.bold, color: Colors.green),
                    ),
                    Text(
                      widget.prescription.diseaseNameEn,
                      style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                    ),
                  ],
                ),
              ),
              IconButton.filled(
                onPressed: _isPlayingAudio ? _voiceService.stop : _triggerVoice,
                icon: Icon(_isPlayingAudio ? Icons.stop : Icons.volume_up),
                style: IconButton.styleFrom(backgroundColor: Colors.green[700]),
              ),
            ],
          ),
          const Divider(height: 20),

          // Treatment Toggle (Chemical vs Organic)
          Row(
            children: [
              ChoiceChip(
                label: const Text("രാസ നിയന്ത്രണം (Chemical)"),
                selected: !_useOrganic,
                onSelected: (val) => setState(() => _useOrganic = false),
              ),
              const SizedBox(width: 8),
              ChoiceChip(
                label: const Text("ജൈവ രീതി (Organic)"),
                selected: _useOrganic,
                onSelected: (val) => setState(() => _useOrganic = true),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Instructions Body
          if (!_useOrganic) ...[
            if (widget.prescription.chemicalCure.toLowerCase() == 'none') ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.green.shade200),
                ),
                child: Text(
                  widget.prescription.chemicalInstructionsMl.isNotEmpty
                      ? widget.prescription.chemicalInstructionsMl
                      : "ചെടി പൂർണ്ണ ആരോഗ്യത്തോടെയിരിക്കുന്നു. രാസവസ്തുക്കൾ ആവശ്യമില്ല.",
                  style: const TextStyle(fontWeight: FontWeight.w500, color: Colors.black87),
                ),
              ),
            ] else ...[
              Text("ശുപാർശ ചെയ്ത മരുന്ന്: ${widget.prescription.chemicalCure}",
                  style: const TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              // Sprayer Tank Dosage Slider
              Row(
                children: [
                  const Text("സ്പ്രേയർ ടാങ്ക്:"),
                  Expanded(
                    child: Slider(
                      value: _tankVolume,
                      min: 1,
                      max: 20,
                      divisions: 19,
                      label: "${_tankVolume.toInt()}L",
                      onChanged: (val) => setState(() => _tankVolume = val),
                    ),
                  ),
                  Text("${_tankVolume.toInt()} L"),
                ],
              ),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(calc.dosageSummaryMl, style: const TextStyle(color: Colors.black87)),
              ),
              const SizedBox(height: 6),
              if (widget.prescription.waitingPeriodDays > 0)
                Text(
                  "വിളവെടുപ്പ് ഇടവേള (Waiting Period): ${widget.prescription.waitingPeriodDays} ദിവസം",
                  style: const TextStyle(fontSize: 12, color: Colors.redAccent, fontWeight: FontWeight.bold),
                )
              else
                const Text(
                  "വിളവെടുപ്പ് ഇടവേള ബാധകമല്ല (No waiting period required)",
                  style: TextStyle(fontSize: 12, color: Colors.green, fontWeight: FontWeight.bold),
                ),
            ],
          ] else ...[
            if (widget.prescription.organicCure.toLowerCase() != 'none' &&
                widget.prescription.organicCure.trim().isNotEmpty) ...[
              Text("ജൈവ നിയന്ത്രണ രീതി: ${widget.prescription.organicCure}",
                  style: const TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  widget.prescription.organicInstructionsMl.isNotEmpty
                      ? widget.prescription.organicInstructionsMl
                      : "സാധാരണ ജൈവ പരിചരണ രീതികൾ (വേപ്പിൻപിണ്ണാക്ക്, പഞ്ചഗവ്യം) തുടരുക.",
                  style: const TextStyle(color: Colors.black87),
                ),
              ),
            ] else ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blueGrey.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blueGrey.shade200),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.eco, size: 20, color: Colors.green),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        "പ്രത്യേക ജൈവ കീടനാശിനി ആവശ്യമില്ല. സാധാരണ സസ്യസംരക്ഷണ രീതികൾ തുടരുക.",
                        style: TextStyle(fontSize: 13, color: Colors.black87),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ],
      ),
    );
  }
}