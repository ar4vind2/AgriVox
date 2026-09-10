import 'dart:math' as math;
import 'package:flutter/material.dart';

class AnimatedPulseLogo extends StatefulWidget {
  final double size;
  final bool showRings;
  final bool showReticle;

  const AnimatedPulseLogo({
    super.key,
    this.size = 100,
    this.showRings = true,
    this.showReticle = true,
  });

  @override
  State<AnimatedPulseLogo> createState() => _AnimatedPulseLogoState();
}

class _AnimatedPulseLogoState extends State<AnimatedPulseLogo>
    with TickerProviderStateMixin {
  late final AnimationController _pulseController;
  late final AnimationController _radarController;
  late final AnimationController _rotateController;

  late final Animation<double> _scaleAnimation;
  late final Animation<double> _radarAnimation;

  @override
  void initState() {
    super.initState();

    // Subtle organic breathing scale
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    )..repeat(reverse: true);

    _scaleAnimation = Tween<double>(begin: 0.96, end: 1.04).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOutSine),
    );

    // Continuous expanding radar wave
    _radarController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    )..repeat();

    _radarAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _radarController, curve: Curves.easeOutQuad),
    );

    // Slow orbital rotation for tech reticle
    _rotateController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 14),
    )..repeat();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _radarController.dispose();
    _rotateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final logoSize = widget.size;
    final totalDimension = logoSize * 2.2;

    return SizedBox(
      width: totalDimension,
      height: totalDimension,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Expanding Radar / Pulse waves
          if (widget.showRings)
            AnimatedBuilder(
              animation: _radarAnimation,
              builder: (context, child) {
                return CustomPaint(
                  size: Size(totalDimension, totalDimension),
                  painter: _RadarWavePainter(
                    progress: _radarAnimation.value,
                    baseRadius: logoSize * 0.58,
                    accentColor: const Color(0xFF4ADE80),
                  ),
                );
              },
            ),

          // High-tech orbital rotating reticle ring
          if (widget.showReticle)
            AnimatedBuilder(
              animation: _rotateController,
              builder: (context, child) {
                return Transform.rotate(
                  angle: _rotateController.value * 2 * math.pi,
                  child: CustomPaint(
                    size: Size(logoSize * 1.5, logoSize * 1.5),
                    painter: _ReticleTechPainter(
                      color: const Color(0xFF22C55E).withValues(alpha: 0.45),
                    ),
                  ),
                );
              },
            ),

          // Ambient Radial Glow
          Container(
            width: logoSize * 1.15,
            height: logoSize * 1.15,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF10B981).withValues(alpha: 0.35),
                  blurRadius: logoSize * 0.45,
                  spreadRadius: logoSize * 0.1,
                ),
              ],
            ),
          ),

          // Central Breathing Logo Container
          AnimatedBuilder(
            animation: _scaleAnimation,
            builder: (context, child) {
              return Transform.scale(
                scale: _scaleAnimation.value,
                child: child,
              );
            },
            child: Container(
              width: logoSize,
              height: logoSize,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(logoSize * 0.24),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.25),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.35),
                    blurRadius: 18,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(logoSize * 0.24),
                child: Image.asset(
                  'assets/icon/app_icon.png',
                  width: logoSize,
                  height: logoSize,
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _RadarWavePainter extends CustomPainter {
  final double progress;
  final double baseRadius;
  final Color accentColor;

  _RadarWavePainter({
    required this.progress,
    required this.baseRadius,
    required this.accentColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);

    for (int i = 0; i < 3; i++) {
      final ringProgress = (progress + (i / 3.0)) % 1.0;
      final currentRadius = baseRadius + (ringProgress * (size.width * 0.4));
      final opacity = (1.0 - ringProgress).clamp(0.0, 1.0) * 0.4;

      final paint = Paint()
        ..color = accentColor.withValues(alpha: opacity)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.6 * (1.0 - ringProgress);

      canvas.drawCircle(center, currentRadius, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _RadarWavePainter oldDelegate) =>
      oldDelegate.progress != progress;
}

class _ReticleTechPainter extends CustomPainter {
  final Color color;

  _ReticleTechPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.8;

    // Draw 4 circular arc segments around the logo
    const arcAngle = math.pi / 3.2;
    for (int i = 0; i < 4; i++) {
      final startAngle = (i * math.pi / 2) + 0.15;
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        arcAngle,
        false,
        paint,
      );

      // Add a small tech tick dot at corner
      final dotAngle = startAngle + arcAngle + 0.08;
      final dotOffset = Offset(
        center.dx + radius * math.cos(dotAngle),
        center.dy + radius * math.sin(dotAngle),
      );
      canvas.drawCircle(dotOffset, 2.0, paint..style = PaintingStyle.fill);
      paint.style = PaintingStyle.stroke;
    }
  }

  @override
  bool shouldRepaint(covariant _ReticleTechPainter oldDelegate) => false;
}
