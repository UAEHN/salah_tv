import 'package:adhan_dart/adhan_dart.dart';

/// Maps a string key (stored in settings) to adhan_dart CalculationParameters.
///
/// Keys match those used in [AppSettings.calculationMethod] and the
/// `world_cities.json` `method` field.
CalculationParameters calculationParametersFor(String methodKey) {
  return switch (methodKey) {
    'dubai' => CalculationMethodParameters.dubai(),
    'egyptian' => CalculationMethodParameters.egyptian(),
    'karachi' => CalculationMethodParameters.karachi(),
    'kuwait' => CalculationMethodParameters.kuwait(),
    'moonsighting_committee' =>
      CalculationMethodParameters.moonsightingCommittee(),
    'morocco' => CalculationMethodParameters.morocco(),
    'north_america' => CalculationMethodParameters.northAmerica(),
    'qatar' => CalculationMethodParameters.qatar(),
    'singapore' => CalculationMethodParameters.singapore(),
    'tehran' => CalculationMethodParameters.tehran(),
    'turkiye' => CalculationMethodParameters.turkiye(),
    'umm_al_qura' => CalculationMethodParameters.ummAlQura(),
    _ => CalculationMethodParameters.muslimWorldLeague(),
  };
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

/// Human-readable Arabic labels for calculation methods.
const kCalculationMethodLabels = <String, String>{
  'muslim_world_league': 'رابطة العالم الإسلامي',
  'egyptian': 'الهيئة المصرية العامة للمساحة',
  'karachi': 'جامعة العلوم الإسلامية، كراتشي',
  'umm_al_qura': 'أم القرى',
  'dubai': 'دبي',
  'qatar': 'قطر',
  'kuwait': 'الكويت',
  'morocco': 'المغرب',
  'singapore': 'سنغافورة',
  'tehran': 'طهران',
  'turkiye': 'تركيا (ديانت)',
  'north_america': 'أمريكا الشمالية (ISNA)',
  'moonsighting_committee': 'لجنة رؤية الهلال',
};
