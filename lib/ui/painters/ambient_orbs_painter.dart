import 'dart:math';
import 'package:flutter/material.dart';

/// Floating ambient orbs — softly animated radial gradients that drift
/// slowly across the background to give the screen a "living" feel.
class AmbientOrbsPainter extends CustomPainter {
  final double t; // 0..1 animation progress (repeating)
  final Color color;

  const AmbientOrbsPainter({required this.t, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    // Define 4 orbs with different radii, speeds, and trajectories
    final orbs = [
      _Orb(
        cx: 0.15 + 0.10 * sin(t * 2 * pi),
        cy: 0.30 + 0.08 * cos(t * 2 * pi * 0.7),
        r: size.width * 0.22,
        alpha: 0.07,
      ),
      _Orb(
        cx: 0.80 + 0.08 * cos(t * 2 * pi * 0.9),
        cy: 0.18 + 0.10 * sin(t * 2 * pi * 1.1),
        r: size.width * 0.20,
        alpha: 0.06,
      ),
      _Orb(
        cx: 0.55 + 0.12 * sin(t * 2 * pi * 0.6 + 1.0),
        cy: 0.75 + 0.07 * cos(t * 2 * pi * 0.8),
        r: size.width * 0.18,
        alpha: 0.05,
      ),
      _Orb(
        cx: 0.25 + 0.09 * cos(t * 2 * pi * 1.2 + 2.0),
        cy: 0.70 + 0.09 * sin(t * 2 * pi * 0.5),
        r: size.width * 0.15,
        alpha: 0.05,
      ),
    ];

    for (final orb in orbs) {
      final center = Offset(orb.cx * size.width, orb.cy * size.height);
      final paint = Paint()
        ..shader = RadialGradient(
          colors: [
            color.withValues(alpha: orb.alpha),
            color.withValues(alpha: 0),
          ],
        ).createShader(Rect.fromCircle(center: center, radius: orb.r));
      canvas.drawCircle(center, orb.r, paint);
    }
  }

  @override
  bool shouldRepaint(AmbientOrbsPainter old) =>
      old.t != t || old.color != color;
}

class _Orb {
  final double cx, cy, r, alpha;
  const _Orb({
    required this.cx,
    required this.cy,
    required this.r,
    required this.alpha,
  });
}
