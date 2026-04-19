import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ghasaq/l10n/app_localizations.dart';
import '../../../../../core/widgets/mobile/tour_target_keys.dart';
import '../../bloc/prayer_bloc.dart';
import '../../bloc/prayer_event.dart';
import '../../bloc/prayer_progress_calculator.dart' as progress_calc;
import '../../bloc/prayer_state.dart';
import 'mobile_hero_helpers.dart';
import 'mobile_hero_countdown.dart';
import 'mobile_hero_hijri_row.dart';

/// Coordinator widget for the hero section: countdown + date nav.
///
/// Split into two child stateless widgets so that date navigation
/// (which only changes on user input) does not rebuild every tick alongside
/// the countdown.
class MobileHeroCard extends StatelessWidget {
  const MobileHeroCard({super.key});

  @override
  Widget build(BuildContext context) {
    final tourKeys = TourTargetKeysProvider.maybeOf(context);

    return Column(
      children: [
        const _MobileHeroCountdownSection(),
        const SizedBox(height: 16),
        KeyedSubtree(
          key: tourKeys?.dateNavigator,
          child: const _MobileHeroDateSection(),
        ),
      ],
    );
  }
}

class _MobileHeroCountdownSection extends StatelessWidget {
  const _MobileHeroCountdownSection();

  @override
  Widget build(BuildContext context) {
    // Countdown-only selector: rebuild once per tick (countdown changes)
    // without being coupled to unrelated state (adhan/quran flags, etc.).
    return BlocBuilder<PrayerBloc, PrayerState>(
      buildWhen: (prev, cur) =>
          prev.countdown != cur.countdown ||
          prev.nextPrayerKey != cur.nextPrayerKey ||
          prev.isCycleActive != cur.isCycleActive ||
          prev.isIqamaCountdown != cur.isIqamaCountdown ||
          prev.iqamaCountdown != cur.iqamaCountdown ||
          prev.iqamaPrayerKey != cur.iqamaPrayerKey ||
          prev.todayPrayers != cur.todayPrayers ||
          prev.now != cur.now,
      builder: (context, state) {
        final progress = progress_calc.countdownArcProgress(state);
        return MobileHeroCountdown(
          nextPrayerKey: state.nextPrayerKey,
          countdown: state.countdown,
          isCycleActive: state.isCycleActive,
          isIqamaCountdown: state.isIqamaCountdown,
          iqamaCountdown: state.iqamaCountdown,
          iqamaPrayerKey: state.iqamaPrayerKey,
          progress: progress,
        );
      },
    );
  }
}

class _MobileHeroDateSection extends StatelessWidget {
  const _MobileHeroDateSection();

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    // Date/navigation only — does not rebuild every tick.
    final data = context.select<PrayerBloc, (DateTime, bool, bool)>(
      (b) => (
        b.state.displayedDate,
        b.state.isViewingToday,
        b.state.isDateNavigationBusy,
      ),
    );
    final displayedDate = data.$1;
    final isViewingToday = data.$2;
    final isBusy = data.$3;
    return MobileHeroHijriRow(
      hijriDate: formatHijriDate(l, displayedDate),
      gregorianDate: formatGregorianDate(l, displayedDate),
      isViewingToday: isViewingToday,
      isBusy: isBusy,
      onPrevious: () =>
          context.read<PrayerBloc>().add(const PrayerDateChanged(-1)),
      onNext: () =>
          context.read<PrayerBloc>().add(const PrayerDateChanged(1)),
      onReset: () =>
          context.read<PrayerBloc>().add(const PrayerDateReset()),
    );
  }
}
