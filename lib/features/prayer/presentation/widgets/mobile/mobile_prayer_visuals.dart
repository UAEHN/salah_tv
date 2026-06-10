import 'package:flutter/material.dart';

import '../../../../../core/mobile_theme.dart';

const mobilePrayerIcons = <String, IconData>{
  'fajr': Icons.wb_twilight_rounded,
  'dhuhr': Icons.wb_sunny_rounded,
  'asr': Icons.brightness_medium_rounded,
  'maghrib': Icons.nights_stay_rounded,
  'isha': Icons.bedtime_rounded,
};

/// Per-prayer accent pair `(bright, deep)` derived from the active theme
/// palette so a theme switch propagates to prayer icons and the hero
/// countdown card.
///
/// The [prayerKey] is accepted to keep the call site stable; we currently
/// return the same `(primaryContainer, primary)` for every prayer, but the
/// hook lets us tint individual prayers later without touching consumers.
(Color, Color) mobilePrayerAccentPair(BuildContext context, String prayerKey) {
  return (
    MobileColors.activePrimaryContainer(context),
    MobileColors.activePrimary(context),
  );
}
