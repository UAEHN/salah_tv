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
