import 'package:ghasaq/l10n/app_localizations.dart';

import '../../domain/entities/greeting.dart';
import '../../domain/entities/upcoming_occasion.dart';

String resolveGreetingTitle(AppLocalizations l, Greeting g) {
  switch (g.period) {
    case GreetingPeriod.morning:
      return l.greetingMorningTitle;
    case GreetingPeriod.evening:
      return l.greetingEveningTitle;
  }
}

String resolveGreetingSubtitle(AppLocalizations l, Greeting g) {
  switch (g.period) {
    case GreetingPeriod.morning:
      return l.greetingMorningSubtitle;
    case GreetingPeriod.evening:
      return l.greetingEveningSubtitle;
  }
}

String resolveOccasionLabel(AppLocalizations l, String labelKey) {
  switch (labelKey) {
    case 'occasionHijriNewYear':
      return l.occasionHijriNewYear;
    case 'occasionAshura':
      return l.occasionAshura;
    case 'occasionMawlid':
      return l.occasionMawlid;
    case 'occasionIsraMiraj':
      return l.occasionIsraMiraj;
    case 'occasionMidShaban':
      return l.occasionMidShaban;
    case 'occasionRamadanStart':
      return l.occasionRamadanStart;
    case 'occasionLaylatQadr':
      return l.occasionLaylatQadr;
    case 'occasionEidFitr':
      return l.occasionEidFitr;
    case 'occasionArafah':
      return l.occasionArafah;
    case 'occasionEidAdha':
      return l.occasionEidAdha;
    default:
      return labelKey;
  }
}

/// Picks the display label for [o], preferring remote-driven `labelAr/En`
/// (locale-matched) over the bundled `labelKey`. Falls back across languages
/// when one is empty so a single-language remote entry still works.
String resolveOccasionDisplayLabel(
  AppLocalizations l,
  UpcomingOccasion o,
  String localeCode,
) {
  final ar = o.labelAr;
  final en = o.labelEn;
  if ((ar != null && ar.isNotEmpty) || (en != null && en.isNotEmpty)) {
    if (localeCode == 'en') {
      if (en != null && en.isNotEmpty) return en;
      if (ar != null && ar.isNotEmpty) return ar;
    } else {
      if (ar != null && ar.isNotEmpty) return ar;
      if (en != null && en.isNotEmpty) return en;
    }
  }
  return resolveOccasionLabel(l, o.labelKey);
}

String resolveDaysCountdown(AppLocalizations l, int daysUntil) {
  if (daysUntil == 0) return l.todayOccasionToday;
  if (daysUntil == 1) return l.todayOccasionTomorrow;
  return l.todayDaysRemaining(daysUntil);
}
