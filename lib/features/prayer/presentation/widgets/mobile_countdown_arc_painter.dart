import 'dart:math' as math;
import 'package:flutter/material.dart';

/// Paints a circular arc countdown indicator.
/// [progress] = 0.0 (empty) → 1.0 (full arc completed).
class MobileCountdownArcPainter extends CustomPainter {
  final double progress;
  final Color arcColor;
  final Color trackColor;
  final double strokeWidth;

  const MobileCountdownArcPainter({
    required this.progress,
    required this.arcColor,
    required this.trackColor,
    this.strokeWidth = 5.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.shortestSide / 2) - 6;
    const startAngle = -math.pi / 2; // 12 o'clock

    // Track (background circle)
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      0,
      2 * math.pi,
      false,
      Paint()
        ..color = trackColor
        ..strokeWidth = strokeWidth
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round,
    );

    // Progress arc
    final sweepAngle = 2 * math.pi * progress.clamp(0.0, 1.0);
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      sweepAngle,
      false,
      Paint()
        ..color = arcColor
        ..strokeWidth = strokeWidth
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(MobileCountdownArcPainter old) =>
      old.progress != progress ||
      old.arcColor != arcColor ||
      old.trackColor != trackColor;
}
