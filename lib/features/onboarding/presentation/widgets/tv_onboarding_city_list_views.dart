import 'package:flutter/material.dart';

import '../../../../core/city_translations.dart';
import '../../../../features/settings/domain/entities/world_city.dart';
import 'tv_onboarding_list_item.dart';

class DbCityListView extends StatelessWidget {
  const DbCityListView({
    super.key,
    required this.cities,
    required this.selectedKey,
    required this.locale,
    required this.onSelect,
  });

  final List<String> cities;
  final String? selectedKey;
  final String locale;
  final ValueChanged<String> onSelect;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 16),
      itemCount: cities.length,
      itemBuilder: (_, i) {
        final key = cities[i];
        return TvOnboardingListItem(
          title: cityLabel(key, locale: locale),
          isSelected: key == selectedKey,
          onSelect: () => onSelect(key),
          autofocus: i == 0,
        );
      },
    );
  }
}

class WorldCityListView extends StatelessWidget {
  const WorldCityListView({
    super.key,
    required this.cities,
    required this.selectedCity,
    required this.locale,
    required this.onSelect,
  });

  final List<WorldCity> cities;
  final WorldCity? selectedCity;
  final String locale;
  final ValueChanged<WorldCity> onSelect;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 16),
      itemCount: cities.length,
      itemBuilder: (_, i) {
        final city = cities[i];
        final isSelected =
            selectedCity?.name == city.name &&
            selectedCity?.countryKey == city.countryKey;
        return TvOnboardingListItem(
          title: cityLabel(
            city.name,
            locale: locale,
            countryKey: city.countryKey,
          ),
          isSelected: isSelected,
          onSelect: () => onSelect(city),
          autofocus: i == 0,
        );
      },
    );
  }
}
