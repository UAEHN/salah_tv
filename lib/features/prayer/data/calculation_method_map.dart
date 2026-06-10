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
    // Grande Mosquée de Paris convention (12°/12°) — used by most French
    // mosques. adhan_dart has no built-in entry, so we start from MWL and
    // override the angles (the fields are declared `late` on the package
    // class so post-construction mutation is safe).
    'france' =>
      CalculationMethodParameters.muslimWorldLeague()
        ..fajrAngle = 12.0
        ..ishaAngle = 12.0,
    // UOIF (Union des Organisations Islamiques de France) — 15°/15°,
    // the second most common convention in French mosques.
    'uoif' =>
      CalculationMethodParameters.muslimWorldLeague()
        ..fajrAngle = 15.0
        ..ishaAngle = 15.0,
    // United Kingdom — 18°/17°, the convention published by London
    // Central Mosque (Regent's Park) and shared by most UK mosques
    // including Birmingham Central. adhan_dart has no built-in entry.
    'uk' =>
      CalculationMethodParameters.muslimWorldLeague()
        ..fajrAngle = 18.0
        ..ishaAngle = 17.0,
    // Germany / Austria / Netherlands / Belgium — 18°/17°, in line with
    // most German-speaking mosques and the DITIB published schedules.
    'germany' =>
      CalculationMethodParameters.muslimWorldLeague()
        ..fajrAngle = 18.0
        ..ishaAngle = 17.0,
    // Russia / Spiritual Administration of Muslims of Russia — 16°/15°.
    // Suited to high-latitude Russian and Eastern-European cities.
    'russia' =>
      CalculationMethodParameters.muslimWorldLeague()
        ..fajrAngle = 16.0
        ..ishaAngle = 15.0,
    // Ja'fari (Leva Research Institute / Shia): Fajr 16°, Isha 14°,
    // and Maghrib offset by 4° after sunset.
    'jafari' =>
      CalculationMethodParameters.muslimWorldLeague()
        ..fajrAngle = 16.0
        ..ishaAngle = 14.0
        ..maghribAngle = 4.0,
    _ => CalculationMethodParameters.muslimWorldLeague(),
  };
}
