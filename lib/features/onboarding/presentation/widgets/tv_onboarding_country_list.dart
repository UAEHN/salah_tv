import 'package:flutter/material.dart';

import '../../../settings/presentation/logic/location_picker_logic.dart';
import 'tv_onboarding_list_item.dart';

/// Scrollable, focus-traversable list of selectable countries for TV onboarding
/// step 1. Split out of the country page to honor the 150-line cap (§4).
class TvOnboardingCountryList extends StatelessWidget {
  const TvOnboardingCountryList({
    super.key,
    required this.countries,
    required this.selectedKey,
    required this.locale,
    required this.onSelect,
  });

  final List<UnifiedCountry> countries;
  final String? selectedKey;
  final String locale;
  final ValueChanged<String> onSelect;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.only(left: 64, right: 64, bottom: 32),
      itemCount: countries.length,
      itemBuilder: (_, i) {
        final country = countries[i];
        final label = locale == 'en' ? country.englishName : country.arabicName;
        return TvOnboardingListItem(
          title: label,
          isSelected: country.key == selectedKey,
          onSelect: () => onSelect(country.key),
          autofocus: i == 0,
        );
      },
    );
  }
}
