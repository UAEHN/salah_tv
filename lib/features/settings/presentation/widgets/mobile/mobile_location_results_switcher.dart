import 'package:flutter/material.dart';

import '../../../domain/entities/remote_city_result.dart';
import '../../../domain/entities/world_city.dart';
import '../../logic/merged_city_results.dart';
import 'mobile_location_cities_list.dart';
import 'mobile_location_countries_list.dart';
import 'mobile_location_mixed_results_list.dart';
import 'mobile_location_search_utils.dart';
import 'mobile_location_world_cities_list.dart';

/// Picks which list to render inside the location bottom sheet based on
/// the current navigation/query state. Extracted from the dialog body so
/// the body file stays under the 150-line limit.
class MobileLocationResultsSwitcher extends StatelessWidget {
  final String? selectedCountryKey;
  final bool isSelectedCountryDb;
  final String currentCountry;
  final String currentCity;
  final String currentQuery;
  final List<UnifiedCountry> filteredCountries;
  final List<String> filteredDbCities;
  final List<WorldCity> filteredWorldCities;
  final List<MergedCityRow> mixedCityRows;
  final bool remoteLoading;
  final ValueChanged<String> onSelectCountry;
  final ValueChanged<String> onSelectDbCity;
  final ValueChanged<WorldCity> onSelectWorldCity;
  final ValueChanged<RemoteCityResult> onSelectRemoteCity;

  const MobileLocationResultsSwitcher({
    super.key,
    required this.selectedCountryKey,
    required this.isSelectedCountryDb,
    required this.currentCountry,
    required this.currentCity,
    required this.currentQuery,
    required this.filteredCountries,
    required this.filteredDbCities,
    required this.filteredWorldCities,
    required this.mixedCityRows,
    required this.remoteLoading,
    required this.onSelectCountry,
    required this.onSelectDbCity,
    required this.onSelectWorldCity,
    required this.onSelectRemoteCity,
  });

  @override
  Widget build(BuildContext context) {
    final k = selectedCountryKey;
    if (k == null) {
      if (currentQuery.trim().isEmpty) {
        return MobileLocationCountriesList(
          countries: filteredCountries,
          currentCountry: currentCountry,
          onSelect: onSelectCountry,
        );
      }
      return MobileLocationMixedResultsList(
        countries: filteredCountries,
        cityRows: mixedCityRows,
        remoteLoading: remoteLoading,
        currentCountry: currentCountry,
        onSelectCountry: onSelectCountry,
        onSelectLocalCity: onSelectWorldCity,
        onSelectRemoteCity: onSelectRemoteCity,
      );
    }
    if (isSelectedCountryDb) {
      return MobileLocationCitiesList(
        cities: filteredDbCities,
        currentCountry: currentCountry,
        currentCity: currentCity,
        selectedCountryKey: k,
        onSelect: onSelectDbCity,
      );
    }
    return MobileLocationWorldCitiesList(
      cities: filteredWorldCities,
      currentCountry: currentCountry,
      currentCity: currentCity,
      selectedCountryKey: k,
      onSelect: onSelectWorldCity,
    );
  }
}
