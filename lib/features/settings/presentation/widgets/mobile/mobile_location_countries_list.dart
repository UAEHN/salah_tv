import 'package:flutter/material.dart';
import 'package:ghasaq/l10n/app_localizations.dart';

import '../../../../../core/app_colors.dart';
import '../../../../../core/mobile_theme.dart';
import '../../../domain/entities/online_geocoding_result.dart';
import '../../bloc/online_geocoding_cubit.dart';
import '../online_city_result_tile.dart';
import 'mobile_location_empty_state.dart';
import 'mobile_location_option_tile.dart';
import 'mobile_location_search_utils.dart';

class MobileLocationCountriesList extends StatelessWidget {
  final List<UnifiedCountry> countries;
  final String currentCountry;
  final ValueChanged<String> onSelect;
  final OnlineGeocodingState onlineState;
  final ValueChanged<OnlineGeocodingResult>? onSelectOnline;

  const MobileLocationCountriesList({
    super.key,
    required this.countries,
    required this.currentCountry,
    required this.onSelect,
    this.onlineState = OnlineGeocodingState.idle,
    this.onSelectOnline,
  });

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    if (countries.isEmpty) {
      return _emptyOrOnline(context, l);
    }
    final isEn = l.localeName == 'en';
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

  /// Renders the inline online (Nominatim) results when the bundled country
  /// list has nothing for the current query. The user no longer needs a
  /// dedicated search page — typing here is enough to discover any city
  /// worldwide.
  Widget _emptyOrOnline(BuildContext context, AppLocalizations l) {
    final select = onSelectOnline;
    if (select == null || onlineState.query.length < 2) {
      return MobileLocationEmptyState(message: l.settingsNoMatchingCountries);
    }
    switch (onlineState.status) {
      case OnlineGeocodingStatus.loading:
        return const Center(child: CircularProgressIndicator());
      case OnlineGeocodingStatus.error:
        return MobileLocationEmptyState(message: l.settingsSearchOnlineError);
      case OnlineGeocodingStatus.empty:
        return MobileLocationEmptyState(message: l.settingsSearchOnlineEmpty);
      case OnlineGeocodingStatus.idle:
        return MobileLocationEmptyState(message: l.settingsNoMatchingCountries);
      case OnlineGeocodingStatus.results:
        final tc = ThemeColors.of(
          Theme.of(context).brightness == Brightness.dark,
        );
        return ListView(
          key: const ValueKey('online_results'),
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
          physics: const BouncingScrollPhysics(),
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 8, right: 4, left: 4),
              child: Text(
                l.settingsSearchOnline,
                style: TextStyle(
                  color: MobileColors.onSurfaceMuted(context),
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.4,
                ),
              ),
            ),
            for (final r in onlineState.results)
              OnlineCityResultTile(result: r, tc: tc, onTap: () => select(r)),
          ],
        );
    }
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
