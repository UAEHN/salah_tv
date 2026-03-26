import 'package:flutter/material.dart';
import '../../../domain/entities/world_city.dart';
import 'mobile_location_empty_state.dart';
import 'mobile_location_option_tile.dart';

/// City list for world (non-DB) countries.
///
/// Displays [WorldCity.arabicName] and fires [onSelect] with the full
/// [WorldCity] so the caller can extract lat/lng/method/utcOffset.
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
    if (cities.isEmpty) {
      return const MobileLocationEmptyState(message: 'لا توجد مدن مطابقة');
    }

    return ListView.builder(
      key: const ValueKey('world_cities'),
      padding: const EdgeInsets.only(left: 24, right: 24, bottom: 24),
      physics: const BouncingScrollPhysics(),
      itemExtent: 68,
      itemCount: cities.length,
      itemBuilder: (context, index) {
        final city = cities[index];
        final isSelected = city.arabicName == currentCity &&
            selectedCountryKey == currentCountry;
        return MobileLocationOptionTile(
          title: city.arabicName,
          isSelected: isSelected,
          onTap: () => onSelect(city),
        );
      },
    );
  }
}
