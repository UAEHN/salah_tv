import 'package:flutter/material.dart';

class MobileColors {
  MobileColors._();

  // ✨ Accent palette - Ghasaq Night & Gold ✨
  static const Color primary = Color(0xFFD4A843); // Ghasaq Gold
  static const Color primaryContainer = Color(0xFFE8C77A); // Soft Gold
  static const Color secondary = Color(0xFFE67E22); // Warm Sunset Orange
  static const Color iqamaAccent = Color(
    0xFFE74C3C,
  ); // Amber/Red — iqama countdown phase

  static bool isDark(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark;
  }

  static Color background(BuildContext context) {
    return isDark(context) ? const Color(0xFF050A18) : const Color(0xFFF9F6F0);
  }

  static Color cardColor(BuildContext context) {
    return isDark(context) ? const Color(0xFF0F1B33) : const Color(0xFFFFFFFF);
  }

  static Color onSurface(BuildContext context) {
    return isDark(context) ? Colors.white : const Color(0xFF1A1A24);
  }

  static Color onSurfaceMuted(BuildContext context) {
    return isDark(context) ? const Color(0x99FFFFFF) : const Color(0xFF5C6370);
  }

  static Color onSurfaceFaint(BuildContext context) {
    return isDark(context) ? const Color(0x55FFFFFF) : const Color(0xFFB0B5C0);
  }

  static Color border(BuildContext context) {
    return isDark(context)
        ? Colors.white.withValues(alpha: 0.08)
        : const Color(0xFF1A1A24).withValues(alpha: 0.08);
  }

  static Color shadowDark(BuildContext context) {
    return isDark(context)
        ? Colors.black.withValues(alpha: 0.40)
        : const Color(0xFF1A1A24).withValues(alpha: 0.06);
  }

  static List<Color> homeGradient(BuildContext context) {
    return isDark(context)
        ? const [
            Color(0xFF0B142B), // Dark navy top
            Color(0xFF050A18), // Base night
            Color(0xFF050A18),
            Color(0xFF03050C), // Near black bottom
          ]
        : const [
            Color(0xFFFFFDF8),
            Color(0xFFF9F6F0),
            Color(0xFFF9F6F0),
            Color(0xFFF2ECE1),
          ];
  }

  static List<Color> qiblaGradient(BuildContext context) {
    return isDark(context)
        ? const [Color(0xFF0A0F1E), Color(0xFF050A18), Color(0xFF050A18)]
        : const [Color(0xFFFFFDF8), Color(0xFFF9F6F0), Color(0xFFF2ECE1)];
  }
}

class MobileTextStyles {
  MobileTextStyles._();

  static TextStyle displayLg(BuildContext context) => TextStyle(
    fontFamily: 'Cairo',
    fontSize: 56,
    fontWeight: FontWeight.w800,
    color: MobileColors.onSurface(context),
    height: 1.0,
    letterSpacing: -1,
  );

  static TextStyle headlineMd(BuildContext context) => TextStyle(
    fontFamily: 'Cairo',
    fontSize: 18,
    fontWeight: FontWeight.w700,
    color: MobileColors.onSurface(context),
  );

  static TextStyle titleMd(BuildContext context) => TextStyle(
    fontFamily: 'Cairo',
    fontSize: 22,
    fontWeight: FontWeight.w700,
    color: MobileColors.onSurface(context),
  );

  static TextStyle bodyMd(BuildContext context) => TextStyle(
    fontFamily: 'Cairo',
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: MobileColors.onSurfaceMuted(context),
  );

  static TextStyle labelSm(BuildContext context) => TextStyle(
    fontFamily: 'Cairo',
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
