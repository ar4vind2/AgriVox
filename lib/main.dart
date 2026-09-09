import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:permission_handler/permission_handler.dart';
import 'presentation/screens/dashboard_screen.dart';
import 'services/tflite_service.dart';

List<CameraDescription> cameras = [];

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Permission.camera.request();
  try {
    cameras = await availableCameras();
  } catch (e) {
    debugPrint("Failed to get available cameras: $e");
  }

  // Initialize TFLite interpreter / labels if assets are present
  await TFLiteService().initialize();

  runApp(const AgriVoxApp());
}

class AgriVoxApp extends StatelessWidget {
  const AgriVoxApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AgriVox',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF1B5E20), // Deep Forest Green
          primary: const Color(0xFF2E7D32),
        ),
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFF6F8F5),
      ),
      home: DashboardScreen(cameras: cameras),
    );
  }
}

