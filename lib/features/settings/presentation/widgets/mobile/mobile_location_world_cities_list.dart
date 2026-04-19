import 'package:flutter/material.dart';
import 'package:ghasaq/l10n/app_localizations.dart';

import '../../../../../core/city_translations.dart';
import '../../../domain/entities/world_city.dart';
import 'mobile_location_empty_state.dart';
import 'mobile_location_option_tile.dart';

/// City list for world (non-DB) countries.
///
/// Displays the localized world-city label and fires [onSelect] with the
/// full [WorldCity] so the caller can extract lat/lng/method/utcOffset.
class MobileLocationWorldCitiesList extends StatelessWidget {
  final List<WorldCity> cities;
  final String currentCountry;
  final String currentCity;
  final String selectedCountryKey;
  final ValueChanged<WorldCity> onSelect;

  const MobileLocationWorldCitiesList({
    super.key,
    required this.cities,
    required this.currentCountry,
    required this.currentCity,
    required this.selectedCountryKey,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    if (cities.isEmpty) {
      return MobileLocationEmptyState(message: l.settingsNoMatchingCities);
    }

    return ListView.builder(
      key: const ValueKey('world_cities'),
      padding: const EdgeInsets.only(left: 24, right: 24, bottom: 24),
      physics: const BouncingScrollPhysics(),
      itemExtent: 68,
      itemCount: cities.length,
      itemBuilder: (context, index) {
        final city = cities[index];
        final normalizedCurrentCountry = normalizeCountryKey(currentCountry);
        final isSelected =
            selectedCountryKey == normalizedCurrentCountry &&
            (city.name == currentCity || city.arabicName == currentCity);
        return MobileLocationOptionTile(
          title: cityLabel(
            city.name,
            locale: l.localeName,
            countryKey: city.countryKey,
          ),
          isSelected: isSelected,
          onTap: () => onSelect(city),
        );
      },
    );
  }
}
