import 'package:flutter/material.dart';

import '../../../../../core/mobile_theme.dart';

/// N / E / S / W cardinal label placed on the rotating compass ring.
class QiblaDirectionLabel extends StatelessWidget {
  final String label;
  final Alignment alignment;

  const QiblaDirectionLabel({
    super.key,
    required this.label,
    required this.alignment,
  });

  @override
  Widget build(BuildContext context) {
    final isN = label == 'N';
    final color = isN
        ? MobileColors.activePrimary(context).withValues(alpha: 0.95)
        : MobileColors.onSurface(context).withValues(alpha: 0.55);
    return Align(
      alignment: alignment,
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Text(
          label,
          textDirection: TextDirection.ltr,
          style: TextStyle(
            fontFamily: 'Rubik',
            color: color,
            fontSize: 13,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.5,
          ),
        ),
      ),
    );
  }
}
