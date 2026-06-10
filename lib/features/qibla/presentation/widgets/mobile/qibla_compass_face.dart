import 'package:flutter/material.dart';

import '../../../../../core/mobile_theme.dart';

/// Cardinal labels in the order they're drawn on the rotating ring.
const qiblaCardinals = <(String, Alignment)>[
  ('N', Alignment.topCenter),
  ('E', Alignment.centerRight),
  ('S', Alignment.bottomCenter),
  ('W', Alignment.centerLeft),
];

/// Outer compass face: radial gradient + theme accent border when aligned.
BoxDecoration qiblaFaceDecoration(BuildContext context, bool aligned) {
  final isDark = MobileColors.isDark(context);
  final accent = MobileColors.activePrimary(context);
  final gradient = isDark
      ? const RadialGradient(colors: [Color(0xFF131D36), Color(0xFF0A1226)])
      : RadialGradient(
          colors: [
            Colors.white,
            Color.alphaBlend(
              accent.withValues(alpha: 0.06),
              const Color(0xFFFAF7F0),
            ),
          ],
        );
  return BoxDecoration(
    shape: BoxShape.circle,
    gradient: gradient,
    border: Border.all(
      color: aligned
          ? accent.withValues(alpha: 0.95)
          : MobileColors.border(context),
      width: aligned ? 2 : 1,
    ),
    boxShadow: [
      BoxShadow(
        color: aligned
            ? accent.withValues(alpha: isDark ? 0.35 : 0.22)
            : (isDark
                  ? Colors.black.withValues(alpha: 0.45)
                  : accent.withValues(alpha: 0.10)),
        blurRadius: aligned ? 36 : 26,
        spreadRadius: aligned ? 4 : 2,
        offset: const Offset(0, 12),
      ),
    ],
  );
}

/// Thin concentric guide ring drawn inside the compass face.
class QiblaCompassGuideRing extends StatelessWidget {
  final double size;
  final double alpha;
  const QiblaCompassGuideRing({
    super.key,
    required this.size,
    required this.alpha,
  });

  @override
  Widget build(BuildContext context) {
    final base = MobileColors.isDark(context)
        ? Colors.white
        : MobileColors.onSurface(context);
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: base.withValues(alpha: alpha)),
      ),
    );
  }
}
