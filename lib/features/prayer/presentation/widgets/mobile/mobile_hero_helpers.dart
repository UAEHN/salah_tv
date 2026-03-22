import 'package:hijri/hijri_calendar.dart';

const _hijriMonths = [
  'مُحَرَّم',
  'صَفَر',
  'رَبِيع الأَوَّل',
  'رَبِيع الثَّانِي',
  'جُمَادَى الأُولَى',
  'جُمَادَى الآخِرَة',
  'رَجَب',
  'شَعْبَان',
  'رَمَضَان',
  'شَوَّال',
  'ذُو القَعْدَة',
  'ذُو الحِجَّة',
];

const _dayNames = [
  'الاثنين',
  'الثلاثاء',
  'الأربعاء',
  'الخميس',
  'الجمعة',
  'السبت',
  'الأحد',
];

String formatHijriDate(DateTime date) {
  final hijri = HijriCalendar.fromDate(date);
  final month = (hijri.hMonth >= 1 && hijri.hMonth <= 12)
      ? _hijriMonths[hijri.hMonth - 1]
      : hijri.longMonthName;
  return '${_dayNames[date.weekday - 1]}، ${hijri.hDay} $month ${hijri.hYear} هـ';
}

/// Progress for the prayer countdown arc (0.0 = just after last prayer, 1.0 = prayer time).
/// Uses prayersOnly to exclude sunrise from the reference point calculation.
double countdownArcProgress(dynamic state) {
  if (state.isIqamaCountdown as bool) return 1.0; // arc stays full during iqama
  final prayers = state.todayPrayers?.prayersOnly ?? [];
  if (prayers.isEmpty || state.countdown == Duration.zero) return 0.0;
  final now = state.now as DateTime;
  final nextTime = now.add(state.countdown as Duration);
  DateTime? previousTime;
  for (final prayer in prayers) {
    if (!(prayer.time as DateTime).isAfter(now)) {
      previousTime = prayer.time as DateTime;
    }
  }
  if (previousTime == null) return 0.0;
  final total = nextTime.difference(previousTime).inSeconds;
  if (total <= 0) return 0.0;
  return (now.difference(previousTime).inSeconds / total).clamp(0.0, 1.0);
}

/// Progress for the iqama countdown arc (0.0 = just started, 1.0 = iqama time).
double iqamaArcProgress(Duration remaining, int totalMinutes) {
  if (totalMinutes <= 0) return 0.0;
  final totalSeconds = totalMinutes * 60.0;
  final elapsed = totalSeconds - remaining.inSeconds.clamp(0, totalSeconds.toInt());
  return (elapsed / totalSeconds).clamp(0.0, 1.0);
}
