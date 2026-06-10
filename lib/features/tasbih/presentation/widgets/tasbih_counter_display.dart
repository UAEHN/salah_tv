import 'dart:math';
import 'package:flutter/material.dart';

import '../../../../core/mobile_theme.dart';

class TasbihCounterDisplay extends StatelessWidget {
  final int count;
  final int target;
  final bool isCompleted;
  final VoidCallback? onTap;

  const TasbihCounterDisplay({
    super.key,
    required this.count,
    required this.target,
    required this.isCompleted,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final progress = (count / target).clamp(0.0, 1.0);
    final accent = isCompleted
        ? const Color(0xFF4CAF50)
        : MobileColors.activePrimary(context);
    final size = (MediaQuery.of(context).size.height * 0.26).clamp(
      150.0,
      240.0,
    );

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: size,
        height: size,
        child: CustomPaint(
          painter: _RingPainter(
            progress: progress,
            color: accent,
            isDark: MobileColors.isDark(context),
          ),
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 160),
                  transitionBuilder: (child, anim) =>
                      ScaleTransition(scale: anim, child: child),
                  child: Text(
                    '$count',
                    key: ValueKey(count),
                    style: TextStyle(
                      fontSize: size * 0.24,
                      fontWeight: FontWeight.bold,
                      color: accent,
                      height: 1,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '/ $target',
                  style: TextStyle(
                    fontSize: size * 0.07,
                    color: accent.withValues(alpha: 0.5),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  final double progress;
  final Color color;
  final bool isDark;

  _RingPainter({
    required this.progress,
    required this.color,
    required this.isDark,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.shortestSide / 2) - 6;
    const stroke = 6.0;

    // Track ring
    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = stroke
        ..color = color.withValues(alpha: isDark ? 0.10 : 0.15),
    );

    // Progress arc
    if (progress > 0) {
      final rect = Rect.fromCircle(center: center, radius: radius);
      canvas.drawArc(
        rect,
        -pi / 2,
        2 * pi * progress,
        false,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = stroke
          ..strokeCap = StrokeCap.round
          ..color = color,
      );
    }

    // Inner subtle fill
    canvas.drawCircle(
      center,
      radius - stroke - 4,
      Paint()..color = color.withValues(alpha: isDark ? 0.04 : 0.06),
    );
  }

  @override
  bool shouldRepaint(_RingPainter old) =>
      old.progress != progress || old.color != color;
}
