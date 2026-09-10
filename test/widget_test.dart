import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:agrivox/main.dart';
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
}
