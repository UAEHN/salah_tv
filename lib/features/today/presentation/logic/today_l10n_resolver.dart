import 'package:ghasaq/l10n/app_localizations.dart';

import '../../domain/entities/greeting.dart';

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

String resolveDaysCountdown(AppLocalizations l, int daysUntil) {
  if (daysUntil == 0) return l.todayOccasionToday;
  if (daysUntil == 1) return l.todayOccasionTomorrow;
  return l.todayDaysRemaining(daysUntil);
}
