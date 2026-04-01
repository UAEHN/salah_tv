import 'package:hijri/hijri_calendar.dart';
import 'package:ghasaq/l10n/app_localizations.dart';

String localizedWeekdayName(AppLocalizations l, int weekday) {
  switch (weekday) {
    case DateTime.monday:
      return l.weekdayMonday;
    case DateTime.tuesday:
      return l.weekdayTuesday;
    case DateTime.wednesday:
      return l.weekdayWednesday;
    case DateTime.thursday:
      return l.weekdayThursday;
    case DateTime.friday:
      return l.weekdayFriday;
    case DateTime.saturday:
      return l.weekdaySaturday;
    case DateTime.sunday:
      return l.weekdaySunday;
    default:
      return '';
  }
}

String localizedGregorianMonthName(AppLocalizations l, int month) {
  switch (month) {
    case 1:
      return l.gregorianMonthJanuary;
    case 2:
      return l.gregorianMonthFebruary;
    case 3:
      return l.gregorianMonthMarch;
    case 4:
      return l.gregorianMonthApril;
    case 5:
      return l.gregorianMonthMay;
    case 6:
      return l.gregorianMonthJune;
    case 7:
      return l.gregorianMonthJuly;
    case 8:
      return l.gregorianMonthAugust;
    case 9:
      return l.gregorianMonthSeptember;
    case 10:
      return l.gregorianMonthOctober;
    case 11:
      return l.gregorianMonthNovember;
    case 12:
      return l.gregorianMonthDecember;
    default:
      return '';
  }
}

String localizedHijriMonthName(AppLocalizations l, int month) {
  switch (month) {
    case 1:
      return l.hijriMonthMuharram;
    case 2:
      return l.hijriMonthSafar;
    case 3:
      return l.hijriMonthRabiAlAwwal;
    case 4:
      return l.hijriMonthRabiAlThani;
    case 5:
      return l.hijriMonthJumadaAlAwwal;
    case 6:
      return l.hijriMonthJumadaAlAkhirah;
    case 7:
      return l.hijriMonthRajab;
    case 8:
      return l.hijriMonthShaban;
    case 9:
      return l.hijriMonthRamadan;
    case 10:
      return l.hijriMonthShawwal;
    case 11:
      return l.hijriMonthDhuAlQadah;
    case 12:
      return l.hijriMonthDhuAlHijjah;
    default:
      return '';
  }
}

String formatHijriDateLocalized(AppLocalizations l, DateTime date) {
  final hijri = HijriCalendar.fromDate(date);
  final month = localizedHijriMonthName(l, hijri.hMonth);
  return '${localizedWeekdayName(l, date.weekday)}${l.localeComma} '
      '${hijri.hDay} $month ${hijri.hYear} ${l.hijriYearSuffix}';
}

String formatGregorianDateLocalized(AppLocalizations l, DateTime date) {
  final month = localizedGregorianMonthName(l, date.month);
  return '${localizedWeekdayName(l, date.weekday)} '
      '${date.day} $month ${date.year} ${l.gregorianYearSuffix}';
}
