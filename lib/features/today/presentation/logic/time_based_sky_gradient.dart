import 'package:flutter/material.dart';

/// Pure helper — picks a 3-stop "sky" gradient that matches the local hour.
/// Each band sits next to the next so the screen reads as a continuum across
/// the day. Colors are intentionally muted (10–25% saturation) so foreground
/// tiles stay legible.
///
/// Bands (24h local):
///   • 03:00–05:30  pre-fajr blue-violet
///   • 05:30–07:30  fajr / dawn rose
///   • 07:30–11:00  morning soft cyan
///   • 11:00–15:00  noon clear blue
///   • 15:00–17:30  afternoon warm amber
///   • 17:30–19:30  maghrib sunset
///   • 19:30–21:30  isha indigo
///   • 21:30–03:00  deep night
List<Color> skyGradientForHour(int hour, {bool isDark = false}) {
  if (hour >= 3 && hour < 5) return const _PreFajr().colors;
  if (hour >= 5 && hour < 7) return const _Dawn().colors;
  if (hour >= 7 && hour < 11) return const _Morning().colors;
  if (hour >= 11 && hour < 15) return const _Noon().colors;
  if (hour >= 15 && hour < 17) return const _Afternoon().colors;
  if (hour >= 17 && hour < 19) return const _Sunset().colors;
  if (hour >= 19 && hour < 21) return const _Isha().colors;
  return const _Night().colors;
}

/// True when the time-of-day sky band is dark enough that white text wins
/// over dark text. Drives the adaptive surface/foreground colors used by
/// `bento_tile` and friends. Boundaries match `skyGradientForHour`:
///   • pre-fajr (3-5)  → dark
///   • dawn / morning / noon / afternoon / sunset → light/medium
///   • isha (19-21)    → dark
///   • night (21-3)    → dark
bool isDarkSkyHour(int hour) {
  if (hour >= 3 && hour < 5) return true;        // pre-fajr violet
  if (hour >= 19) return true;                    // isha + night
  if (hour < 3) return true;                      // late night
  return false;                                   // dawn → sunset
}

/// Premium night gradient used when the user explicitly opts into the dark
/// theme (independent of the local hour). Deep blue → muted violet → near
/// black, evoking laylat-al-qadr without leaning on the time-of-day cycle.
const List<Color> kPremiumNightGradient = [
  Color(0xFF0F1729),
  Color(0xFF1A1429),
  Color(0xFF050410),
];

/// Soft warm light background — used in light mode instead of the
/// time-of-day gradient. Avoids stark white so tiles read clearly without
/// the screen feeling clinical; the warm beige base also pairs well with
/// any accent colour the user picks from the theme palette.
const List<Color> kSoftLightGradient = [
  Color(0xFFF7F1E6),
  Color(0xFFF1E9D9),
  Color(0xFFEADFC8),
];

abstract class _SkyBand {
  const _SkyBand();
  List<Color> get colors;
}

class _PreFajr extends _SkyBand {
  const _PreFajr();
  @override
  List<Color> get colors => const [
        Color(0xFF1A1B3A),
        Color(0xFF2E2A4D),
        Color(0xFF453B62),
      ];
}

class _Dawn extends _SkyBand {
  const _Dawn();
  @override
  List<Color> get colors => const [
        Color(0xFFFFB088),
        Color(0xFFE490A6),
        Color(0xFF7A6BAA),
      ];
}

class _Morning extends _SkyBand {
  const _Morning();
  @override
  List<Color> get colors => const [
        Color(0xFFE8F4FA),
        Color(0xFFB7D4EA),
        Color(0xFF7AA9CD),
      ];
}

class _Noon extends _SkyBand {
  const _Noon();
  @override
  List<Color> get colors => const [
        Color(0xFFC9E4F8),
        Color(0xFF7FB6E0),
        Color(0xFF4A8AB8),
      ];
}

class _Afternoon extends _SkyBand {
  const _Afternoon();
  @override
  List<Color> get colors => const [
        Color(0xFFFFD7A8),
        Color(0xFFE8A87C),
        Color(0xFF9D6B5C),
      ];
}

class _Sunset extends _SkyBand {
  const _Sunset();
  @override
  List<Color> get colors => const [
        Color(0xFFFF9966),
        Color(0xFFD46A6A),
        Color(0xFF6B3E70),
      ];
}

class _Isha extends _SkyBand {
  const _Isha();
  @override
  List<Color> get colors => const [
        Color(0xFF2E2756),
        Color(0xFF1F1B3D),
        Color(0xFF12102A),
      ];
}

class _Night extends _SkyBand {
  const _Night();
  @override
  List<Color> get colors => const [
        Color(0xFF0B1027),
        Color(0xFF050818),
        Color(0xFF02030A),
      ];
}
