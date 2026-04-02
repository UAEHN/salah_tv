import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ghasaq/l10n/app_localizations.dart';
import '../../bloc/prayer_bloc.dart';
import '../../bloc/prayer_event.dart';
import '../../bloc/prayer_progress_calculator.dart' as progress_calc;
import 'mobile_hero_helpers.dart';
import 'mobile_hero_countdown.dart';
import 'mobile_hero_hijri_row.dart';

/// Coordinator widget for the hero section: countdown + date nav.
class MobileHeroCard extends StatelessWidget {
  const MobileHeroCard({super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final state = context.watch<PrayerBloc>().state;

    final progress = progress_calc.countdownArcProgress(state);

    return Column(
      children: [
        MobileHeroCountdown(
          nextPrayerKey: state.nextPrayerKey,
          countdown: state.countdown,
          isCycleActive: state.isCycleActive,
          isIqamaCountdown: state.isIqamaCountdown,
          iqamaCountdown: state.iqamaCountdown,
          iqamaPrayerKey: state.iqamaPrayerKey,
          progress: progress,
        ),
        const SizedBox(height: 16),
        MobileHeroHijriRow(
          hijriDate: formatHijriDate(l, state.displayedDate),
          gregorianDate: formatGregorianDate(l, state.displayedDate),
          isViewingToday: state.isViewingToday,
          isBusy: state.isDateNavigationBusy,
          onPrevious: () =>
              context.read<PrayerBloc>().add(const PrayerDateChanged(-1)),
          onNext: () =>
              context.read<PrayerBloc>().add(const PrayerDateChanged(1)),
          onReset: () =>
              context.read<PrayerBloc>().add(const PrayerDateReset()),
        ),
      ],
    );
  }
}
