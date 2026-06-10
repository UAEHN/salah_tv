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

/// Outer widget: rebuilds only when [iqamaPrayerKey] or theme changes.
/// Countdown isolated in [_IqamaCountdownClock] to avoid recreating TextStyles
/// and the prayer-name Text on every 1-second tick.
class IqamaContent extends StatelessWidget {
  const IqamaContent({super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final iqamaPrayerKey = context.select<PrayerBloc, String>(
      (b) => b.state.iqamaPrayerKey,
    );
    final isDark = context.select<SettingsProvider, bool>(
      (p) => p.settings.isDarkMode,
    );
    final tc = ThemeColors.of(isDark);
    final screenH = MediaQuery.of(context).size.height;

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          l.iqamaAfterPrayer(localizedPrayerName(context, iqamaPrayerKey)),
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
            _IqamaCountdownClock(
              style: TextStyle(
                fontSize: screenH * 0.10,
                fontWeight: FontWeight.w700,
                color: tc.textPrimary,
                letterSpacing: 2,
              ),
              digitWidth: (screenH * 0.10) * 0.68,
              digitHeight: (screenH * 0.10) * 1.22,
            ),
          ],
        ),
      ],
    );
  }
}

class _IqamaCountdownClock extends StatelessWidget {
  final TextStyle style;
  final double digitWidth;
  final double digitHeight;

  const _IqamaCountdownClock({
    required this.style,
    required this.digitWidth,
    required this.digitHeight,
  });

  @override
  Widget build(BuildContext context) {
    final iqamaCountdown = context.select<PrayerBloc, Duration>(
      (b) => b.state.iqamaCountdown,
    );
    return FlipClock(
      text: formatIqamaCountdown(iqamaCountdown),
      style: style,
      digitWidth: digitWidth,
      digitHeight: digitHeight,
    );
  }
}
