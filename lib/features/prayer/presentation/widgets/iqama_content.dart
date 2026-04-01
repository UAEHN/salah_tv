import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ghasaq/l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import '../../../../core/app_colors.dart';
import '../../../../core/localization/prayer_name_localizer.dart';
import '../../../../core/time_formatters.dart';
import '../../../../core/widgets/flip_clock.dart';
import '../bloc/prayer_bloc.dart';
import '../../../settings/presentation/settings_provider.dart';

class IqamaContent extends StatelessWidget {
  const IqamaContent({super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final prayerState = context.watch<PrayerBloc>().state;
    final settings = context.watch<SettingsProvider>().settings;
    final palette = getThemePalette(settings.themeColorKey);
    final tc = ThemeColors.of(settings.isDarkMode);
    final screenH = MediaQuery.of(context).size.height;

    final countdownStyle = TextStyle(
      fontSize: screenH * 0.10,
      fontWeight: FontWeight.w700,
      color: tc.textPrimary,
      letterSpacing: 2,
      shadows: [
        Shadow(color: palette.glow.withValues(alpha: 0.35), blurRadius: 12),
      ],
    );

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          l.iqamaAfterPrayer(
            localizedPrayerName(context, prayerState.iqamaPrayerKey),
          ),
          style: TextStyle(
            fontSize: screenH * 0.048,
            fontWeight: FontWeight.w500,
            color: tc.textSecondary,
          ),
        ),
        SizedBox(height: screenH * 0.015),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.access_time_filled_rounded,
              color: tc.textSecondary,
              size: screenH * 0.050,
            ),
            const SizedBox(width: 12),
            FlipClock(
              text: formatIqamaCountdown(prayerState.iqamaCountdown),
              style: countdownStyle,
              digitWidth: (screenH * 0.10) * 0.68,
              digitHeight: (screenH * 0.10) * 1.22,
            ),
          ],
        ),
      ],
    );
  }
}
