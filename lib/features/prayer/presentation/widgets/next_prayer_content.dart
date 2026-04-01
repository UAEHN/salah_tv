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

class NextPrayerContent extends StatelessWidget {
  const NextPrayerContent({super.key});

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
      fontWeight: FontWeight.w600,
      color: tc.textPrimary,
      letterSpacing: 2,
    );

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Label for remaining time until adhan
        Text(
          l.nextPrayerLabel,
          style: TextStyle(
            fontSize: screenH * 0.045,
            fontWeight: FontWeight.w400,
            color: tc.textSecondary,
          ),
        ),
        SizedBox(height: screenH * 0.005),
        // Prayer name
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 400),
          transitionBuilder: (child, animation) => FadeTransition(
            opacity: animation,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0, 0.3),
                end: Offset.zero,
              ).animate(animation),
              child: child,
            ),
          ),
          child: Text(
            localizedPrayerName(context, prayerState.nextPrayerKey),
            key: ValueKey(prayerState.nextPrayerKey),
            style: TextStyle(
              fontSize: screenH * 0.12,
              fontWeight: FontWeight.w700,
              color: tc.textPrimary,
              height: 1.1,
              shadows: [
                Shadow(
                  color: palette.glow.withValues(alpha: 0.4),
                  blurRadius: 18,
                ),
              ],
            ),
          ),
        ),
        SizedBox(height: screenH * 0.015),
        // Countdown
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.timer_outlined,
              color: tc.textSecondary,
              size: screenH * 0.05,
            ),
            const SizedBox(width: 12),
            FlipClock(
              text: formatCountdown(prayerState.countdown),
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
