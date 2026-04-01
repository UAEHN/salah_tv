import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ghasaq/l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import '../../../../settings/presentation/settings_provider.dart';
import '../../bloc/prayer_bloc.dart';
import '../../bloc/prayer_event.dart';
import 'mobile_hero_helpers.dart';
import 'mobile_hero_countdown.dart';
import 'mobile_hero_hijri_row.dart';

class MobileHeroCard extends StatelessWidget {
  const MobileHeroCard({super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final state = context.watch<PrayerBloc>().state;
    final nextPrayerKey = context.select(
      (PrayerBloc b) => b.state.nextPrayerKey,
    );
    final countdown = context.select((PrayerBloc b) => b.state.countdown);
    final isCycleActive = context.select(
      (PrayerBloc b) => b.state.isCycleActive,
    );
    final isIqamaCountdown = context.select(
      (PrayerBloc b) => b.state.isIqamaCountdown,
    );
    final iqamaCountdown = context.select(
      (PrayerBloc b) => b.state.iqamaCountdown,
    );
    final iqamaPrayerKey = context.select(
      (PrayerBloc b) => b.state.iqamaPrayerKey,
    );
    final activeCyclePrayerKey = context.select(
      (PrayerBloc b) => b.state.activeCyclePrayerKey,
    );
    final displayedDate = context.select(
      (PrayerBloc b) => b.state.displayedDate,
    );
    final isViewingToday = context.select(
      (PrayerBloc b) => b.state.isViewingToday,
    );
    final isDateNavigationBusy = context.select(
      (PrayerBloc b) => b.state.isDateNavigationBusy,
    );

    final iqamaDelays = context.select(
      (SettingsProvider p) => p.settings.iqamaDelays,
    );
    final iqamaDelayMinutes = iqamaDelays[activeCyclePrayerKey] ?? 10;

    final progress = countdownArcProgress(state);
    final iqamaProgress = iqamaArcProgress(iqamaCountdown, iqamaDelayMinutes);

    return Column(
      children: [
        MobileHeroCountdown(
          nextPrayerKey: nextPrayerKey,
          countdown: countdown,
          isCycleActive: isCycleActive,
          isIqamaCountdown: isIqamaCountdown,
          iqamaCountdown: iqamaCountdown,
          iqamaPrayerKey: iqamaPrayerKey,
          progress: progress,
          iqamaProgress: iqamaProgress,
        ),
        const SizedBox(height: 24),
        MobileHeroHijriRow(
          hijriDate: formatHijriDate(l, displayedDate),
          gregorianDate: formatGregorianDate(l, displayedDate),
          isViewingToday: isViewingToday,
          isBusy: isDateNavigationBusy,
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
