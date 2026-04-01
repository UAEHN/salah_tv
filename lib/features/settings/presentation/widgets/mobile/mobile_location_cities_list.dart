import 'package:flutter/material.dart';
import 'package:ghasaq/l10n/app_localizations.dart';

import '../../../../../core/city_translations.dart';
import 'mobile_location_empty_state.dart';
import 'mobile_location_option_tile.dart';

class MobileLocationCitiesList extends StatelessWidget {
  final List<String> cities;
  final String currentCountry;
  final String currentCity;
  final String selectedCountryKey;
  final ValueChanged<String> onSelect;

  const MobileLocationCitiesList({
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
      key: const ValueKey('cities'),
      padding: const EdgeInsets.only(left: 24, right: 24, bottom: 24),
      physics: const BouncingScrollPhysics(),
      itemExtent: 68,
      itemCount: cities.length,
      itemBuilder: (context, index) {
        final cityKey = cities[index];
        final isSelected =
            cityKey == currentCity && selectedCountryKey == currentCountry;
        return MobileLocationOptionTile(
          title: cityLabel(cityKey, locale: l.localeName),
          isSelected: isSelected,
          onTap: () => onSelect(cityKey),
        );
      },
    );
  }
}
