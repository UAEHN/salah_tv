import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ghasaq/l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import '../../../../core/app_colors.dart';
import '../../../../core/localization/prayer_name_localizer.dart';
import '../../../../core/time_formatters.dart';
import '../bloc/prayer_bloc.dart';
import '../../../settings/presentation/settings_provider.dart';

/// Outer widget: rebuilds only when [nextPrayerKey] or theme changes.
/// Countdown digits isolated in [_ContentCountdownClock] to avoid recreating
/// the AnimatedSwitcher, TextStyles, and Icon on every 1-second tick.
class NextPrayerContent extends StatelessWidget {
  const NextPrayerContent({super.key});

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

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          l.nextPrayerLabel,
          style: TextStyle(
            fontSize: screenH * 0.045,
            fontWeight: FontWeight.w400,
            color: tc.textSecondary,
          ),
        ),
        SizedBox(height: screenH * 0.005),
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
            localizedPrayerName(context, nextPrayerKey),
            key: ValueKey(nextPrayerKey),
            style: TextStyle(
              fontSize: screenH * 0.12,
              fontWeight: FontWeight.w700,
              color: tc.textPrimary,
              height: 1.1,
            ),
          ),
        ),
        SizedBox(height: screenH * 0.015),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.timer_outlined,
              color: tc.textSecondary,
              size: screenH * 0.05,
            ),
            const SizedBox(width: 12),
            // RepaintBoundary prevents the per-second flip animation from
            // invalidating the hero card's gradient/border layer.
            RepaintBoundary(
              child: _ContentCountdownClock(
                style: TextStyle(
                  fontSize: screenH * 0.10,
                  fontWeight: FontWeight.w600,
                  color: tc.textPrimary,
                  letterSpacing: 2,
                  // Tabular figures keep every digit at the same advance
                  // width so the countdown text doesn't shift left/right
                  // each tick as narrow glyphs (1) replace wide ones (0/8).
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
                digitWidth: (screenH * 0.10) * 0.68,
                digitHeight: (screenH * 0.10) * 1.22,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _ContentCountdownClock extends StatelessWidget {
  final TextStyle style;
  final double digitWidth;
  final double digitHeight;

  const _ContentCountdownClock({
    required this.style,
    required this.digitWidth,
    required this.digitHeight,
  });

  @override
  Widget build(BuildContext context) {
    final countdown = context.select<PrayerBloc, Duration>(
      (b) => b.state.countdown,
    );
    // Isolation test: plain text, no flip animation, no per-frame rebuild.
    return Text(
      formatCountdown(countdown),
      style: style,
      textDirection: TextDirection.ltr,
    );
  }
}
