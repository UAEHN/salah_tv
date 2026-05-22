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
    final isEn = l.localeName == 'en';
    // Pin the currently selected country to the top of the list so users
    // who just want to change the city in their own country find it
    // immediately without scrolling.
    final ordered = _orderedCountries(countries, currentCountry);
    return ListView.builder(
      key: const ValueKey('countries'),
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
      physics: const BouncingScrollPhysics(),
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      itemCount: ordered.length,
      itemBuilder: (context, index) {
        final country = ordered[index];
        final primary = isEn ? country.englishName : country.arabicName;
        final secondary = isEn ? country.arabicName : country.englishName;
        return MobileLocationOptionTile(
          title: primary,
          subtitle: secondary,
          isSelected: country.key == currentCountry,
          onTap: () => onSelect(country.key),
        );
      },
    );
  }

  List<UnifiedCountry> _orderedCountries(
    List<UnifiedCountry> list,
    String currentKey,
  ) {
    final idx = list.indexWhere((c) => c.key == currentKey);
    if (idx <= 0) return list;
    return [list[idx], ...list.where((c) => c.key != currentKey)];
  }
}
