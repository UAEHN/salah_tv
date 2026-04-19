import 'dart:math' as math;
import 'package:flutter/material.dart';

/// Draws a circular arc with gradient stroke to visualize countdown progress.
class HeroArcPainter extends CustomPainter {
  final double progress;
  final Color startColor;
  final Color endColor;
  final double strokeWidth;
  final Color trackColor;

  HeroArcPainter({
    required this.progress,
    required this.startColor,
    required this.endColor,
    this.strokeWidth = 5,
    this.trackColor = const Color(0x15FFFFFF),
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.shortestSide - strokeWidth) / 2;
    final rect = Rect.fromCircle(center: center, radius: radius);
    const startAngle = -math.pi / 2;
    final sweepAngle = 2 * math.pi * progress.clamp(0.0, 1.0);

    // Track (full circle, faint)
    final trackPaint = Paint()
      ..color = trackColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;
    canvas.drawCircle(center, radius, trackPaint);

    if (sweepAngle <= 0) return;

    // Arc with gradient
    final arcPaint = Paint()
      ..shader = SweepGradient(
        startAngle: startAngle,
        endAngle: startAngle + sweepAngle,
        colors: [startColor, endColor],
      ).createShader(rect)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(rect, startAngle, sweepAngle, false, arcPaint);

    // Glow dot at the tip — simulated with two concentric circles instead of
    // MaskFilter.blur (which forces a GPU compositing layer on every frame).
    final tipAngle = startAngle + sweepAngle;
    final tipX = center.dx + radius * math.cos(tipAngle);
    final tipY = center.dy + radius * math.sin(tipAngle);
    final tip = Offset(tipX, tipY);
    canvas.drawCircle(tip, strokeWidth * 1.8,
        Paint()..color = endColor.withValues(alpha: 0.10));
    canvas.drawCircle(tip, strokeWidth * 1.1,
        Paint()..color = endColor.withValues(alpha: 0.30));
    canvas.drawCircle(tip, strokeWidth * 0.7,
        Paint()..color = endColor);
  }

  @override
  bool shouldRepaint(HeroArcPainter old) =>
      old.progress != progress ||
      old.startColor != startColor ||
      old.endColor != endColor;
}
