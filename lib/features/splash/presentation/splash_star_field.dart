import 'dart:math';
import 'package:flutter/material.dart';

/// Animated star field with twinkling stars, golden glow stars,
/// and occasional shooting stars (meteors).
class SplashStarField extends StatelessWidget {
  final Animation<double> animation;
  const SplashStarField({required this.animation, super.key});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (_, _) => CustomPaint(
        painter: _StarPainter(animation.value),
        size: Size.infinite,
      ),
    );
  }
}

class _StarPainter extends CustomPainter {
  final double t;
  static final List<_Star> _stars = _genStars(120, 42);
  static final List<_Meteor> _meteors = _genMeteors(5, 99);

  _StarPainter(this.t);

  static List<_Star> _genStars(int n, int seed) {
    final r = Random(seed);
    return List.generate(n, (_) {
      final base = r.nextDouble();
      return _Star(
        x: r.nextDouble(),
        y: r.nextDouble(),
        radius: base * 1.8 + 0.4,
        phase: r.nextDouble() * pi * 2,
        speed: r.nextDouble() * 0.6 + 0.4,
        isGlow: base > 0.85,
      );
    });
  }

  static List<_Meteor> _genMeteors(int n, int seed) {
    final r = Random(seed);
    return List.generate(n, (_) => _Meteor(
      sx: r.nextDouble() * 0.6 + 0.2,
      sy: r.nextDouble() * 0.3,
      angle: pi * 0.6 + r.nextDouble() * 0.3,
      len: 0.08 + r.nextDouble() * 0.12,
      start: r.nextDouble(),
      dur: 0.04 + r.nextDouble() * 0.03,
    ));
  }

  @override
  void paint(Canvas canvas, Size size) {
    // --- Stars ---
    for (final s in _stars) {
      final a = ((sin(s.phase + t * pi * 2 * s.speed) + 1) / 2)
          .clamp(0.1, 1.0);
      final c = s.isGlow
          ? Color.fromRGBO(212, 168, 67, a * 0.6)
          : Color.fromRGBO(255, 255, 255, a * 0.7);
      final paint = Paint()..color = c;
      final center = Offset(s.x * size.width, s.y * size.height);
      final r = s.radius * (s.isGlow ? 1.6 : 1.0);
      if (s.isGlow) {
        // Simulate glow with two extra low-opacity circles — no GPU blur needed
        canvas.drawCircle(center, r * 2.5,
            Paint()..color = Color.fromRGBO(212, 168, 67, a * 0.15));
        canvas.drawCircle(center, r * 1.5,
            Paint()..color = Color.fromRGBO(212, 168, 67, a * 0.30));
      }
      canvas.drawCircle(center, r, paint);
    }
    // --- Meteors ---
    for (final m in _meteors) {
      final elapsed = (t - m.start) % 1.0;
      if (elapsed > m.dur) continue;
      final prog = elapsed / m.dur;
      final hx = m.sx + cos(m.angle) * m.len * prog;
      final hy = m.sy + sin(m.angle) * m.len * prog;
      for (int i = 0; i < 10; i++) {
        final f = i / 10.0;
        final tx = hx - cos(m.angle) * m.len * 0.06 * f;
        final ty = hy - sin(m.angle) * m.len * 0.06 * f;
        final alpha = ((1.0 - f) * (1.0 - prog * 0.5)).clamp(0.0, 1.0);
        canvas.drawCircle(
          Offset(tx * size.width, ty * size.height),
          (1.8 - f * 1.2).clamp(0.3, 2.0),
          Paint()..color = Color.fromRGBO(255, 255, 255, alpha * 0.9),
        );
      }
    }
  }

  @override
  bool shouldRepaint(_StarPainter old) => true;
}

class _Star {
  final double x, y, radius, phase, speed;
  final bool isGlow;
  const _Star({
    required this.x, required this.y, required this.radius,
    required this.phase, required this.speed, required this.isGlow,
  });
}

class _Meteor {
  final double sx, sy, angle, len, start, dur;
  const _Meteor({
    required this.sx, required this.sy, required this.angle,
    required this.len, required this.start, required this.dur,
  });
}
