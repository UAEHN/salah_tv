import 'package:flutter/widgets.dart';
import 'package:ghasaq/l10n/app_localizations.dart';

import '../../../../../core/city_translations.dart';
import '../../../domain/entities/world_city.dart';
import '../../../domain/i_world_city_repository.dart';
import '../../bloc/location_picker_source.dart';
import '../../logic/location_picker_logic.dart';

export '../../logic/location_picker_logic.dart';

List<String> filterDbCities(String countryKey, String query) {
  return buildCountryChoices(
        UnifiedCountry(
          key: countryKey,
          arabicName: '',
          englishName: '',
          source: LocationPickerSource.db,
        ),
        null,
      )
      .where((choice) {
        return matchesLocationQuery(query, [
          choice.cityName,
          cityLabel(choice.cityName),
          choice.countryKey,
        ]);
      })
      .map((choice) => choice.cityName)
      .toList();
}

List<WorldCity> filterWorldCities(
  String countryKey,
  String query,
  IWorldCityRepository worldRepo,
) {
  final q = normalizeLocationSearchQuery(query);
  return worldRepo.citiesForCountry(countryKey).where((city) {
    if (q.isEmpty) return true;
    return matchesLocationQuery(query, [city.name, city.arabicName]);
  }).toList();
}

String locationSearchHint(BuildContext context, bool showCities) {
  final l = AppLocalizations.of(context);
  return showCities ? l.settingsSearchCity : l.settingsSearchCountry;
}
