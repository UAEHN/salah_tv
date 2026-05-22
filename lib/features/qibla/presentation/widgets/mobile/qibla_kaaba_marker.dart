import 'package:flutter/material.dart';

import '../../../../../core/mobile_theme.dart';

/// Marker placed on the rotating compass ring at [qiblaBearing]. Tinted with
/// the active theme accent so a green palette gives a green marker, gold
/// gives gold, etc. Grows brighter when the user is aligned with Mecca.
class QiblaKaabaMarker extends StatelessWidget {
  final bool isAligned;
  const QiblaKaabaMarker({super.key, this.isAligned = false});

  @override
  Widget build(BuildContext context) {
    final accent = MobileColors.activePrimary(context);
    final brightAccent = MobileColors.activePrimaryContainer(context);
    final color = isAligned ? brightAccent : accent;
    return Align(
      alignment: Alignment.topCenter,
      child: Padding(
        padding: const EdgeInsets.only(top: 6),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 280),
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: color,
            boxShadow: [
              BoxShadow(
                color: color.withValues(alpha: isAligned ? 0.75 : 0.45),
                blurRadius: isAligned ? 18 : 10,
                spreadRadius: isAligned ? 3 : 1,
              ),
            ],
          ),
          child: const Icon(
            Icons.mosque_rounded,
            size: 20,
            color: Color(0xFF1A1208),
          ),
        ),
      ),
    );
  }
}
