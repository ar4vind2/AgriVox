import 'dart:async';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../repositories/prescription_repository.dart';
import '../../services/tflite_service.dart';
import '../../services/voice_service.dart';
import '../widgets/animated_pulse_logo.dart';
import 'dashboard_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _entranceController;
  late final Animation<double> _fadeAnimation;
  late final Animation<double> _slideAnimation;

  String _statusText = "Initializing Edge-AI Engine...";
  double _progressValue = 0.15;
  List<CameraDescription> _cameras = [];

  @override
  void initState() {
    super.initState();

    _entranceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..forward();

    _fadeAnimation = CurvedAnimation(
      parent: _entranceController,
      curve: Curves.easeOut,
    );

    _slideAnimation = Tween<double>(begin: 24.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _entranceController,
        curve: Curves.easeOutCubic,
      ),
    );

    _runStartupSequence();
  }

  Future<void> _runStartupSequence() async {
    final startTime = DateTime.now();

    // Step 1: Camera permissions and available cameras
    await Future.delayed(const Duration(milliseconds: 400));
    if (mounted) {
      setState(() {
        _statusText = "Configuring Optical Sensor Pipeline...";
        _progressValue = 0.35;
      });
    }

    try {
      await Permission.camera.request();
      _cameras = await availableCameras();
    } catch (e) {
      debugPrint("Camera initialization warning: $e");
    }

    // Step 2: TFLite Service and quantized model load
    await Future.delayed(const Duration(milliseconds: 500));
    if (mounted) {
      setState(() {
        _statusText = "Loading YOLOv8n-cls INT8 Weights...";
        _progressValue = 0.65;
      });
    }

    try {
      await TFLiteService().initialize();
    } catch (e) {
      debugPrint("TFLite initialization warning: $e");
    }

    // Step 3: SQLite Agronomy DB & TTS Voice Engine
    await Future.delayed(const Duration(milliseconds: 500));
    if (mounted) {
      setState(() {
        _statusText = "Linking KAU Agronomy & Indic TTS Engine...";
        _progressValue = 0.88;
      });
    }

    try {
      await PrescriptionRepository().database;
      await VoiceService().init();
    } catch (e) {
      debugPrint("Agronomy / Voice initialization warning: $e");
    }

    // Step 4: Final Ready State
    await Future.delayed(const Duration(milliseconds: 400));
    if (mounted) {
      setState(() {
        _statusText = "100% Offline Edge Diagnostics Ready";
        _progressValue = 1.0;
      });
    }

    // Ensure minimum visual duration for cinematic polish (~2.6 seconds)
    final elapsed = DateTime.now().difference(startTime).inMilliseconds;
    const minDisplayDuration = 2600;
    if (elapsed < minDisplayDuration) {
      await Future.delayed(Duration(milliseconds: minDisplayDuration - elapsed));
    }

    if (!mounted) return;

    // Smooth fade transition to DashboardScreen
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 700),
        pageBuilder: (_, animation, secondaryAnimation) =>
            DashboardScreen(cameras: _cameras),
        transitionsBuilder: (_, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
    );
  }

  @override
  void dispose() {
    _entranceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: const Color(0xFF071A10), // Deep Forest Obsidian
      body: Stack(
        children: [
          // Subtle ambient corner gradients
          Positioned(
            top: -size.width * 0.3,
            right: -size.width * 0.3,
            child: Container(
              width: size.width * 0.9,
              height: size.width * 0.9,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    const Color(0xFF15803D).withValues(alpha: 0.25),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),

          Positioned(
            bottom: -size.width * 0.3,
            left: -size.width * 0.3,
            child: Container(
              width: size.width * 0.9,
              height: size.width * 0.9,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    const Color(0xFF047857).withValues(alpha: 0.2),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),

          // Central Animated Stage
          SafeArea(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Spacer(flex: 3),

                    // Multi-ring Animated Edge-AI Brand Logo
                    FadeTransition(
                      opacity: _fadeAnimation,
                      child: const AnimatedPulseLogo(
                        size: 116,
                        showRings: true,
                        showReticle: true,
                      ),
                    ),

                    const SizedBox(height: 32),

                    // Staggered Title Entrance
                    AnimatedBuilder(
                      animation: _entranceController,
                      builder: (context, child) {
                        return Transform.translate(
                          offset: Offset(0, _slideAnimation.value),
                          child: Opacity(
                            opacity: _fadeAnimation.value,
                            child: child,
                          ),
                        );
                      },
                      child: Column(
                        children: [
                          const Text(
                            "AgriVox",
                            style: TextStyle(
                              fontSize: 38,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 1.2,
                              color: Colors.white,
                              height: 1.1,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFF22C55E)
                                  .withValues(alpha: 0.14),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: const Color(0xFF22C55E)
                                    .withValues(alpha: 0.35),
                              ),
                            ),
                            child: const Text(
                              "OFFLINE EDGE-AI • KAU AGRO-COPILOT",
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1.0,
                                color: Color(0xFF4ADE80),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const Spacer(flex: 3),

                    // Initialization Progress & Status Tracker
                    FadeTransition(
                      opacity: _fadeAnimation,
                      child: Column(
                        children: [
                          // Sleek glowing progress indicator
                          Container(
                            height: 4,
                            width: 220,
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(2),
                            ),
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 400),
                                curve: Curves.easeOutCubic,
                                width: 220 * _progressValue,
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    colors: [
                                      Color(0xFF10B981),
                                      Color(0xFF4ADE80),
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(2),
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color(0xFF4ADE80)
                                          .withValues(alpha: 0.6),
                                      blurRadius: 6,
                                      spreadRadius: 1,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 14),

                          AnimatedSwitcher(
                            duration: const Duration(milliseconds: 300),
                            child: Text(
                              _statusText,
                              key: ValueKey<String>(_statusText),
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 12.5,
                                fontWeight: FontWeight.w500,
                                color: Colors.white.withValues(alpha: 0.7),
                                letterSpacing: 0.3,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Attribution Footer
                    FadeTransition(
                      opacity: _fadeAnimation,
                      child: Text(
                        "AI Conclave 2026 • Amal Jyothi College of Engineering",
                        style: TextStyle(
                          fontSize: 10.5,
                          color: Colors.white.withValues(alpha: 0.35),
                          letterSpacing: 0.4,
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
