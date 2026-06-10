import 'package:flutter/material.dart';
import 'package:ghasaq/l10n/app_localizations.dart';

import '../../../../../core/city_translations.dart';
import '../../../domain/entities/online_geocoding_result.dart';
import '../../../domain/entities/world_city.dart';
import '../../bloc/online_geocoding_cubit.dart';
import 'mobile_location_empty_state.dart';
import 'mobile_location_online_results_block.dart';
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
  final OnlineGeocodingState onlineState;
  final ValueChanged<OnlineGeocodingResult>? onSelectOnline;

  const MobileLocationWorldCitiesList({
    super.key,
    required this.cities,
    required this.currentCountry,
    required this.currentCity,
    required this.selectedCountryKey,
    required this.onSelect,
    this.onlineState = OnlineGeocodingState.idle,
    this.onSelectOnline,
  });

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final onlineBlock = _buildOnlineBlock();
    if (cities.isEmpty && onlineBlock == null) {
      return MobileLocationEmptyState(message: l.settingsNoMatchingCities);
    }
    final extra = onlineBlock != null ? 1 : 0;
    return ListView.builder(
      key: const ValueKey('world_cities'),
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
      physics: const BouncingScrollPhysics(),
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      itemCount: cities.length + extra,
      itemBuilder: (context, index) {
        if (index == cities.length && onlineBlock != null) return onlineBlock;
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

  Widget? _buildOnlineBlock() {
    final onSelect = onSelectOnline;
    if (onSelect == null) return null;
    if (onlineState.status == OnlineGeocodingStatus.idle) return null;
    return MobileLocationOnlineResultsBlock(
      state: onlineState,
      onSelect: onSelect,
    );
  }
}
