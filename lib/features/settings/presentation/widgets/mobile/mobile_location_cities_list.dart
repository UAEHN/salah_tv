import 'package:flutter/material.dart';
import 'package:ghasaq/l10n/app_localizations.dart';

import '../../../../../core/city_translations.dart';
import '../../../domain/entities/online_geocoding_result.dart';
import '../../bloc/online_geocoding_cubit.dart';
import 'mobile_location_empty_state.dart';
import 'mobile_location_online_results_block.dart';
import 'mobile_location_option_tile.dart';

class MobileLocationCitiesList extends StatelessWidget {
  final List<String> cities;
  final String currentCountry;
  final String currentCity;
  final String selectedCountryKey;
  final ValueChanged<String> onSelect;
  final OnlineGeocodingState onlineState;
  final ValueChanged<OnlineGeocodingResult>? onSelectOnline;

  const MobileLocationCitiesList({
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
      key: const ValueKey('cities'),
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
      physics: const BouncingScrollPhysics(),
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      itemCount: cities.length + extra,
      itemBuilder: (context, index) {
        if (index == cities.length && onlineBlock != null) return onlineBlock;
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
