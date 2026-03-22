import 'dart:math' as math;
import 'package:flutter/material.dart';

/// Paints a circular arc countdown indicator with gradient fill and glowing tip.
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
    final radius = (size.shortestSide / 2) - strokeWidth / 2 - 2;
    const startAngle = -math.pi / 2; // 12 o'clock
    final clamped = progress.clamp(0.0, 1.0);
    final sweepAngle = 2 * math.pi * clamped;
    final rect = Rect.fromCircle(center: center, radius: radius);

    // ── Track ────────────────────────────────────────────────────────────────
    canvas.drawArc(
      rect,
      0,
      2 * math.pi,
      false,
      Paint()
        ..color = trackColor
        ..strokeWidth = strokeWidth
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round,
    );

    if (clamped <= 0.0) return;

    // ── Gradient arc ─────────────────────────────────────────────────────────
    final gradientEnd = startAngle + sweepAngle;
    final gradient = SweepGradient(
      startAngle: startAngle,
      endAngle: gradientEnd.clamp(startAngle + 0.01, startAngle + 2 * math.pi),
      colors: [
        arcColor.withValues(alpha: 0.15),
        arcColor.withValues(alpha: 0.6),
        arcColor,
      ],
      stops: const [0.0, 0.55, 1.0],
    );

    canvas.drawArc(
      rect,
      startAngle,
      sweepAngle,
      false,
      Paint()
        ..shader = gradient.createShader(rect)
        ..strokeWidth = strokeWidth
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round,
    );

    // ── Glowing tip dot ───────────────────────────────────────────────────────
    final tipAngle = startAngle + sweepAngle;
    final tip = Offset(
      center.dx + radius * math.cos(tipAngle),
      center.dy + radius * math.sin(tipAngle),
    );

    // Outer glow bloom
    canvas.drawCircle(
      tip,
      strokeWidth * 1.1,
      Paint()
        ..color = arcColor.withValues(alpha: 0.3)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8),
    );

    // Solid dot — white center
    canvas.drawCircle(
      tip,
      strokeWidth * 0.42,
      Paint()..color = Colors.white,
    );

    // Colored ring around dot
    canvas.drawCircle(
      tip,
      strokeWidth * 0.55,
      Paint()
        ..color = arcColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth * 0.25,
    );
  }

  @override
  bool shouldRepaint(MobileCountdownArcPainter old) =>
      old.progress != progress ||
      old.arcColor != arcColor ||
      old.trackColor != trackColor ||
      old.strokeWidth != strokeWidth;
}
