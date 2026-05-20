import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ghasaq/l10n/app_localizations.dart';
import 'package:provider/provider.dart';

import '../../../../core/app_colors.dart';
import '../../../../core/localization/prayer_name_localizer.dart';
import '../../../../core/time_formatters.dart';
import '../../../../core/widgets/flip_clock.dart';
import '../../../settings/presentation/settings_provider.dart';
import '../bloc/prayer_bloc.dart';

/// Outer widget: rebuilds only when [nextPrayerKey] or [isDarkMode] changes.
/// The countdown digits are isolated in [_CountdownClock] which rebuilds every
/// second — this prevents the Container, Border, TextStyles, Icon, and prayer
/// name Text from being recreated 3 600 times/hour.
class NextPrayerWidget extends StatelessWidget {
  final AccentPalette palette;

  const NextPrayerWidget({super.key, required this.palette});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final nextPrayerKey = context.select<PrayerBloc, String>(
      (b) => b.state.nextPrayerKey,
    );
    final isDark = context.select<SettingsProvider, bool>(
      (p) => p.settings.isDarkMode,
    );
    final tc = ThemeColors.of(isDark);
    final screenH = MediaQuery.of(context).size.height;
    final screenW = MediaQuery.of(context).size.width;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: screenW * 0.03,
        vertical: screenH * 0.025,
      ),
      decoration: BoxDecoration(
        // Light: opaque to detach from the warm parchment background.
        // Dark: transparent so the dark gradient bleeds through naturally.
        color: isDark ? Colors.transparent : tc.bgSurface,
        border: Border.all(
          color: palette.primary.withValues(alpha: 0.55),
          width: 1.5,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            l.nextPrayerLabel,
            style: TextStyle(
              fontSize: screenH * 0.040,
              fontWeight: FontWeight.w400,
              color: tc.textSecondary,
            ),
          ),
          Text(
            localizedPrayerName(context, nextPrayerKey),
            style: TextStyle(
              fontSize: screenH * 0.09,
              fontWeight: FontWeight.w600,
              color: tc.textPrimary,
              height: 1.1,
            ),
          ),
          SizedBox(height: screenH * 0.01),
          Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.timer_outlined,
                color: tc.textSecondary,
                size: screenH * 0.035,
              ),
              SizedBox(width: screenW * 0.008),
              _CountdownClock(
                style: TextStyle(
                  fontSize: screenH * 0.060,
                  fontWeight: FontWeight.w600,
                  color: tc.textPrimary,
                ),
                digitWidth: screenH * 0.060 * 0.68,
                digitHeight: screenH * 0.060 * 1.22,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Rebuilds every second (countdown changes). Receives precomputed style from
/// parent so it does not re-read settings or screenH on every tick.
class _CountdownClock extends StatelessWidget {
  final TextStyle style;
  final double digitWidth;
  final double digitHeight;

  const _CountdownClock({
    required this.style,
    required this.digitWidth,
    required this.digitHeight,
  });

  @override
  Widget build(BuildContext context) {
    final countdown = context.select<PrayerBloc, Duration>(
      (b) => b.state.countdown,
    );
    return FlipClock(
      text: formatCountdown(countdown),
      style: style,
      digitWidth: digitWidth,
      digitHeight: digitHeight,
    );
  }
}
