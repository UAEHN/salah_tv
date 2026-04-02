import 'prayer_state.dart';

double countdownArcProgress(PrayerState state) {
  if (state.isIqamaCountdown) return 1.0;

  final prayers = state.todayPrayers?.prayersOnly ?? const [];
  final nextPrayerKey = state.nextPrayerKey;
  if (prayers.isEmpty ||
      state.countdown == Duration.zero ||
      nextPrayerKey.isEmpty) {
    return 0.0;
  }

  final now = state.now;
  final nextTime = now.add(state.countdown);
  final nextIndex = prayers.indexWhere((prayer) => prayer.key == nextPrayerKey);
  if (nextIndex == -1) return 0.0;

  final previousTime = nextIndex == 0
      ? prayers.last.time.subtract(const Duration(days: 1))
      : prayers[nextIndex - 1].time;
  final total = nextTime.difference(previousTime).inSeconds;
  if (total <= 0) return 0.0;

  final elapsed = now.difference(previousTime).inSeconds;
  return (elapsed / total).clamp(0.0, 1.0);
}

double iqamaArcProgress(Duration remaining, int totalMinutes) {
  if (totalMinutes <= 0) return 0.0;
  final totalSeconds = totalMinutes * 60.0;
  final elapsed =
      totalSeconds - remaining.inSeconds.clamp(0, totalSeconds.toInt());
  return (elapsed / totalSeconds).clamp(0.0, 1.0);
}
