import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:camera/camera.dart';
import '../../services/tflite_service.dart';
import '../widgets/animated_pulse_logo.dart';
import '../widgets/reticle_overlay.dart';
import 'result_screen.dart';

class ScannerScreen extends StatefulWidget {
  final List<CameraDescription> cameras;
  final String initialCrop;

  const ScannerScreen({
    super.key,
    required this.cameras,
    this.initialCrop = 'All',
  });

  @override
  State<ScannerScreen> createState() => _ScannerScreenState();
}

class _ScannerScreenState extends State<ScannerScreen> {
  CameraController? _controller;
  bool _isReady = false;
  bool _isAnalyzing = false;
  bool _showShutterBlink = false;
  FlashMode _flashMode = FlashMode.off;
  int _selectedCameraIndex = 0;
  String? _errorMessage;
  late String _selectedCrop;

  @override
  void initState() {
    super.initState();
    _selectedCrop = widget.initialCrop;
    _initCamera();
  }

  Future<void> _initCamera() async {
    if (widget.cameras.isEmpty) {
      setState(() {
        _errorMessage = "No camera hardware detected.";
      });
      return;
    }

    final controller = CameraController(
      widget.cameras[_selectedCameraIndex],
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
      if (!mounted) return;
      setState(() {
        _errorMessage = "Camera error: $e";
      });
    }
  }

  Future<void> _toggleFlash() async {
    if (_controller == null || !_controller!.value.isInitialized) return;
    final nextMode = _flashMode == FlashMode.off ? FlashMode.torch : FlashMode.off;
    try {
      await _controller!.setFlashMode(nextMode);
      setState(() {
        _flashMode = nextMode;
      });
    } catch (e) {
      debugPrint("Flash toggle failed: $e");
    }
  }

  Future<void> _switchCamera() async {
    if (widget.cameras.length < 2) return;
    setState(() {
      _isReady = false;
      _selectedCameraIndex = (_selectedCameraIndex + 1) % widget.cameras.length;
    });
    await _controller?.dispose();
    await _initCamera();
  }

  Future<void> _captureAndAnalyze() async {
    if (_controller == null || !_controller!.value.isInitialized || _isAnalyzing) return;

    // Haptic feedback for tactile shutter confirmation
    HapticFeedback.mediumImpact();

    // Trigger brief visual shutter blink
    setState(() {
      _showShutterBlink = true;
      _isAnalyzing = true;
    });

    // Reset shutter flash after 120ms
    Future.delayed(const Duration(milliseconds: 120), () {
      if (mounted) {
        setState(() {
          _showShutterBlink = false;
        });
      }
    });

    try {
      final xFile = await _controller!.takePicture();
      final result = await TFLiteService().processAndClassify(
        xFile.path,
        targetCrop: _selectedCrop == 'All' ? null : _selectedCrop,
      );

      if (!mounted) return;

      // Turn off flash if it was on
      if (_flashMode == FlashMode.torch) {
        await _controller?.setFlashMode(FlashMode.off);
        _flashMode = FlashMode.off;
      }

      setState(() {
        _isAnalyzing = false;
      });

      if (!mounted) return;

      // Guardrail: Reject non-crop items (books, tables, walls) or ambiguous scans
      if (!result.isValidPlant || result.prescription.confidence < 0.65) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: const Color(0xFFB45309),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            margin: const EdgeInsets.all(16),
            content: const Row(
              children: [
                Icon(Icons.info_outline, color: Colors.white, size: 22),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    "ഇല വ്യക്തമല്ല (No plant leaf detected).\nPlease center the affected crop leaf within the reticle.",
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                  ),
                ),
              ],
            ),
            duration: const Duration(seconds: 4),
          ),
        );
        return;
      }

      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ResultScreen(
            croppedImage: result.croppedImageFile,
            prescription: result.prescription,
            classProbabilities: result.classProbabilities,
            initialCrop: _selectedCrop,
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isAnalyzing = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Analysis failed: $e"), backgroundColor: Colors.red),
      );
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
        appBar: AppBar(backgroundColor: Colors.black, foregroundColor: Colors.white),
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
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Live Camera Stream
          CameraPreview(_controller!),

          // Aiming Reticle Overlay
          const ReticleOverlay(size: 260),

          // Top Action Controls
          Positioned(
            top: MediaQuery.of(context).padding.top + 10,
            left: 16,
            right: 16,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildCircleButton(
                  icon: Icons.arrow_back,
                  onPressed: () => Navigator.pop(context),
                ),
                Row(
                  children: [
                    _buildCircleButton(
                      icon: _flashMode == FlashMode.torch ? Icons.flash_on : Icons.flash_off,
                      color: _flashMode == FlashMode.torch ? Colors.amber : Colors.white,
                      onPressed: _toggleFlash,
                    ),
                    if (widget.cameras.length > 1) ...[
                      const SizedBox(width: 12),
                      _buildCircleButton(
                        icon: Icons.flip_camera_ios,
                        onPressed: _switchCamera,
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),

          // Crop Target Filter Bar
          if (!_isAnalyzing)
            Positioned(
              bottom: 130,
              left: 16,
              right: 16,
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.65),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: Colors.white24, width: 1),
                  ),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _buildCropChip('All', '🌿 Auto'),
                        const SizedBox(width: 4),
                        _buildCropChip('Paddy', '🌾 Paddy (നെല്ല്)'),
                        const SizedBox(width: 4),
                        _buildCropChip('Coconut', '🥥 Coconut (തെങ്ങ്)'),
                        const SizedBox(width: 4),
                        _buildCropChip('Banana', '🍌 Banana (വാഴ)'),
                        const SizedBox(width: 4),
                        _buildCropChip('Brinjal', '🍆 Brinjal (വഴുതന)'),
                        const SizedBox(width: 4),
                        _buildCropChip('Okra', '🥬 Okra (വെണ്ട)'),
                        const SizedBox(width: 4),
                        _buildCropChip('Pepper', '🌶️ Pepper'),
                        const SizedBox(width: 4),
                        _buildCropChip('Tomato', '🍅 Tomato'),
                        const SizedBox(width: 4),
                        _buildCropChip('Potato', '🥔 Potato'),
                      ],
                    ),
                  ),
                ),
              ),
            ),

          // Shutter / Capture Button
          Positioned(
            bottom: 40,
            left: 0,
            right: 0,
            child: Center(
              child: _isAnalyzing
                  ? const SizedBox.shrink()
                  : GestureDetector(
                      onTap: _captureAndAnalyze,
                      child: Container(
                        width: 78,
                        height: 78,
                        padding: const EdgeInsets.all(5),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 4),
                        ),
                        child: Container(
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.greenAccent,
                          ),
                          child: const Icon(Icons.camera_alt, color: Colors.black87, size: 32),
                        ),
                      ),
                    ),
            ),
          ),

          // High-Tech Analyzing HUD Overlay
          if (_isAnalyzing)
            Positioned.fill(
              child: Container(
                color: Colors.black.withValues(alpha: 0.78),
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 28),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const AnimatedPulseLogo(
                          size: 76,
                          showRings: true,
                          showReticle: true,
                        ),
                        const SizedBox(height: 20),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
                          decoration: BoxDecoration(
                            color: const Color(0xFF22C55E).withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: const Color(0xFF22C55E).withValues(alpha: 0.4),
                            ),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              SizedBox(
                                width: 8,
                                height: 8,
                                child: DecoratedBox(
                                  decoration: BoxDecoration(
                                    color: Color(0xFF4ADE80),
                                    shape: BoxShape.circle,
                                  ),
                                ),
                              ),
                              SizedBox(width: 8),
                              Text(
                                "NEURAL EDGE-DIAGNOSTIC",
                                style: TextStyle(
                                  color: Color(0xFF4ADE80),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 11,
                                  letterSpacing: 1.1,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 14),
                        const Text(
                          "Analyzing Lesion On-Device...",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 19,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.4,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          "Running YOLOv8n-cls INT8 Inference\nExtracting KAU agronomy recommendations",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.68),
                            fontSize: 12.5,
                            height: 1.45,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

          // Shutter Blink Flash Overlay
          if (_showShutterBlink)
            Positioned.fill(
              child: IgnorePointer(
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 120),
                  color: Colors.white.withValues(alpha: 0.85),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildCircleButton({
    required IconData icon,
    required VoidCallback onPressed,
    Color color = Colors.white,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.6),
        shape: BoxShape.circle,
      ),
      child: IconButton(
        icon: Icon(icon, color: color, size: 22),
        onPressed: onPressed,
      ),
    );
  }

  Widget _buildCropChip(String cropKey, String label) {
    final isSelected = _selectedCrop.toLowerCase() == cropKey.toLowerCase();
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedCrop = cropKey;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? Colors.greenAccent.shade700 : Colors.transparent,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.white70,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            fontSize: 12,
          ),
        ),
      ),
    );
  }
}
