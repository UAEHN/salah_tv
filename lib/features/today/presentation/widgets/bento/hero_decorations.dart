import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Decorative layers used by [BentoPrayerTile] to give the hero countdown
/// surface depth — three layers stacked behind the foreground text:
///
///   1. [HeroHighlight]  — soft white glow in the top-leading corner that
///      hints at a single light source.
///   2. [HeroNoise]      — sparse, deterministic 1px speckles to break the
///      flat gradient and add a "printed paper" tactility.
///
/// All three sit *under* the foreground content and are rendered as
/// `IgnorePointer` so they never steal taps.

class HeroHighlight extends StatelessWidget {
  const HeroHighlight({super.key, this.size = 220, this.alpha = 0.22});

  final double size;
  final double alpha;

  @override
  Widget build(BuildContext context) {
    return PositionedDirectional(
      start: -40,
      top: -50,
      child: IgnorePointer(
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(
              colors: [
                Colors.white.withValues(alpha: alpha),
                Colors.white.withValues(alpha: 0),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class HeroNoise extends StatelessWidget {
  /// Set [isDark] when the tile sits on the dark-mode gradient — white
  /// speckles read as dust against a low-luminance surface, so in dark
  /// mode the texture is rendered at much lower opacity *and* tinted with
  /// a hint of the gradient instead of pure white. The pattern stays the
  /// same so the surface still has tactility, just whisper-quiet.
  const HeroNoise({super.key, required this.isDark});

  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: IgnorePointer(
        child: CustomPaint(painter: _HeroNoisePainter(isDark: isDark)),
      ),
    );
  }
}

class _HeroNoisePainter extends CustomPainter {
  _HeroNoisePainter({required this.isDark});

  final bool isDark;

  @override
  void paint(Canvas canvas, Size size) {
    // Fixed seed → deterministic, identical pattern every paint, so the
    // noise reads as part of the tile rather than animating between frames.
    final rnd = math.Random(7);
    final paint = Paint();
    // Lower density on dark; lighter alpha range; smaller radii.
    final dots = ((size.width * size.height) / (isDark ? 900 : 360)).round();
    final baseAlpha = isDark ? 0.018 : 0.05;
    final alphaSwing = isDark ? 0.018 : 0.06;
    final maxR = isDark ? 0.55 : 0.85;
    for (var i = 0; i < dots; i++) {
      final dx = rnd.nextDouble() * size.width;
      final dy = rnd.nextDouble() * size.height;
      final r = 0.3 + rnd.nextDouble() * (maxR - 0.3);
      // Per-dot alpha jitter → organic film-grain feel, no banding.
      final a = baseAlpha + rnd.nextDouble() * alphaSwing;
      paint.color = Colors.white.withValues(alpha: a);
      canvas.drawCircle(Offset(dx, dy), r, paint);
    }
  }

  @override
  bool shouldRepaint(_HeroNoisePainter old) => old.isDark != isDark;
}
