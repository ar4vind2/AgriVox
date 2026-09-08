import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:permission_handler/permission_handler.dart';

List<CameraDescription> cameras = [];

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Permission.camera.request();
  try {
    cameras = await availableCameras();
  } catch (e) {
    debugPrint("Failed to get available cameras: $e");
  }
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
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
        useMaterial3: true,
      ),
      home: const ScannerPreviewScreen(),
    );
  }
}

class ScannerPreviewScreen extends StatefulWidget {
  const ScannerPreviewScreen({super.key});

  @override
  State<ScannerPreviewScreen> createState() => _ScannerPreviewScreenState();
}

class _ScannerPreviewScreenState extends State<ScannerPreviewScreen> {
  CameraController? _controller;
  bool _isReady = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    if (cameras.isEmpty) {
      setState(() {
        _errorMessage = "No camera found on this device.\nPlease connect an Android device or camera.";
      });
      return;
    }

    final controller = CameraController(
      cameras[0],
      ResolutionPreset.medium,
      enableAudio: false,
    );

    _controller = controller;

    try {
      await controller.initialize();
      if (!mounted) return;
      setState(() {
        _isReady = true;
      });
    } catch (e) {
      debugPrint("Camera initialization failed: $e");
      if (!mounted) return;
      setState(() {
        _errorMessage = "Failed to initialize camera: $e";
      });
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_errorMessage != null) {
      return Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          title: const Text("AgriVox | Leaf Scanner"),
          backgroundColor: Colors.green.shade900,
          foregroundColor: Colors.white,
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Text(
              _errorMessage!,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white70, fontSize: 16),
            ),
          ),
        ),
      );
    }

    if (!_isReady || _controller == null) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: CircularProgressIndicator(color: Colors.greenAccent),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text("AgriVox | Leaf Scanner"),
        backgroundColor: Colors.green.shade900,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox.expand(
            child: CameraPreview(_controller!),
          ),
          // Aiming Reticle for Leaf Target Area (Center-crop 250x250)
          Container(
            width: 250,
            height: 250,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.greenAccent, width: 3),
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          // Helper Guide Badge
          Positioned(
            bottom: 50,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.7),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Text(
                "Center diseased leaf within the box",
                style: TextStyle(color: Colors.white, fontSize: 14),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
