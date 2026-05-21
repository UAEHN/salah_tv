import 'prayer_state.dart';

/// Last-hour progress: matches the bento hero's linear bar so both surfaces
/// fill in lockstep. More than an hour away → a tiny anchor sliver (5%);
/// within the last hour → linearly fills 0 → 100% as the countdown elapses.
double countdownArcProgress(PrayerState state) {
  if (state.isIqamaCountdown) return 1.0;
  final countdown = state.countdown;
  if (countdown.isNegative) return 1.0;
  const oneHour = Duration(hours: 1);
  if (countdown >= oneHour) return 0.05;
  return 1.0 - (countdown.inSeconds.clamp(0, 3600) / 3600.0);
}

double iqamaArcProgress(Duration remaining, int totalMinutes) {
  if (totalMinutes <= 0) return 0.0;
  final totalSeconds = totalMinutes * 60.0;
  final elapsed =
      totalSeconds - remaining.inSeconds.clamp(0, totalSeconds.toInt());
  return (elapsed / totalSeconds).clamp(0.0, 1.0);
}
