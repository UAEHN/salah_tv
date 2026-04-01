import 'package:ghasaq/l10n/app_localizations.dart';

import '../../../../../core/localization/date_localizer.dart';

String formatHijriDate(AppLocalizations l, DateTime date) {
  return formatHijriDateLocalized(l, date);
}

String formatGregorianDate(AppLocalizations l, DateTime date) {
  return formatGregorianDateLocalized(l, date);
}

/// Progress for the prayer countdown arc.
/// 0.0 = just after the previous prayer, 1.0 = prayer time.
/// Uses prayersOnly to exclude sunrise from the reference point calculation.
double countdownArcProgress(dynamic state) {
  if (state.isIqamaCountdown as bool) return 1.0;
  final prayers = state.todayPrayers?.prayersOnly ?? [];
  final nextPrayerKey = state.nextPrayerKey as String? ?? '';
  if (prayers.isEmpty ||
      state.countdown == Duration.zero ||
      nextPrayerKey.isEmpty) {
    return 0.0;
  }
  final now = state.now as DateTime;
  final nextTime = now.add(state.countdown as Duration);
  final nextIndex = prayers.indexWhere((prayer) => prayer.key == nextPrayerKey);
  if (nextIndex == -1) return 0.0;
  final previousTime = nextIndex == 0
      ? prayers.last.time.subtract(const Duration(days: 1))
      : prayers[nextIndex - 1].time;
  if (previousTime == null) return 0.0;
  final total = nextTime.difference(previousTime).inSeconds;
  if (total <= 0) return 0.0;
  final elapsed = now.difference(previousTime).inSeconds;
  return (elapsed / total).clamp(0.0, 1.0);
}

/// Progress for the iqama countdown arc.
/// 0.0 = just started, 1.0 = iqama time.
double iqamaArcProgress(Duration remaining, int totalMinutes) {
  if (totalMinutes <= 0) return 0.0;
  final totalSeconds = totalMinutes * 60.0;
  final elapsed =
      totalSeconds - remaining.inSeconds.clamp(0, totalSeconds.toInt());
  return (elapsed / totalSeconds).clamp(0.0, 1.0);
}
