import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';

import 'package:ghasaq/core/app_colors.dart';
import 'package:ghasaq/core/localization/date_localizer.dart';
import 'package:ghasaq/features/prayer/presentation/bloc/prayer_bloc.dart';
import 'package:ghasaq/features/settings/presentation/settings_provider.dart';
import 'package:ghasaq/l10n/app_localizations.dart';
import 'classic_visuals.dart';

/// Hijri (primary) + Gregorian (secondary) date shown directly beneath the
/// classic clock. Selects only the day so it rebuilds on date change, not on
/// the clock's per-second tick.
class ClassicClockDate extends StatelessWidget {
  final AccentPalette palette;

  const ClassicClockDate({super.key, required this.palette});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final isDark = context.select<SettingsProvider, bool>(
      (p) => p.settings.isDarkMode,
    );
    final now = context.select(
      (PrayerBloc b) =>
          DateTime(b.state.now.year, b.state.now.month, b.state.now.day),
    );
    final vis = ClassicVisuals(ThemeColors.of(isDark), palette);
    final screenH = MediaQuery.of(context).size.height;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          formatHijriDateLocalized(l, now),
          textDirection: TextDirection.rtl,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: screenH * 0.030,
            fontWeight: FontWeight.w600,
            color: vis.fg,
          ),
        ),
        SizedBox(height: screenH * 0.006),
        Text(
          formatGregorianDateLocalized(l, now),
          textDirection: TextDirection.rtl,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: screenH * 0.021,
            fontWeight: FontWeight.w500,
            color: vis.fgSec,
          ),
        ),
      ],
    );
  }
}
