import 'package:ghasaq/l10n/app_localizations.dart';

import '../../../../../core/localization/date_localizer.dart';

String formatHijriDate(AppLocalizations l, DateTime date) {
  return formatHijriDateLocalized(l, date);
}

String formatGregorianDate(AppLocalizations l, DateTime date) {
  return formatGregorianDateLocalized(l, date);
}
