import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import '../../../../settings/presentation/settings_provider.dart';
import '../../bloc/prayer_bloc.dart';
import 'mobile_hero_helpers.dart';
import 'mobile_hero_countdown.dart';
import 'mobile_hero_hijri_row.dart';

class MobileHeroCard extends StatelessWidget {
  const MobileHeroCard({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<PrayerBloc>().state;
    final nextPrayerName = context.select((PrayerBloc b) => b.state.nextPrayerName);
    final countdown = context.select((PrayerBloc b) => b.state.countdown);
    final isCycleActive = context.select((PrayerBloc b) => b.state.isCycleActive);
    final isIqamaCountdown = context.select((PrayerBloc b) => b.state.isIqamaCountdown);
    final iqamaCountdown = context.select((PrayerBloc b) => b.state.iqamaCountdown);
    final iqamaPrayerName = context.select((PrayerBloc b) => b.state.iqamaPrayerName);
    final activeCyclePrayerKey = context.select((PrayerBloc b) => b.state.activeCyclePrayerKey);

    final iqamaDelays = context.select((SettingsProvider p) => p.settings.iqamaDelays);
    final iqamaDelayMinutes = iqamaDelays[activeCyclePrayerKey] ?? 10;

    final progress = countdownArcProgress(state);
    final iqamaProgress = iqamaArcProgress(iqamaCountdown, iqamaDelayMinutes);

    return Column(
      children: [
        MobileHeroCountdown(
          nextPrayerName: nextPrayerName,
          countdown: countdown,
          isCycleActive: isCycleActive,
          isIqamaCountdown: isIqamaCountdown,
          iqamaCountdown: iqamaCountdown,
          iqamaPrayerName: iqamaPrayerName,
          progress: progress,
          iqamaProgress: iqamaProgress,
        ),
        const SizedBox(height: 24),
        MobileHeroHijriRow(
          hijriDate: formatHijriDate(state.now),
        ),
      ],
    );
  }
}
