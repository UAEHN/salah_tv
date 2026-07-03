import 'package:flutter/material.dart';

import '../../../../../core/mobile_theme.dart';

/// Circular progress ring for the Khatma — a thin track with an accent arc and
/// an optional [center] widget (percentage label). Built on the framework's
/// [CircularProgressIndicator] so there's no hand-painted geometry.
class KhatmaRing extends StatelessWidget {
  /// 0..1 completion.
  final double fraction;
  final double size;
  final double strokeWidth;
  final Widget? center;

  const KhatmaRing({
    super.key,
    required this.fraction,
    this.size = 96,
    this.strokeWidth = 7,
    this.center,
  });

  @override
  Widget build(BuildContext context) {
    final accent = MobileColors.activePrimary(context);
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox(
            width: size,
            height: size,
            child: CircularProgressIndicator(
              value: fraction.clamp(0.0, 1.0),
              strokeWidth: strokeWidth,
              strokeCap: StrokeCap.round,
              backgroundColor: accent.withValues(alpha: 0.14),
              valueColor: AlwaysStoppedAnimation<Color>(accent),
            ),
          ),
          ?center,
        ],
      ),
    );
  }
}
