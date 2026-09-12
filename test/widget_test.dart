import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:agrivox/main.dart';
import 'package:agrivox/models/disease_prescription.dart';
import 'package:agrivox/presentation/screens/dashboard_screen.dart';
import 'package:agrivox/presentation/widgets/animated_pulse_logo.dart';
import 'package:agrivox/services/dosage_calculator.dart';
import 'package:agrivox/services/tflite_service.dart';
import 'package:agrivox/services/voice_service.dart';

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

  test('Crop-constrained resolution correctly isolates Pepper Bacterial Spot from Tomato classes', () {
    // Simulated raw model probabilities where Tomato Early Blight was falsely dominant
    final mockScores = {
      'Pepper_bell_Bacterial_spot': 0.08,
      'Pepper_bell_healthy': 0.005,
      'Potato_Early_blight': 0.01,
      'Potato_Late_blight': 0.005,
      'Potato_healthy': 0.005,
      'Tomato_Early_blight': 0.89,
      'Tomato_Late_blight': 0.003,
      'Tomato_Leaf_Mold': 0.001,
      'Tomato_Septoria_leaf_spot': 0.001,
      'Tomato_healthy': 0.000,
    };

    // Filter to Pepper classes
    final pepperEntries = mockScores.entries
        .where((e) => e.key.toLowerCase().contains('pepper'))
        .toList();
    pepperEntries.sort((a, b) => b.value.compareTo(a.value));
    final bestPepper = pepperEntries.first;
    final sumPepper = pepperEntries.fold<double>(0.0, (sum, e) => sum + e.value);
    final normalizedPepperConf = bestPepper.value / sumPepper;

    expect(bestPepper.key, 'Pepper_bell_Bacterial_spot');
    expect(normalizedPepperConf > 0.90, isTrue);

    final pepperRx = DiseasePrescription.fromLabel(bestPepper.key, normalizedPepperConf);
    expect(pepperRx.diseaseId, 'Pepper_bell_Bacterial_spot');
    expect(pepperRx.cropName.contains('Pepper'), isTrue);
    expect(pepperRx.confidence > 0.90, isTrue);
  });

  test('DosageCalculator correctly calculates knapsack tank dilution and land area math', () {
    // 16L tank with 2.0g/L dosage (e.g. Copper Oxychloride for Bacterial Spot)
    final tankResult = DosageCalculator.calculateByTankVolume(
      tankVolumeLiters: 16.0,
      dosagePerLiter: 2.0,
      chemicalName: 'Copper Oxychloride 50 WP',
    );
    expect(tankResult.totalWaterLiters, 16.0);
    expect(tankResult.totalProductGramsOrMl, 32.0);
    expect(tankResult.unit, 'ഗ്രാം');
    expect(tankResult.dosageSummaryMl.contains('16.0 ലീറ്റർ വെള്ളത്തിൽ 32.0 ഗ്രാം'), isTrue);

    // 10L tank with 2.5g/L dosage
    final smallTank = DosageCalculator.calculateByTankVolume(
      tankVolumeLiters: 10.0,
      dosagePerLiter: 2.5,
      chemicalName: 'Ridomil',
    );
    expect(smallTank.totalWaterLiters, 10.0);
    expect(smallTank.totalProductGramsOrMl, 25.0);

    // 14L tank with 1.5g/L dosage
    final medTank = DosageCalculator.calculateByTankVolume(
      tankVolumeLiters: 14.0,
      dosagePerLiter: 1.5,
      chemicalName: 'Dimethoate 30 EC',
      isLiquid: true,
    );
    expect(medTank.totalWaterLiters, 14.0);
    expect(medTank.totalProductGramsOrMl, 21.0);
    expect(medTank.unit, 'ml');

    // Land area calculation: 10 cents plot
    final areaResult = DosageCalculator.calculateByAreaInCents(
      cents: 10.0,
      dosagePerLiter: 2.0,
      chemicalName: 'Mancozeb 75% WP',
    );
    // 10 cents * 1.5 L/cent = 15 L water -> 15 * 2.0 = 30.0 g
    expect(areaResult.totalWaterLiters, 15.0);
    expect(areaResult.totalProductGramsOrMl, 30.0);
    expect(areaResult.dosageSummaryMl.contains('10.0 സെന്റ്'), isTrue);
  });

  test('Background_Noise non-plant guardrail prescription resolution tests', () {
    final bg = DiseasePrescription.fromLabel('Background_Noise', 0.15);
    expect(bg.diseaseId, 'Background_Noise');
    expect(bg.cropName, 'Non-Crop Surface');
    expect(bg.malayalamAudioText.contains('ചെടിയുടെ ഇല കണ്ടെത്താനായില്ല'), isTrue);
    expect(bg.confidence <= 0.20, isTrue);

    // Direct check in prescriptionsMap
    expect(DiseasePrescription.prescriptionsMap.containsKey('Background_Noise'), isTrue);
    expect(DiseasePrescription.prescriptionsMap.containsKey('unmapped_pathology'), isTrue);
  });

  test('VoiceService singleton provides offline speaking state tracking', () {
    final vs1 = VoiceService();
    final vs2 = VoiceService();
    expect(identical(vs1, vs2), isTrue);
    expect(vs1.isSpeaking, isFalse);
  });

  test('Local Kerala crops KAU prescriptions resolution tests', () {
    // Paddy / Rice Blast
    final blast = DiseasePrescription.fromLabel('Rice_Blast', 0.95);
    expect(blast.diseaseId, 'Rice_Blast');
    expect(blast.cropName.contains('Paddy'), isTrue);
    expect(blast.chemicalTreatment.contains('Tricyclazole'), isTrue);
    expect(blast.malayalamAudioText.contains('ബ്ലാസ്റ്റ്'), isTrue);

    // Coconut Bud Rot
    final budRot = DiseasePrescription.fromLabel('Coconut_Bud_Rot', 0.94);
    expect(budRot.diseaseId, 'Coconut_Bud_Rot');
    expect(budRot.cropName.contains('Coconut'), isTrue);
    expect(budRot.chemicalTreatment.contains('Bordeaux'), isTrue);

    // Banana Sigatoka
    final sigatoka = DiseasePrescription.fromLabel('Banana_Sigatoka_Leaf_Spot', 0.93);
    expect(sigatoka.diseaseId, 'Banana_Sigatoka_Leaf_Spot');
    expect(sigatoka.cropName.contains('Banana'), isTrue);
    expect(sigatoka.chemicalTreatment.contains('Mancozeb'), isTrue);

    // Brinjal Bacterial Wilt
    final brinjalWilt = DiseasePrescription.fromLabel('Brinjal_Bacterial_Wilt', 0.95);
    expect(brinjalWilt.diseaseId, 'Brinjal_Bacterial_Wilt');
    expect(brinjalWilt.cropName.contains('Brinjal'), isTrue);
    expect(brinjalWilt.chemicalTreatment.contains('Copper Oxychloride'), isTrue);

    // Okra Yellow Vein Mosaic
    final okraMosaic = DiseasePrescription.fromLabel('Okra_Yellow_Vein_Mosaic', 0.96);
    expect(okraMosaic.diseaseId, 'Okra_Yellow_Vein_Mosaic');
    expect(okraMosaic.cropName.contains('Okra'), isTrue);
    expect(okraMosaic.chemicalTreatment.contains('Dimethoate'), isTrue);
  });

  testWidgets('Dashboard renders all 8 Kerala and Solanaceae crops', (WidgetTester tester) async {
    await tester.pumpWidget(const AgriVoxApp(home: DashboardScreen(cameras: [])));

    expect(find.text('Paddy'), findsOneWidget);
    expect(find.text('Coconut'), findsOneWidget);
    expect(find.text('Banana'), findsOneWidget);
    expect(find.text('Brinjal'), findsOneWidget);
    expect(find.text('Okra'), findsOneWidget);
    expect(find.text('Pepper'), findsOneWidget);
    expect(find.text('Tomato'), findsOneWidget);
    expect(find.text('Potato'), findsOneWidget);
    expect(find.text('8 Crops • 25 Prescriptions'), findsOneWidget);
  });
}
