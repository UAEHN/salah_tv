import 'package:flutter/widgets.dart';
import 'package:ghasaq/l10n/app_localizations.dart';

String localizedCalculationMethod(
  BuildContext context,
  String methodKey,
) {
  final l = AppLocalizations.of(context);
  return localizedCalculationMethodFromLocalizations(l, methodKey);
}

String localizedCalculationMethodFromLocalizations(
  AppLocalizations l,
  String methodKey,
) {
  switch (methodKey) {
    case 'muslim_world_league':
      return l.calcMethodMuslimWorldLeague;
    case 'egyptian':
      return l.calcMethodEgyptian;
    case 'karachi':
      return l.calcMethodKarachi;
    case 'umm_al_qura':
      return l.calcMethodUmmAlQura;
    case 'dubai':
      return l.calcMethodDubai;
    case 'qatar':
      return l.calcMethodQatar;
    case 'kuwait':
      return l.calcMethodKuwait;
    case 'morocco':
      return l.calcMethodMorocco;
    case 'singapore':
      return l.calcMethodSingapore;
    case 'tehran':
      return l.calcMethodTehran;
    case 'turkiye':
      return l.calcMethodTurkiye;
    case 'north_america':
      return l.calcMethodNorthAmerica;
    case 'moonsighting_committee':
      return l.calcMethodMoonsightingCommittee;
    default:
      return methodKey;
  }
}

/// Default calculation method for a given ISO 3166-1 alpha-2 country code.
String defaultMethodForCountryIso(String? isoCode) {
  return switch (isoCode?.toUpperCase()) {
    'AE' => 'dubai',
    'SA' => 'umm_al_qura',
    'KW' => 'kuwait',
    'QA' => 'qatar',
    'EG' || 'LY' || 'SD' => 'egyptian',
    'MA' => 'morocco',
    'TR' => 'turkiye',
    'IR' => 'tehran',
    'PK' || 'BD' || 'IN' || 'AF' => 'karachi',
    'SG' || 'MY' || 'ID' || 'BN' => 'singapore',
    'US' || 'CA' || 'MX' => 'north_america',
    _ => 'muslim_world_league',
  };
}
