import 'package:flutter/material.dart';

import '../../../../../core/mobile_theme.dart';

BoxDecoration buildMobilePrayerActiveDecoration(
  bool isDark,
  Color accent,
  Color deep,
) {
  return BoxDecoration(
    gradient: LinearGradient(
      begin: Alignment.centerRight,
      end: Alignment.centerLeft,
      colors: isDark
          ? [
              Color.alphaBlend(
                accent.withValues(alpha: 0.15),
                const Color(0xFF1A150C),
              ),
              const Color(0xFF261D0F),
            ]
          : [
              Color.alphaBlend(accent.withValues(alpha: 0.8), deep),
              Color.alphaBlend(accent.withValues(alpha: 0.6), deep),
            ],
    ),
    borderRadius: BorderRadius.circular(20),
    border: Border.all(
      color: accent.withValues(alpha: isDark ? 0.3 : 0.5),
      width: 1.5,
    ),
    boxShadow: [
      BoxShadow(
        color: accent.withValues(alpha: isDark ? 0.15 : 0.3),
        offset: const Offset(0, 4),
        blurRadius: 16,
        spreadRadius: 2,
      ),
    ],
  );
}

BoxDecoration buildMobilePrayerInactiveDecoration(
  BuildContext context,
  bool isDark,
  Color accentBright,
  Color accentDeep,
) {
  if (isDark) {
    return BoxDecoration(
      color: MobileColors.cardColor(context).withValues(alpha: 0.4),
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: Colors.white.withValues(alpha: 0.05), width: 1),
    );
  }
  return BoxDecoration(
    gradient: LinearGradient(
      begin: Alignment.centerRight,
      end: Alignment.centerLeft,
      colors: [
        Color.alphaBlend(accentBright.withValues(alpha: 0.04), Colors.white),
        Colors.white,
      ],
    ),
    borderRadius: BorderRadius.circular(20),
    border: Border.all(color: accentBright.withValues(alpha: 0.08), width: 1),
    boxShadow: [
      BoxShadow(
        color: accentDeep.withValues(alpha: 0.04),
        offset: const Offset(0, 2),
        blurRadius: 6,
      ),
    ],
  );
}
