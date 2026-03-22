import 'package:flutter/material.dart';
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
    if (cities.isEmpty) {
      return const MobileLocationEmptyState(message: 'لا توجد مدن مطابقة');
    }

    return ListView.builder(
      key: const ValueKey('cities'),
      padding: const EdgeInsets.only(left: 24, right: 24, bottom: 24),
      physics: const BouncingScrollPhysics(),
      itemExtent: 68, // ListTile(56) + margin-bottom(12) — skips per-item layout
      itemCount: cities.length,
      itemBuilder: (context, index) {
        final cityKey = cities[index];
        final isSelected =
            cityKey == currentCity && selectedCountryKey == currentCountry;
        return MobileLocationOptionTile(
          title: cityLabel(cityKey),
          isSelected: isSelected,
          onTap: () => onSelect(cityKey),
        );
      },
    );
  }
}
