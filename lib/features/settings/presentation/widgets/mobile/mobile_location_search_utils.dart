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

/// Country-agnostic city search across the bundled catalogue. Used by
/// the top-level mixed results list so the user can find a known local
/// city by name without first picking its country.
List<WorldCity> filterAllWorldCities(
  String query,
  IWorldCityRepository worldRepo, {
  int limit = 20,
}) {
  if (normalizeLocationSearchQuery(query).isEmpty) return const [];
  final hits = worldRepo
      .searchCities(query)
      .where(
        (c) => matchesLocationQuery(query, [
          c.name,
          c.arabicName,
          c.countryKey,
          c.countryArabic,
        ]),
      )
      .take(limit)
      .toList();
  return hits;
}

String locationSearchHint(BuildContext context, bool showCities) {
  final l = AppLocalizations.of(context);
  return showCities ? l.settingsSearchCity : l.settingsSearchCountry;
}
