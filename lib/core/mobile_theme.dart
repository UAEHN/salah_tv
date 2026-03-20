import 'package:flutter/material.dart';

/// Design tokens — "Desert Oasis" dark theme (prayer_times.html).
/// Used exclusively by the mobile UI. TV theme stays in app_colors.dart.
class MobileColors {
  MobileColors._();

  static const Color background = Color(0xFF1D1C16);      // deep charcoal
  static const Color cardColor = Color(0xFF2A2922);       // elevated surface
  static const Color primary = Color(0xFF006A62);         // oasis teal
  static const Color primaryContainer = Color(0xFF40E0D0); // turquoise accent
  static const Color secondary = Color(0xFF9F402D);       // terracotta
  static const Color onSurface = Colors.white;
  static const Color onSurfaceMuted = Color(0x99FFFFFF);  // white 60%
  static const Color onSurfaceFaint = Color(0x66FFFFFF);  // white 40%
}

class MobileTextStyles {
  MobileTextStyles._();

  static const TextStyle displayLg = TextStyle(
    fontFamily: 'Beiruti',
    fontSize: 56,
    fontWeight: FontWeight.w800,
    color: MobileColors.primaryContainer,
    height: 1.0,
    letterSpacing: -1,
  );

  static const TextStyle headlineMd = TextStyle(
    fontFamily: 'Beiruti',
    fontSize: 18,
    fontWeight: FontWeight.w700,
    color: MobileColors.onSurface,
  );

  static const TextStyle titleMd = TextStyle(
    fontFamily: 'Cairo',
    fontSize: 22,
    fontWeight: FontWeight.w600,
    color: MobileColors.onSurface,
  );

  static const TextStyle bodyMd = TextStyle(
    fontFamily: 'Cairo',
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: MobileColors.onSurfaceMuted,
  );

  static const TextStyle labelSm = TextStyle(
    fontFamily: 'Cairo',
    fontSize: 10,
    fontWeight: FontWeight.w700,
    color: MobileColors.onSurfaceMuted,
    letterSpacing: 1.0,
  );
}

/// Neomorphic dark shadows — deep shadow below, faint highlight above.
class MobileShadows {
  MobileShadows._();

  static const List<BoxShadow> card = [
    BoxShadow(
      color: Color(0x661D1C16),
      offset: Offset(8, 8),
      blurRadius: 16,
    ),
    BoxShadow(
      color: Color(0x05FFFFFF),
      offset: Offset(-8, -8),
      blurRadius: 16,
    ),
  ];
}

class MobileDecorations {
  MobileDecorations._();

  /// Pill-shaped inactive prayer card.
  static BoxDecoration pillCard() => BoxDecoration(
        color: MobileColors.background,
        borderRadius: BorderRadius.circular(50),
        boxShadow: MobileShadows.card,
      );

  /// Gradient active prayer card.
  static BoxDecoration activePillCard() => const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [MobileColors.primary, MobileColors.primaryContainer],
        ),
        borderRadius: BorderRadius.all(Radius.circular(50)),
        boxShadow: [
          BoxShadow(
            color: Color(0x4D006A62),
            offset: Offset(0, 8),
            blurRadius: 20,
          ),
        ],
      );
}
