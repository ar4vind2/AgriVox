import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:agrivox/main.dart';
import 'package:agrivox/models/disease_prescription.dart';
import 'package:agrivox/presentation/screens/dashboard_screen.dart';
import 'package:agrivox/presentation/widgets/animated_pulse_logo.dart';

void main() {
  testWidgets('AgriVoxApp smoke test - DashboardScreen direct', (WidgetTester tester) async {
    await tester.pumpWidget(const AgriVoxApp(home: DashboardScreen(cameras: [])));

    // Verify Dashboard title and action card are rendered
    expect(find.text('AgriVox'), findsOneWidget);
    expect(find.text('Scan Crop Leaf Lesion'), findsOneWidget);
    expect(find.text('Offline Mode'), findsOneWidget);
  });

  testWidgets('AnimatedPulseLogo widget smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: Center(
            child: AnimatedPulseLogo(size: 80),
          ),
        ),
      ),
    );

    expect(find.byType(AnimatedPulseLogo), findsOneWidget);
  });

  test('DiseasePrescription fallback and guardrail tests', () {
    // Test known disease
    final known = DiseasePrescription.fromLabel('Tomato_Late_blight', 0.88);
    expect(known.diseaseId, 'Tomato_Late_blight');
    expect(known.confidence, 0.88);

    // Test unmapped disease fallback (Task 4)
    final unmapped = DiseasePrescription.fromLabel('mystery_crop_disease_123', 0.42);
    expect(unmapped.diseaseId, 'unmapped_pathology');
    expect(unmapped.diseaseName, 'Unclassified Foliar Anomaly');
    expect(unmapped.confidence, 0.42);
    expect(unmapped.confidence < 0.60, isTrue);
  });
}
