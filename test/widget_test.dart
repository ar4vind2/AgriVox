import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:agrivox/main.dart';
import 'package:agrivox/models/disease_prescription.dart';
import 'package:agrivox/presentation/screens/dashboard_screen.dart';
import 'package:agrivox/presentation/widgets/animated_pulse_logo.dart';
import 'package:agrivox/services/tflite_service.dart';

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

  test('Foliage pre-filter strictly rejects non-leaf surfaces and accepts true crop leaves', () {
    // Non-plant surfaces MUST be rejected (ExG <= 0, low saturation, or red > green)
    expect(TFLiteService.isPlantFoliagePixel(140, 90, 50), isFalse, reason: 'Dark wood table');
    expect(TFLiteService.isPlantFoliagePixel(190, 150, 100), isFalse, reason: 'Light wood desk');
    expect(TFLiteService.isPlantFoliagePixel(180, 140, 90), isFalse, reason: 'Cardboard');
    expect(TFLiteService.isPlantFoliagePixel(240, 240, 235), isFalse, reason: 'White notebook paper');
    expect(TFLiteService.isPlantFoliagePixel(235, 225, 195), isFalse, reason: 'Cream book page');
    expect(TFLiteService.isPlantFoliagePixel(215, 165, 130), isFalse, reason: 'Human skin');
    expect(TFLiteService.isPlantFoliagePixel(30, 30, 35), isFalse, reason: 'Black keyboard');
    expect(TFLiteService.isPlantFoliagePixel(160, 165, 155), isFalse, reason: 'Cement wall');

    // Genuine plant foliage MUST be accepted
    expect(TFLiteService.isPlantFoliagePixel(45, 120, 40), isTrue, reason: 'Healthy pepper leaf');
    expect(TFLiteService.isPlantFoliagePixel(60, 140, 50), isTrue, reason: 'Healthy tomato leaf');
    expect(TFLiteService.isPlantFoliagePixel(130, 155, 50), isTrue, reason: 'Chlorotic yellowing leaf');
    expect(TFLiteService.isPlantFoliagePixel(110, 170, 70), isTrue, reason: 'Lime green leaf');
  });

  test('Non-leaf OOD fallback clamps confidence to 0.15', () {
    final ood = DiseasePrescription.fromLabel('unmapped_pathology', 0.15);
    expect(ood.diseaseId, 'unmapped_pathology');
    expect(ood.confidence, 0.15);
    expect(ood.confidence < 0.65, isTrue);
  });
}
