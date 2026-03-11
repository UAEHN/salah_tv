import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/app_colors.dart';
import '../prayer_provider.dart';
import '../../../settings/presentation/settings_provider.dart';

class AnalogClockWidget extends StatelessWidget {
  final AccentPalette palette;
  final bool compact;
  final bool tiny;

  const AnalogClockWidget({
    super.key,
    required this.palette,
    this.compact = false,
    this.tiny = false,
  });

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>().settings;
    final now = context.watch<PrayerProvider>().now;
    final screenH = MediaQuery.of(context).size.height;
    final tc = ThemeColors.of(settings.isDarkMode);

    final diameter = tiny
        ? screenH * 0.11
        : compact
            ? screenH * 0.26
            : screenH * 0.40;

    return SizedBox(
      width: diameter,
      height: diameter,
      child: CustomPaint(
        painter: _AnalogClockPainter(
          now: now,
          palette: palette,
          tc: tc,
        ),
      ),
    );
  }
}

class _AnalogClockPainter extends CustomPainter {
  final DateTime now;
  final AccentPalette palette;
  final ThemeColors tc;

  const _AnalogClockPainter({
    required this.now,
    required this.palette,
    required this.tc,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    // Background fill
    canvas.drawCircle(
      center,
      radius,
      Paint()..color = tc.bgSurface.withValues(alpha: 0.88),
    );

    // Outer ring
    canvas.drawCircle(
      center,
      radius - radius * 0.02,
      Paint()
        ..color = palette.primary.withValues(alpha: 0.75)
        ..style = PaintingStyle.stroke
        ..strokeWidth = radius * 0.045,
    );

    // Tick marks (12 hour positions)
    for (int i = 0; i < 12; i++) {
      final angle = i * 30 * math.pi / 180 - math.pi / 2;
      final isMain = i % 3 == 0;
      final outerR = radius * 0.86;
      final innerR = isMain ? radius * 0.72 : radius * 0.79;
      canvas.drawLine(
        Offset(center.dx + innerR * math.cos(angle), center.dy + innerR * math.sin(angle)),
        Offset(center.dx + outerR * math.cos(angle), center.dy + outerR * math.sin(angle)),
        Paint()
          ..color = isMain
              ? tc.textPrimary.withValues(alpha: 0.88)
              : tc.textSecondary.withValues(alpha: 0.50)
          ..strokeWidth = isMain ? radius * 0.045 : radius * 0.025
          ..strokeCap = StrokeCap.round,
      );
    }

    // Hour hand
    _drawHand(
      canvas,
      center,
      ((now.hour % 12) + now.minute / 60) * 30 * math.pi / 180 - math.pi / 2,
      radius * 0.50,
      radius * 0.068,
      tc.textPrimary,
    );

    // Minute hand
    _drawHand(
      canvas,
      center,
      (now.minute + now.second / 60) * 6 * math.pi / 180 - math.pi / 2,
      radius * 0.72,
      radius * 0.045,
      tc.textPrimary,
    );

    // Second hand (with tail)
    _drawHand(
      canvas,
      center,
      now.second * 6 * math.pi / 180 - math.pi / 2,
      radius * 0.76,
      radius * 0.022,
      palette.primary,
      tail: radius * 0.20,
    );

    // Center cap
    canvas.drawCircle(center, radius * 0.075, Paint()..color = palette.primary);
    canvas.drawCircle(center, radius * 0.035, Paint()..color = tc.textPrimary);
  }

  void _drawHand(
    Canvas canvas,
    Offset center,
    double angle,
    double length,
    double width,
    Color color, {
    double tail = 0,
  }) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = width
      ..strokeCap = StrokeCap.round;
    final tip = Offset(center.dx + length * math.cos(angle), center.dy + length * math.sin(angle));
    final base = tail > 0
        ? Offset(center.dx - tail * math.cos(angle), center.dy - tail * math.sin(angle))
        : center;
    canvas.drawLine(base, tip, paint);
  }

  @override
  bool shouldRepaint(_AnalogClockPainter old) => old.now != now || old.tc != tc;
}
