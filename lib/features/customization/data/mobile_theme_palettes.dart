import 'package:flutter/material.dart';
import '../../../core/app_colors.dart';

/// Extra accent palettes available **only on the mobile build**.
///
/// Kept separate from [kThemePalettes] in `core/app_colors.dart` because the
/// TV settings UI (`simple_sections.dart`) consumes that map directly and we
/// must not surface mobile-only themes there. Mobile screens use
/// [getMobileThemePalette] / [kAllMobilePalettes] which merge both sets.
const Map<String, AccentPalette> kMobileExtraPalettes = {
  'desert_dawn': AccentPalette(
    primary: Color(0xFFE8804B),
    secondary: Color(0xFF6B5B95),
    glow: Color(0x40E8804B),
  ),
  'paradise_sea': AccentPalette(
    primary: Color(0xFF20A39E),
    secondary: Color(0xFF4FC3C0),
    glow: Color(0x4020A39E),
  ),
};

/// Set of legacy theme keys that exist in [kThemePalettes] (TV-shared).
/// Used by the catalog to mark them with `isLegacy: true`.
const Set<String> kLegacyThemeKeys = {
  'green',
  'teal',
  'gold',
  'blue',
  'purple',
};

/// Combined palette map — TV-shared + mobile-exclusive themes.
/// **Use only from mobile-only code paths.**
Map<String, AccentPalette> get kAllMobilePalettes => {
  ...kThemePalettes,
  ...kMobileExtraPalettes,
};

/// Mobile-aware palette resolver. Falls back to `green` if [key] is unknown.
/// Used in `app.dart` when `isTV == false`.
AccentPalette getMobileThemePalette(String key) =>
    kAllMobilePalettes[key] ?? kThemePalettes['green']!;
