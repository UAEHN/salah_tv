import 'package:flutter/widgets.dart';
import 'package:ghasaq/l10n/app_localizations.dart';

const _arabic = {
  'subhanallah':    'سبحان الله',
  'alhamdulillah':  'الحمد لله',
  'allahuakbar':    'الله أكبر',
  'lailahaillallah': 'لا إله إلا الله',
};

const _english = {
  'subhanallah':    'Subhan Allah',
  'alhamdulillah':  'Alhamdulillah',
  'allahuakbar':    'Allahu Akbar',
  'lailahaillallah': 'La ilaha illa Allah',
};

/// Returns the phrase in the current locale.
String localizedTasbihPhrase(BuildContext context, String key) {
  final l = AppLocalizations.of(context);
  switch (key) {
    case 'subhanallah':      return l.tasbihPhraseSubhanAllah;
    case 'alhamdulillah':    return l.tasbihPhraseAlhamdulillah;
    case 'allahuakbar':      return l.tasbihPhraseAllahuAkbar;
    case 'lailahaillallah':  return l.tasbihPhraseLaIlahaIllallah;
    default:                 return key;
  }
}

/// Always returns the Arabic script regardless of locale.
String arabicTasbihPhrase(String key) =>
    _arabic[key] ?? key;

/// Always returns the English transliteration regardless of locale.
String englishTasbihPhrase(String key) =>
    _english[key] ?? key;
