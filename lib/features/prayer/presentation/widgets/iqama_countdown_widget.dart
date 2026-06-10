import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ghasaq/l10n/app_localizations.dart';
import 'package:provider/provider.dart';

import '../../../../core/app_colors.dart';
import '../../../../core/localization/prayer_name_localizer.dart';
import '../../../../core/time_formatters.dart';
import '../../../settings/presentation/settings_provider.dart';
import '../bloc/prayer_bloc.dart';
import 'classic/classic_count_card.dart';
import 'classic/classic_visuals.dart';

/// Iqama countdown rendered in the classic count card — same chrome as the
/// next-prayer card so the transition between them is seamless. Digits +
/// progress are isolated so the card is not rebuilt up to ~1800 times during
/// a single iqama wait.
class IqamaCountdownWidget extends StatelessWidget {
  final AccentPalette palette;

  const IqamaCountdownWidget({super.key, required this.palette});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final data = context.select<PrayerBloc, (bool, String)>(
      (b) => (b.state.isIqamaCountdown, b.state.iqamaPrayerKey),
    );
    final isIqamaCountdown = data.$1;
    final iqamaPrayerKey = data.$2;
    final isDark = context.select<SettingsProvider, bool>(
      (p) => p.settings.isDarkMode,
    );
    final vis = ClassicVisuals(ThemeColors.of(isDark), palette);
    final screenH = MediaQuery.of(context).size.height;

    if (!isIqamaCountdown) return const SizedBox.shrink();

    final prayerName = localizedPrayerName(context, iqamaPrayerKey);
    final title = l.localeName == 'ar' ? 'باقي على إقامة' : 'Iqama in';
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
      big: _IqamaCountdownText(
        style: TextStyle(
          fontSize: countdownSize,
          fontWeight: FontWeight.w700,
          color: vis.countdownText,
          fontFeatures: const [FontFeature.tabularFigures()],
        ),
      ),
    );
  }
}

/// Rebuilds every second. Receives precomputed style from parent.
class _IqamaCountdownText extends StatelessWidget {
  final TextStyle style;

  const _IqamaCountdownText({required this.style});

  @override
  Widget build(BuildContext context) {
    final iqamaCountdown = context.select<PrayerBloc, Duration>(
      (b) => b.state.iqamaCountdown,
    );
    return Text(
      formatIqamaCountdown(iqamaCountdown),
      textDirection: TextDirection.ltr,
      style: style,
    );
  }
}
