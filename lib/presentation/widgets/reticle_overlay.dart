import 'package:flutter/material.dart';

class ReticleOverlay extends StatelessWidget {
  final double size;

  const ReticleOverlay({super.key, this.size = 260});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.65),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.greenAccent.withValues(alpha: 0.4)),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.crop_free, color: Colors.greenAccent, size: 16),
                SizedBox(width: 6),
                Text(
                  "Align lesion inside frame",
                  style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: size,
            height: size,
            child: Stack(
              children: [
                // Outer subtle border
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.greenAccent.withValues(alpha: 0.3), width: 1.5),
                    borderRadius: BorderRadius.circular(24),
                  ),
                ),
                // 4 Corner brackets
                const Align(
                  alignment: Alignment.topLeft,
                  child: _CornerBracket(isTop: true, isLeft: true),
                ),
                const Align(
                  alignment: Alignment.topRight,
                  child: _CornerBracket(isTop: true, isLeft: false),
                ),
                const Align(
                  alignment: Alignment.bottomLeft,
                  child: _CornerBracket(isTop: false, isLeft: true),
                ),
                const Align(
                  alignment: Alignment.bottomRight,
                  child: _CornerBracket(isTop: false, isLeft: false),
                ),
                // Center crosshair
                Center(
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: Colors.greenAccent,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.75),
              borderRadius: BorderRadius.circular(24),
            ),
            child: const Text(
              "Center diseased leaf within the box",
              style: TextStyle(color: Colors.white, fontSize: 13, letterSpacing: 0.2),
            ),
          ),
        ],
      ),
    );
  }
}

class _CornerBracket extends StatelessWidget {
  final bool isTop;
  final bool isLeft;

  const _CornerBracket({required this.isTop, required this.isLeft});

  @override
  Widget build(BuildContext context) {
    const double length = 28;
    const double thickness = 4;
    const color = Colors.greenAccent;

    return Container(
      width: length,
      height: length,
      decoration: BoxDecoration(
        border: Border(
          top: isTop ? const BorderSide(color: color, width: thickness) : BorderSide.none,
          bottom: !isTop ? const BorderSide(color: color, width: thickness) : BorderSide.none,
          left: isLeft ? const BorderSide(color: color, width: thickness) : BorderSide.none,
          right: !isLeft ? const BorderSide(color: color, width: thickness) : BorderSide.none,
        ),
        borderRadius: BorderRadius.only(
          topLeft: isTop && isLeft ? const Radius.circular(20) : Radius.zero,
          topRight: isTop && !isLeft ? const Radius.circular(20) : Radius.zero,
          bottomLeft: !isTop && isLeft ? const Radius.circular(20) : Radius.zero,
          bottomRight: !isTop && !isLeft ? const Radius.circular(20) : Radius.zero,
        ),
      ),
    );
  }
}
