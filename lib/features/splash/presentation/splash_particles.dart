import 'dart:math';
import 'package:flutter/material.dart';

/// Tiny golden particles drifting upward in the centre band,
/// creating a sacred / ethereal dust effect.
class SplashParticles extends StatelessWidget {
  final Animation<double> animation;
  const SplashParticles({required this.animation, super.key});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (_, _) => CustomPaint(
        painter: _ParticlePainter(animation.value),
        size: Size.infinite,
      ),
    );
  }
}

class _ParticlePainter extends CustomPainter {
  final double t;
  static final List<_P> _particles = _gen(35, 77);

  _ParticlePainter(this.t);

  static List<_P> _gen(int n, int seed) {
    final r = Random(seed);
    return List.generate(n, (_) => _P(
      x0: r.nextDouble() * 0.5 + 0.25,
      y0: r.nextDouble(),
      speed: 0.08 + r.nextDouble() * 0.15,
      radius: 0.4 + r.nextDouble() * 1.0,
      phase: r.nextDouble() * pi * 2,
      drift: 0.008 + r.nextDouble() * 0.012,
    ));
  }

  @override
  void paint(Canvas canvas, Size size) {
    for (final p in _particles) {
      final y = (p.y0 - p.speed * t) % 1.0;
      final x = p.x0 + sin(p.phase + t * pi * 4) * p.drift;
      final alpha = sin(y * pi) * 0.4;
      if (alpha < 0.02) continue;
      canvas.drawCircle(
        Offset(x * size.width, y * size.height),
        p.radius,
        Paint()..color = Color.fromRGBO(212, 168, 67, alpha),
      );
    }
  }

  @override
  bool shouldRepaint(_ParticlePainter old) => true;
}

class _P {
  final double x0, y0, speed, radius, phase, drift;
  const _P({
    required this.x0, required this.y0, required this.speed,
    required this.radius, required this.phase, required this.drift,
  });
}
