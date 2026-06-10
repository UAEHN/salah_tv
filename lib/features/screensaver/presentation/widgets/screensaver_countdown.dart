import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ghasaq/l10n/app_localizations.dart';

import '../../../../core/localization/prayer_name_localizer.dart';
import '../../../../core/time_formatters.dart';
import '../../../prayer/presentation/bloc/prayer_bloc.dart';

/// Bottom-corner "time until next prayer" for the screensaver so the core
/// prayer countdown stays glanceable while the times view is hidden. Reads the
/// PrayerBloc via the widget tree (the allowed cross-feature access). The
/// selector is scoped to (nextPrayerKey, countdown), so only this small widget
/// rebuilds at 1 Hz — the rest of the screensaver stays still.
class ScreensaverCountdown extends StatelessWidget {
  const ScreensaverCountdown({super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final data = context.select<PrayerBloc, (String, Duration)>(
      (b) => (b.state.nextPrayerKey, b.state.countdown),
    );
    final prayerKey = data.$1;
    final countdown = data.$2;
    if (prayerKey.isEmpty || countdown == Duration.zero) {
      return const SizedBox.shrink();
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          l.countdownNextPrayer(localizedPrayerName(context, prayerKey)),
          textDirection: TextDirection.rtl,
          style: TextStyle(
            fontSize: 18,
            color: Colors.white.withValues(alpha: 0.5),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          formatCountdown(countdown),
          style: TextStyle(
            fontSize: 30,
            fontWeight: FontWeight.w600,
            color: Colors.white.withValues(alpha: 0.78),
            letterSpacing: 1.5,
            // Fixed-width digits so the ticking seconds never shift the text —
            // matches every other countdown in the app (NextPrayerWidget etc.).
            fontFeatures: const [FontFeature.tabularFigures()],
          ),
        ),
      ],
    );
  }
}
