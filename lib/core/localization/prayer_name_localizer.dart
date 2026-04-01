import 'package:flutter/widgets.dart';
import 'package:ghasaq/l10n/app_localizations.dart';

String localizedPrayerName(BuildContext context, String key) {
  final l = AppLocalizations.of(context);
  return localizedPrayerNameFromLocalizations(l, key);
}

String localizedPrayerNameForLocale(String localeCode, String key) {
  final l = lookupAppLocalizations(Locale(localeCode));
  return localizedPrayerNameFromLocalizations(l, key);
}

String localizedPrayerNameFromLocalizations(AppLocalizations l, String key) {
  switch (key) {
    case 'fajr':
      return l.prayerFajr;
    case 'sunrise':
      return l.prayerSunrise;
    case 'dhuhr':
      return l.prayerDhuhr;
    case 'asr':
      return l.prayerAsr;
    case 'maghrib':
      return l.prayerMaghrib;
    case 'isha':
      return l.prayerIsha;
    default:
      return key;
  }
}
