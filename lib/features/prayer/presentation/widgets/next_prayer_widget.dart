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
import 'classic/classic_count_card.dart';
import 'classic/classic_visuals.dart';

/// Next-prayer countdown rendered in the classic count card. The eyebrow reads
/// "time remaining for the [prayerName] prayer". Countdown digits are isolated
/// so the card chrome is not rebuilt every second.
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
    final vis = ClassicVisuals(ThemeColors.of(isDark), palette);
    final screenH = MediaQuery.of(context).size.height;
    final prayerName = localizedPrayerName(context, nextPrayerKey);
    final title = l.localeName == 'ar' ? 'باقي على صلاة' : 'Next prayer in';
    final countdownSize = screenH * 0.106;

    return ClassicCountCard(
      vis: vis,
      eyebrow: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: screenH * 0.032,
              fontWeight: FontWeight.w600,
              color: vis.fgSec,
            ),
          ),
          SizedBox(height: screenH * 0.006),
          Text(
            prayerName,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: screenH * 0.054,
              fontWeight: FontWeight.w900,
              color: vis.countdownText,
              height: 1.0,
            ),
          ),
        ],
      ),
      big: _CountdownClock(
        style: TextStyle(
          fontSize: countdownSize,
          fontWeight: FontWeight.w700,
          color: vis.countdownText,
          fontFeatures: const [FontFeature.tabularFigures()],
        ),
        digitWidth: countdownSize * 0.62,
        digitHeight: countdownSize * 1.16,
      ),
    );
  }
}

/// Rebuilds every second. Receives precomputed style from parent.
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
