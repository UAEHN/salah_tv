import 'package:flutter/material.dart';
import 'package:ghasaq/l10n/app_localizations.dart';

import 'mobile_location_empty_state.dart';
import 'mobile_location_option_tile.dart';
import 'mobile_location_search_utils.dart';

class MobileLocationCountriesList extends StatelessWidget {
  final List<UnifiedCountry> countries;
  final String currentCountry;
  final ValueChanged<String> onSelect;

  const MobileLocationCountriesList({
    super.key,
    required this.countries,
    required this.currentCountry,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    if (countries.isEmpty) {
      return MobileLocationEmptyState(message: l.settingsNoMatchingCountries);
    }

    return ListView.builder(
      key: const ValueKey('countries'),
      padding: const EdgeInsets.only(left: 24, right: 24, bottom: 24),
      physics: const BouncingScrollPhysics(),
      itemExtent: 68,
      itemCount: countries.length,
      itemBuilder: (context, index) {
        final country = countries[index];
        return MobileLocationOptionTile(
          title: l.localeName == 'en' ? country.englishName : country.arabicName,
          isSelected: country.key == currentCountry,
          onTap: () => onSelect(country.key),
        );
      },
    );
  }
}
