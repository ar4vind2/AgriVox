import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../services/prescription_repository.dart';
import '../../services/tflite_service.dart';
import '../../services/voice_service.dart';
import 'dashboard_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  // Master timeline controller for staggered entrance
  late final AnimationController _entranceController;

  // Continuous ambient loop for particles, sheen, and voice bars
  late final AnimationController _ambientController;

  // Staggered element-by-element animations
  late final Animation<double> _laserScanAnimation;
  late final Animation<double> _bracketsAnimation;
  late final Animation<double> _logoScaleAnimation;
  late final Animation<double> _logoSheenAnimation;
  late final List<Animation<double>> _letterAnimations;
  late final Animation<double> _badgeExpandAnimation;
  late final Animation<double> _badgeFadeAnimation;
  late final Animation<double> _voiceVisualizerAnimation;
  late final Animation<double> _telemetryFadeAnimation;
  late final Animation<double> _footerFadeAnimation;

  // Telemetry & Initialization state
  int _currentMilestone = 0; // 0: Cameras, 1: TFLite, 2: DB & TTS, 3: Ready
  String _statusText = "Initializing Edge-AI Subsystems...";
  double _progressValue = 0.15;
  List<CameraDescription> _cameras = [];

  // Pre-calculated bio-luminescent ambient particles
  late final List<_BioParticle> _particles;

  final String _brandWord = "AgriVox";

  @override
  void initState() {
    super.initState();

    // 1. Initialize random floating particles for organic atmosphere
    final random = math.Random(42);
    _particles = List.generate(28, (index) {
      return _BioParticle(
        x: random.nextDouble(),
        y: random.nextDouble(),
        radius: 1.2 + random.nextDouble() * 2.2,
        speed: 0.15 + random.nextDouble() * 0.25,
        baseAlpha: 0.2 + random.nextDouble() * 0.55,
      );
    });

    // 2. Entrance Choreography Timeline (2200ms)
    _entranceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    );

    // 3. Continuous Ambient Loop (3600ms)
    _ambientController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3600),
    )..repeat();

    // Element 1: Initial Sweeping Lidar/Laser Beam (0.0 -> 0.32)
    _laserScanAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _entranceController,
        curve: const Interval(0.0, 0.32, curve: Curves.easeInOutQuad),
      ),
    );

    // Element 2: HUD Corner Brackets Lock-in (0.08 -> 0.42)
    _bracketsAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _entranceController,
        curve: const Interval(0.08, 0.42, curve: Curves.easeOutBack),
      ),
    );

    // Element 3: Logo Spring Pop (0.16 -> 0.50)
    _logoScaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _entranceController,
        curve: const Interval(0.16, 0.50, curve: Curves.elasticOut),
      ),
    );

    // Element 4: Glossy Metallic Sheen Sweep on Logo (0.42 -> 0.68)
    _logoSheenAnimation = Tween<double>(begin: -1.2, end: 1.8).animate(
      CurvedAnimation(
        parent: _entranceController,
        curve: const Interval(0.42, 0.68, curve: Curves.easeInOutCubic),
      ),
    );

    // Element 5: Staggered Letter Reveal for 'AgriVox' (0.32 -> 0.65)
    _letterAnimations = List.generate(_brandWord.length, (i) {
      final start = 0.32 + (i * 0.04);
      final end = (start + 0.22).clamp(0.0, 0.95);
      return Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(
          parent: _entranceController,
          curve: Interval(start, end, curve: Curves.easeOutBack),
        ),
      );
    });

    // Element 6: Laser Unfolding Cyber Badge (0.54 -> 0.78)
    _badgeExpandAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _entranceController,
        curve: const Interval(0.54, 0.78, curve: Curves.easeOutCubic),
      ),
    );
    _badgeFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _entranceController,
        curve: const Interval(0.58, 0.78, curve: Curves.easeIn),
      ),
    );

    // Element 7: Voice Frequency Equalizer Visualizer (0.64 -> 0.86)
    _voiceVisualizerAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _entranceController,
        curve: const Interval(0.64, 0.86, curve: Curves.easeOut),
      ),
    );

    // Element 8: High-Tech Telemetry HUD (0.68 -> 0.92)
    _telemetryFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _entranceController,
        curve: const Interval(0.68, 0.92, curve: Curves.easeOut),
      ),
    );

    // Element 9: Footer Attribution (0.76 -> 1.0)
    _footerFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _entranceController,
        curve: const Interval(0.76, 1.0, curve: Curves.easeOut),
      ),
    );

    _entranceController.forward();
    _runStartupSequence();
  }

  Future<void> _runStartupSequence() async {
    final startTime = DateTime.now();

    // Stage 1: Optical Sensors / Camera pipeline
    await Future.delayed(const Duration(milliseconds: 500));
    if (mounted) {
      setState(() {
        _currentMilestone = 1;
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

    // Stage 2: YOLOv8n-cls INT8 Weights & Quantization
    await Future.delayed(const Duration(milliseconds: 550));
    if (mounted) {
      setState(() {
        _currentMilestone = 2;
        _statusText = "Loading YOLOv8n-cls INT8 Weights...";
        _progressValue = 0.65;
      });
    }

    try {
      await TFLiteService().initialize();
    } catch (e) {
      debugPrint("TFLite initialization warning: $e");
    }

    // Stage 3: KAU Agronomy DB & Indic TTS Voice Engine
    await Future.delayed(const Duration(milliseconds: 550));
    if (mounted) {
      setState(() {
        _currentMilestone = 3;
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

    // Stage 4: 100% Ready State
    await Future.delayed(const Duration(milliseconds: 450));
    if (mounted) {
      setState(() {
        _currentMilestone = 4;
        _statusText = "100% Offline Edge Diagnostics Ready";
        _progressValue = 1.0;
      });
    }

    // Ensure visual duration for smooth cinematic flow (~3.0 seconds)
    final elapsed = DateTime.now().difference(startTime).inMilliseconds;
    const minDisplayDuration = 3000;
    if (elapsed < minDisplayDuration) {
      await Future.delayed(Duration(milliseconds: minDisplayDuration - elapsed));
    }

    if (!mounted) return;

    // Smooth cinematic fade transition to DashboardScreen
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
    _ambientController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: const Color(0xFF071A10), // Deep Forest Obsidian
      body: Stack(
        fit: StackFit.expand,
        children: [
          // 1. Ambient Background Bio-Luminescent Particles
          AnimatedBuilder(
            animation: _ambientController,
            builder: (context, _) {
              return CustomPaint(
                size: size,
                painter: _BioParticlesPainter(
                  animationValue: _ambientController.value,
                  particles: _particles,
                ),
              );
            },
          ),

          // 2. Initial Downward Laser / Lidar Scan Beam
          AnimatedBuilder(
            animation: _laserScanAnimation,
            builder: (context, _) {
              return CustomPaint(
                size: size,
                painter: _LaserScanPainter(
                  progress: _laserScanAnimation.value,
                ),
              );
            },
          ),

          // 3. Subtle Ambient Emerald Corner Radiations
          Positioned(
            top: -size.width * 0.35,
            right: -size.width * 0.35,
            child: Container(
              width: size.width * 0.9,
              height: size.width * 0.9,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    const Color(0xFF15803D).withValues(alpha: 0.28),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            bottom: -size.width * 0.35,
            left: -size.width * 0.35,
            child: Container(
              width: size.width * 0.9,
              height: size.width * 0.9,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    const Color(0xFF047857).withValues(alpha: 0.22),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),

          // 4. Central Choreographed Stage
          SafeArea(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 28),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Spacer(flex: 3),

                    // ELEMENT A: App Logo Assembly with Snapping HUD Brackets & Metallic Sheen
                    _buildAnimatedLogoStage(),

                    const SizedBox(height: 28),

                    // ELEMENT B: Staggered Letter-by-Letter "AgriVox" Reveal
                    _buildStaggeredBrandTitle(),

                    const SizedBox(height: 12),

                    // ELEMENT C: Laser Unfolding Cyber Pill Badge
                    _buildLaserUnfoldingBadge(),

                    const SizedBox(height: 20),

                    // ELEMENT D: "Vox" Soundwave / Audio Equalizer Visualizer
                    _buildVoiceWaveformVisualizer(),

                    const Spacer(flex: 2),

                    // ELEMENT E: High-Tech 4-Segment Subsystem Telemetry HUD
                    _buildSegmentedTelemetryHud(),

                    const SizedBox(height: 22),

                    // ELEMENT F: Footer Attribution
                    _buildAnimatedFooter(),

                    const SizedBox(height: 14),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // ELEMENT A: Logo Stage (HUD Brackets + Pop + Sheen + Ambient Pulse)
  // ---------------------------------------------------------------------------
  Widget _buildAnimatedLogoStage() {
    const double logoBoxSize = 106.0;
    const double stageDimension = 170.0;

    return SizedBox(
      width: stageDimension,
      height: stageDimension,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Outer Snapping HUD Corner Targeting Brackets
          AnimatedBuilder(
            animation: Listenable.merge([_bracketsAnimation, _ambientController]),
            builder: (context, _) {
              return CustomPaint(
                size: const Size(stageDimension, stageDimension),
                painter: _HudCornerBracketsPainter(
                  progress: _bracketsAnimation.value,
                  pulse: math.sin(_ambientController.value * 2 * math.pi) * 0.5 + 0.5,
                ),
              );
            },
          ),

          // Concentric Radar Energy Pulse Shockwave
          AnimatedBuilder(
            animation: _ambientController,
            builder: (context, _) {
              final double waveRadius = (logoBoxSize * 0.6) +
                  (_ambientController.value * (stageDimension * 0.45 - logoBoxSize * 0.6));
              final double waveOpacity = (1.0 - _ambientController.value) * 0.45;

              return Container(
                width: waveRadius * 2,
                height: waveRadius * 2,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: const Color(0xFF4ADE80).withValues(alpha: waveOpacity),
                    width: 1.5,
                  ),
                ),
              );
            },
          ),

          // Central Breathing Emblem with Metallic Light Sheen
          AnimatedBuilder(
            animation: Listenable.merge([_logoScaleAnimation, _ambientController]),
            builder: (context, child) {
              final breath = 1.0 + (math.sin(_ambientController.value * 2 * math.pi) * 0.03);
              final scale = _logoScaleAnimation.value * breath;

              return Transform.scale(
                scale: scale,
                child: child,
              );
            },
            child: Container(
              width: logoBoxSize,
              height: logoBoxSize,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF10B981).withValues(alpha: 0.4),
                    blurRadius: 28,
                    spreadRadius: 2,
                  ),
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.5),
                    blurRadius: 16,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    // Official App Icon Vector SVG
                    SvgPicture.asset(
                      'assets/icon/app_icon.svg',
                      fit: BoxFit.contain,
                    ),

                    // Diagonal Metallic Light Sheen Sweep
                    AnimatedBuilder(
                      animation: _logoSheenAnimation,
                      builder: (context, _) {
                        final offsetProgress = _logoSheenAnimation.value;
                        if (offsetProgress < -1.0 || offsetProgress > 1.5) {
                          return const SizedBox.shrink();
                        }
                        return Positioned.fill(
                          child: FractionalTranslation(
                            translation: Offset(offsetProgress, 0),
                            child: Transform.rotate(
                              angle: 0.5,
                              child: Container(
                                width: 34,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      Colors.transparent,
                                      Colors.white.withValues(alpha: 0.15),
                                      Colors.white.withValues(alpha: 0.65),
                                      Colors.white.withValues(alpha: 0.15),
                                      Colors.transparent,
                                    ],
                                    stops: const [0.0, 0.35, 0.5, 0.65, 1.0],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),

                    // Subtle Glass Border
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.3),
                          width: 1.5,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // ELEMENT B: Staggered Letter-by-Letter "AgriVox" Title
  // ---------------------------------------------------------------------------
  Widget _buildStaggeredBrandTitle() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: List.generate(_brandWord.length, (index) {
        final letter = _brandWord[index];
        final animation = _letterAnimations[index];
        final isVox = index >= 4; // "V", "o", "x"

        return AnimatedBuilder(
          animation: animation,
          builder: (context, child) {
            final double value = animation.value;
            final double offsetY = (1.0 - value) * 26.0;
            final double scale = 0.3 + (0.7 * value);
            final double opacity = value.clamp(0.0, 1.0);

            return Transform.translate(
              offset: Offset(0, offsetY),
              child: Transform.scale(
                scale: scale,
                child: Opacity(
                  opacity: opacity,
                  child: child,
                ),
              ),
            );
          },
          child: Text(
            letter,
            style: TextStyle(
              fontSize: 38,
              fontWeight: FontWeight.w900,
              letterSpacing: 1.5,
              color: isVox ? const Color(0xFF4ADE80) : Colors.white,
              shadows: isVox
                  ? [
                      Shadow(
                        color: const Color(0xFF4ADE80).withValues(alpha: 0.7),
                        blurRadius: 14,
                      ),
                    ]
                  : [
                      Shadow(
                        color: Colors.white.withValues(alpha: 0.3),
                        blurRadius: 8,
                      ),
                    ],
            ),
          ),
        );
      }),
    );
  }

  // ---------------------------------------------------------------------------
  // ELEMENT C: Laser Unfolding Cyber Pill Badge
  // ---------------------------------------------------------------------------
  Widget _buildLaserUnfoldingBadge() {
    return AnimatedBuilder(
      animation: Listenable.merge([_badgeExpandAnimation, _badgeFadeAnimation]),
      builder: (context, child) {
        final expandValue = _badgeExpandAnimation.value;
        final fadeValue = _badgeFadeAnimation.value;

        if (expandValue <= 0.0) return const SizedBox.shrink();

        return Opacity(
          opacity: fadeValue.clamp(0.0, 1.0),
          child: ClipRect(
            child: Align(
              alignment: Alignment.center,
              widthFactor: expandValue,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFF22C55E).withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: const Color(0xFF4ADE80).withValues(alpha: 0.4),
                    width: 1.2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF22C55E).withValues(alpha: 0.2),
                      blurRadius: 10,
                      spreadRadius: 1,
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Pulsing Status LED Beacon
                    AnimatedBuilder(
                      animation: _ambientController,
                      builder: (context, _) {
                        final glow = math.sin(_ambientController.value * 2 * math.pi) * 0.4 + 0.6;
                        return Container(
                          width: 7,
                          height: 7,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: const Color(0xFF4ADE80),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF4ADE80).withValues(alpha: glow),
                                blurRadius: 6,
                                spreadRadius: 1.5,
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      "OFFLINE EDGE-AI • KAU AGRO-COPILOT",
                      style: TextStyle(
                        fontSize: 10.5,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.1,
                        color: Color(0xFF4ADE80),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  // ---------------------------------------------------------------------------
  // ELEMENT D: "Vox" Audio Equalizer / Voice Frequency Visualizer
  // ---------------------------------------------------------------------------
  Widget _buildVoiceWaveformVisualizer() {
    return FadeTransition(
      opacity: _voiceVisualizerAnimation,
      child: AnimatedBuilder(
        animation: _ambientController,
        builder: (context, _) {
          final t = _ambientController.value;

          return Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                "VOX SOUND ENGINE",
                style: TextStyle(
                  fontSize: 9.5,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1.0,
                  color: Colors.white.withValues(alpha: 0.45),
                ),
              ),
              const SizedBox(width: 10),
              SizedBox(
                height: 18,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: List.generate(7, (i) {
                    // Unique harmonic height oscillation per bar
                    final harmonic = math.sin((t * 2 * math.pi * 2.2) + (i * 0.9));
                    final double barHeight = 4.0 + (harmonic.abs() * 12.0);

                    return Container(
                      margin: const EdgeInsets.symmetric(horizontal: 1.8),
                      width: 2.8,
                      height: barHeight,
                      decoration: BoxDecoration(
                        color: Color.lerp(
                          const Color(0xFF22C55E),
                          const Color(0xFF4ADE80),
                          i / 6.0,
                        ),
                        borderRadius: BorderRadius.circular(2),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF4ADE80).withValues(alpha: 0.5),
                            blurRadius: 4,
                          ),
                        ],
                      ),
                    );
                  }),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // ELEMENT E: High-Tech 4-Segment Subsystem Telemetry HUD
  // ---------------------------------------------------------------------------
  Widget _buildSegmentedTelemetryHud() {
    final milestones = [
      "OPTICAL PIPELINE",
      "YOLOv8 INT8",
      "KAU AGRONOMY",
      "INDIC TTS",
    ];

    return FadeTransition(
      opacity: _telemetryFadeAnimation,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.03),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.08),
            width: 1,
          ),
        ),
        child: Column(
          children: [
            // Top Row: Dynamic Milestone Status + Percentage Readout
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 250),
                    child: Text(
                      _statusText,
                      key: ValueKey<String>(_statusText),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        letterSpacing: 0.3,
                        color: Colors.white.withValues(alpha: 0.85),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  "${(_progressValue * 100).toInt()}%",
                  style: const TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w900,
                    fontFamily: 'monospace',
                    letterSpacing: 0.5,
                    color: Color(0xFF4ADE80),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // 4-Segment Hardware/Software Telemetry Bars
            Row(
              children: List.generate(4, (i) {
                final isCompleted = _currentMilestone > i;
                final isCurrent = _currentMilestone == i + 1;

                return Expanded(
                  child: Container(
                    margin: EdgeInsets.only(right: i < 3 ? 6 : 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Subsystem Mini Indicator Bar
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 400),
                          curve: Curves.easeOutCubic,
                          height: 4,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(2),
                            gradient: isCompleted || isCurrent
                                ? const LinearGradient(
                                    colors: [
                                      Color(0xFF10B981),
                                      Color(0xFF4ADE80),
                                    ],
                                  )
                                : null,
                            color: isCompleted || isCurrent
                                ? null
                                : Colors.white.withValues(alpha: 0.1),
                            boxShadow: isCompleted || isCurrent
                                ? [
                                    BoxShadow(
                                      color: const Color(0xFF4ADE80)
                                          .withValues(alpha: 0.6),
                                      blurRadius: 6,
                                      spreadRadius: 1,
                                    ),
                                  ]
                                : null,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          milestones[i],
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 8.5,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.4,
                            color: isCompleted || isCurrent
                                ? const Color(0xFF4ADE80)
                                : Colors.white.withValues(alpha: 0.3),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // ELEMENT F: Attribution Footer
  // ---------------------------------------------------------------------------
  Widget _buildAnimatedFooter() {
    return FadeTransition(
      opacity: _footerFadeAnimation,
      child: Text(
        "AI Conclave 2026 • Amal Jyothi College of Engineering",
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 10.5,
          color: Colors.white.withValues(alpha: 0.35),
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}

// =============================================================================
// CUSTOM PAINTERS FOR HIGH-TECH VISUAL FX
// =============================================================================

class _BioParticle {
  final double x;
  final double y;
  final double radius;
  final double speed;
  final double baseAlpha;

  const _BioParticle({
    required this.x,
    required this.y,
    required this.radius,
    required this.speed,
    required this.baseAlpha,
  });
}

class _BioParticlesPainter extends CustomPainter {
  final double animationValue;
  final List<_BioParticle> particles;

  _BioParticlesPainter({
    required this.animationValue,
    required this.particles,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;

    for (final p in particles) {
      final curY = ((p.y - animationValue * p.speed) % 1.0) * size.height;
      final curX =
          (p.x + math.sin(animationValue * 2 * math.pi + p.y * 8) * 0.03) *
              size.width;
      final alpha = (p.baseAlpha *
              (0.6 +
                  0.4 *
                      math.sin(
                          animationValue * 2 * math.pi + p.x * 6)))
          .clamp(0.04, 0.7);

      paint.color = const Color(0xFF4ADE80).withValues(alpha: alpha);
      canvas.drawCircle(Offset(curX, curY), p.radius, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _BioParticlesPainter oldDelegate) => true;
}

class _LaserScanPainter extends CustomPainter {
  final double progress;

  _LaserScanPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    if (progress <= 0 || progress >= 1.0) return;

    final y = progress * size.height;

    // Sweeping laser line
    final linePaint = Paint()
      ..shader = LinearGradient(
        colors: [
          Colors.transparent,
          const Color(0xFF4ADE80).withValues(alpha: 0.7),
          Colors.white,
          const Color(0xFF4ADE80).withValues(alpha: 0.7),
          Colors.transparent,
        ],
        stops: const [0.0, 0.25, 0.5, 0.75, 1.0],
      ).createShader(Rect.fromLTWH(0, y - 1, size.width, 2))
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;

    canvas.drawLine(Offset(0, y), Offset(size.width, y), linePaint);

    // Glowing laser trail
    const trailHeight = 35.0;
    final trailPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Colors.transparent,
          const Color(0xFF22C55E).withValues(alpha: 0.1),
        ],
      ).createShader(
          Rect.fromLTWH(0, y - trailHeight, size.width, trailHeight))
      ..style = PaintingStyle.fill;

    canvas.drawRect(
      Rect.fromLTWH(0, y - trailHeight, size.width, trailHeight),
      trailPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _LaserScanPainter oldDelegate) =>
      oldDelegate.progress != progress;
}

class _HudCornerBracketsPainter extends CustomPainter {
  final double progress;
  final double pulse;

  _HudCornerBracketsPainter({
    required this.progress,
    required this.pulse,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (progress <= 0) return;

    final paint = Paint()
      ..color = const Color(0xFF4ADE80)
          .withValues(alpha: (progress * 0.9).clamp(0.0, 0.9))
      ..strokeWidth = 2.4
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final glowPaint = Paint()
      ..color = const Color(0xFF22C55E).withValues(
          alpha: (progress * 0.45 * (0.8 + 0.2 * pulse)).clamp(0.0, 0.6))
      ..strokeWidth = 4.8
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final center = Offset(size.width / 2, size.height / 2);
    // As progress goes from 0 to 1, spread shrinks from 1.4 down to 1.0 (snapping effect)
    final spread = 1.0 + ((1.0 - progress) * 0.4);
    final armLength = 16.0 * progress;
    final half = (size.width * 0.42) * spread;

    final corners = [
      Offset(center.dx - half, center.dy - half), // Top-Left
      Offset(center.dx + half, center.dy - half), // Top-Right
      Offset(center.dx + half, center.dy + half), // Bottom-Right
      Offset(center.dx - half, center.dy + half), // Bottom-Left
    ];

    for (int i = 0; i < 4; i++) {
      final c = corners[i];
      final path = Path();
      if (i == 0) {
        path.moveTo(c.dx, c.dy + armLength);
        path.lineTo(c.dx, c.dy);
        path.lineTo(c.dx + armLength, c.dy);
      } else if (i == 1) {
        path.moveTo(c.dx - armLength, c.dy);
        path.lineTo(c.dx, c.dy);
        path.lineTo(c.dx, c.dy + armLength);
      } else if (i == 2) {
        path.moveTo(c.dx, c.dy - armLength);
        path.lineTo(c.dx, c.dy);
        path.lineTo(c.dx - armLength, c.dy);
      } else {
        path.moveTo(c.dx + armLength, c.dy);
        path.lineTo(c.dx, c.dy);
        path.lineTo(c.dx, c.dy - armLength);
      }
      canvas.drawPath(path, glowPaint);
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _HudCornerBracketsPainter oldDelegate) => true;
}
