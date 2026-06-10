import 'package:flutter/material.dart';

import '../../../../../core/mobile_theme.dart';

BoxDecoration buildMobilePrayerActiveDecoration(
  BuildContext context,
  bool isDark,
  Color accent,
  Color deep,
) {
  final activePrimary = MobileColors.activePrimary(context);
  final activeContainer = MobileColors.activePrimaryContainer(context);
  // Slightly darken the live primary on dark theme so the row stays readable
  // without losing the user-selected hue.
  final fill = isDark
      ? Color.lerp(activePrimary, Colors.black, 0.20) ?? activePrimary
      : activePrimary;

  return BoxDecoration(
    color: fill,
    borderRadius: BorderRadius.circular(20),
    border: Border.all(
      color: isDark ? activeContainer.withValues(alpha: 0.35) : activeContainer,
      width: 1.5,
    ),
    boxShadow: [
      BoxShadow(
        color: activePrimary.withValues(alpha: isDark ? 0.25 : 0.35),
        offset: const Offset(0, 4),
        blurRadius: 16,
        spreadRadius: 1,
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
