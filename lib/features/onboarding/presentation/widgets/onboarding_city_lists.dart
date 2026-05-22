import 'package:flutter/material.dart';

import '../../../../core/city_translations.dart';
import '../../../settings/domain/entities/world_city.dart';
import 'onboarding_selectable_tile.dart';
import 'onboarding_staggered_list.dart';

/// City list backed by the bundled prayer-times DB (per-country city keys).
class OnboardingDbCityList extends StatelessWidget {
  final List<String> cities;
  final String? selectedCityKey;
  final Animation<double> entranceAnimation;
  final String locale;
  final ValueChanged<String> onSelect;

  const OnboardingDbCityList({
    super.key,
    required this.cities,
    required this.selectedCityKey,
    required this.entranceAnimation,
    required this.locale,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return OnboardingStaggeredList(
      entranceAnimation: entranceAnimation,
      itemCount: cities.length,
      itemBuilder: (_, i) {
        final key = cities[i];
        final isSelected = key == selectedCityKey;
        return OnboardingSelectableTile(
          title: cityLabel(key, locale: locale),
          isSelected: isSelected,
          onTap: () => onSelect(key),
        );
      },
    );
  }
}

/// City list backed by the calculated-method world city dataset.
class OnboardingWorldCityList extends StatelessWidget {
  final List<WorldCity> cities;
  final WorldCity? selectedCity;
  final Animation<double> entranceAnimation;
  final String locale;
  final ValueChanged<WorldCity> onSelect;

  const OnboardingWorldCityList({
    super.key,
    required this.cities,
    required this.selectedCity,
    required this.entranceAnimation,
    required this.locale,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return OnboardingStaggeredList(
      entranceAnimation: entranceAnimation,
      itemCount: cities.length,
      itemBuilder: (_, i) {
        final city = cities[i];
        final isSelected =
            selectedCity?.name == city.name &&
            selectedCity?.countryKey == city.countryKey;
        return OnboardingSelectableTile(
          title: cityLabel(
            city.name,
            locale: locale,
            countryKey: city.countryKey,
          ),
          isSelected: isSelected,
          onTap: () => onSelect(city),
        );
      },
    );
  }
}
