import 'package:flutter/material.dart';
import '../../../../../core/city_translations.dart';
import 'mobile_location_empty_state.dart';
import 'mobile_location_option_tile.dart';

class MobileLocationCountriesList extends StatelessWidget {
  final List<CountryInfo> countries;
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
    if (countries.isEmpty) {
      return const MobileLocationEmptyState(message: 'لا توجد دول مطابقة');
    }

    return ListView.builder(
      key: const ValueKey('countries'),
      padding: const EdgeInsets.only(left: 24, right: 24, bottom: 24),
      physics: const BouncingScrollPhysics(),
      itemExtent: 68, // ListTile(56) + margin-bottom(12) — skips per-item layout
      itemCount: countries.length,
      itemBuilder: (context, index) {
        final country = countries[index];
        return MobileLocationOptionTile(
          title: country.arabicName,
          isSelected: country.key == currentCountry,
          onTap: () => onSelect(country.key),
        );
      },
    );
  }
}
