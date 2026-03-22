import 'package:flutter/material.dart';

class MobileColors {
  MobileColors._();

  // ── Accent palette — Celestial Blue ──────────────────────────────────────
  static const Color primary = Color(0xFF2563EB);          // blue-600
  static const Color primaryContainer = Color(0xFF60A5FA); // blue-400
  static const Color secondary = Color(0xFF7C3AED);        // violet-600
  static const Color iqamaAccent = Color(0xFFFFB74D);      // amber — iqama countdown phase

  static bool isDark(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark;
  }

  static Color background(BuildContext context) {
    return isDark(context) ? const Color(0xFF080A12) : const Color(0xFFEEF3FF);
  }

  static Color cardColor(BuildContext context) {
    return isDark(context) ? const Color(0xFF0D1220) : const Color(0xFFFFFFFF);
  }

  static Color onSurface(BuildContext context) {
    return isDark(context) ? Colors.white : const Color(0xFF0F172A);
  }

  static Color onSurfaceMuted(BuildContext context) {
    return isDark(context) ? const Color(0x99FFFFFF) : const Color(0xFF4B6080);
  }

  static Color onSurfaceFaint(BuildContext context) {
    return isDark(context) ? const Color(0x55FFFFFF) : const Color(0xFFB8C8E0);
  }

  static Color border(BuildContext context) {
    return isDark(context)
        ? Colors.white.withValues(alpha: 0.07)
        : const Color(0xFF0F172A).withValues(alpha: 0.08);
  }

  static Color shadowDark(BuildContext context) {
    return isDark(context)
        ? Colors.black.withValues(alpha: 0.35)
        : const Color(0xFF0F172A).withValues(alpha: 0.08);
  }

  static List<Color> homeGradient(BuildContext context) {
    return isDark(context)
        ? const [
            Color(0xFF0D1428),  // blue-navy at top
            Color(0xFF080A12),  // base background
            Color(0xFF080A12),
            Color(0xFF06060F),  // near-black at bottom
          ]
        : const [
            Color(0xFFE8F0FF),
            Color(0xFFEEF3FF),
            Color(0xFFEEF3FF),
            Color(0xFFE4EDFF),
          ];
  }

  static List<Color> qiblaGradient(BuildContext context) {
    return isDark(context)
        ? const [Color(0xFF0A0E1E), Color(0xFF080A12), Color(0xFF080A12)]
        : const [Color(0xFFECF2FF), Color(0xFFEEF3FF), Color(0xFFE8F0FF)];
  }
}

class MobileTextStyles {
  MobileTextStyles._();

  static TextStyle displayLg(BuildContext context) => TextStyle(
    fontFamily: 'Rubik',
    fontSize: 56,
    fontWeight: FontWeight.w800,
    color: MobileColors.onSurface(context),
    height: 1.0,
    letterSpacing: -1,
  );

  static TextStyle headlineMd(BuildContext context) => TextStyle(
    fontFamily: 'Rubik',
    fontSize: 18,
    fontWeight: FontWeight.w700,
    color: MobileColors.onSurface(context),
  );

  static TextStyle titleMd(BuildContext context) => TextStyle(
    fontFamily: 'Rubik',
    fontSize: 22,
    fontWeight: FontWeight.w700,
    color: MobileColors.onSurface(context),
  );

  static TextStyle bodyMd(BuildContext context) => TextStyle(
    fontFamily: 'Rubik',
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: MobileColors.onSurfaceMuted(context),
  );

  static TextStyle labelSm(BuildContext context) => TextStyle(
    fontFamily: 'Rubik',
    fontSize: 12,
    fontWeight: FontWeight.w700,
    color: MobileColors.onSurfaceMuted(context),
  );
}

class MobileShadows {
  MobileShadows._();

  static List<BoxShadow> sleekCard(BuildContext context) => [
    BoxShadow(
      color: MobileColors.shadowDark(context),
      offset: const Offset(0, 8),
      blurRadius: 20,
    ),
  ];
}

class MobileDecorations {
  MobileDecorations._();

  static BoxDecoration pillCard(BuildContext context) => BoxDecoration(
    color: MobileColors.cardColor(
      context,
    ).withValues(alpha: MobileColors.isDark(context) ? 0.55 : 0.9),
    borderRadius: BorderRadius.circular(24),
    border: Border.all(color: MobileColors.border(context), width: 1),
    boxShadow: MobileShadows.sleekCard(context),
  );

  static BoxDecoration activePillCard(BuildContext context) => BoxDecoration(
    gradient: const LinearGradient(
      begin: Alignment.centerRight,
      end: Alignment.centerLeft,
      colors: [MobileColors.primary, MobileColors.primaryContainer],
    ),
    borderRadius: BorderRadius.circular(24),
    boxShadow: [
      BoxShadow(
        color: MobileColors.primaryContainer.withValues(
          alpha: MobileColors.isDark(context) ? 0.35 : 0.22,
        ),
        offset: const Offset(0, 8),
        blurRadius: 24,
      ),
    ],
  );
}
