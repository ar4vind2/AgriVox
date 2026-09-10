import 'package:flutter/material.dart';
import '../../services/prescription_repository.dart';
import '../widgets/prescription_card.dart';

class MockPrescriptionTestScreen extends StatefulWidget {
  const MockPrescriptionTestScreen({super.key});

  @override
  State<MockPrescriptionTestScreen> createState() => _MockPrescriptionTestScreenState();
}

class _MockPrescriptionTestScreenState extends State<MockPrescriptionTestScreen> {
  final PrescriptionRepository _repo = PrescriptionRepository();
  Prescription? _activePrescription;

  final List<String> _sampleDiseases = [
    'Tomato_Late_blight',
    'Tomato_Early_blight',
    'Potato_Late_blight',
    'Pepper_bell_Bacterial_spot',
  ];

  void _loadPrescription(String key) async {
    final result = await _repo.getPrescription(key);
    setState(() {
      _activePrescription = result;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("AgriVox | Prescription & Voice Test")),
      body: Column(
        children: [
          const Padding(
            padding: EdgeInsets.all(12.0),
            child: Text("Select a detected disease class to simulate diagnosis:"),
          ),
          Wrap(
            spacing: 8,
            children: _sampleDiseases.map((key) {
              return ElevatedButton(
                onPressed: () => _loadPrescription(key),
                child: Text(key.replaceAll('_', ' ')),
              );
            }).toList(),
          ),
          const Spacer(),
          if (_activePrescription != null)
            PrescriptionCard(
              prescription: _activePrescription!,
              onDismiss: () => setState(() => _activePrescription = null),
            ),
        ],
      ),
    );
  }
}