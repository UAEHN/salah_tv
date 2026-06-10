import 'package:flutter/material.dart';

import '../../../../../core/mobile_theme.dart';

/// Center readout of the compass — the live angle between the device and
/// the Qibla. When aligned, the number tilts to the active accent.
class QiblaCompassCenter extends StatelessWidget {
  final double angle;
  final bool isAligned;

  const QiblaCompassCenter({
    super.key,
    required this.angle,
    this.isAligned = false,
  });

  @override
  Widget build(BuildContext context) {
    final accent = MobileColors.activePrimary(context);
    final onSurface = MobileColors.onSurface(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        AnimatedDefaultTextStyle(
          duration: const Duration(milliseconds: 260),
          style: TextStyle(
            fontFamily: 'Rubik',
            fontSize: 52,
            fontWeight: FontWeight.w800,
            color: isAligned ? accent : onSurface,
            height: 1.0,
            letterSpacing: -1,
          ),
          child: Text('${angle.toInt()}°', textDirection: TextDirection.ltr),
        ),
        const SizedBox(height: 8),
        Container(
          width: 22,
          height: 1.2,
          color: onSurface.withValues(alpha: 0.20),
        ),
        const SizedBox(height: 6),
        Opacity(
          opacity: isAligned ? 0.95 : 0.75,
          child: Image.asset(
            'assets/kaaba.png',
            width: 18,
            height: 18,
            fit: BoxFit.contain,
          ),
        ),
      ],
    );
  }
}
