import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ghasaq/l10n/app_localizations.dart';

import '../../../../../core/app_colors.dart';
import '../../../../../core/city_translations.dart';
import '../../../domain/entities/online_geocoding_result.dart';
import '../../bloc/online_geocoding_cubit.dart';
import '../../bloc/tv_location_picker_cubit.dart';
import '../../logic/location_picker_logic.dart';
import '../../settings_provider.dart';
import '../online_city_result_tile.dart';
import 'tv_location_empty_state.dart';
import 'tv_location_option_tile.dart';

class TvLocationCountriesList extends StatelessWidget {
  final List<UnifiedCountry> countries;
  final String currentCountryKey;
  final ValueChanged<OnlineGeocodingResult>? onSelectOnline;

  const TvLocationCountriesList({
    required this.countries,
    required this.currentCountryKey,
    this.onSelectOnline,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    if (countries.isEmpty) {
      return _emptyOrOnline(context, l);
    }

    return ListView.builder(
      // 8 px scrollable padding so the first/last tile's focus halo (blur 14)
      // doesn't get clipped by the parent Padding's top/bottom edges.
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: countries.length,
      itemBuilder: (context, index) {
        final country = countries[index];
        final isSelected =
            normalizeCountryKey(country.key) ==
            normalizeCountryKey(currentCountryKey);
        return TvLocationOptionTile(
          title: l.localeName == 'en'
              ? country.englishName
              : country.arabicName,
          isSelected: isSelected,
          isBusy: false,
          autofocus: index == 0,
          onPressed: () =>
              context.read<TvLocationPickerCubit>().selectCountry(country),
        );
      },
    );
  }

  /// Inline Nominatim fallback. Same UX promise as mobile: no separate
  /// screen — typing in the country search is enough to find any city
  /// worldwide, with the results appearing right under an empty match.
  Widget _emptyOrOnline(BuildContext context, AppLocalizations l) {
    final select = onSelectOnline;
    return BlocBuilder<OnlineGeocodingCubit, OnlineGeocodingState>(
      builder: (context, state) {
        if (select == null || state.query.length < 2) {
          return TvLocationEmptyState(message: l.settingsNoMatchingCountries);
        }
        switch (state.status) {
          case OnlineGeocodingStatus.loading:
            return const Center(child: CircularProgressIndicator());
          case OnlineGeocodingStatus.error:
            return TvLocationEmptyState(message: l.settingsSearchOnlineError);
          case OnlineGeocodingStatus.empty:
            return TvLocationEmptyState(message: l.settingsSearchOnlineEmpty);
          case OnlineGeocodingStatus.idle:
            return TvLocationEmptyState(message: l.settingsNoMatchingCountries);
          case OnlineGeocodingStatus.results:
            final settings = context.watch<SettingsProvider>().settings;
            final tc = ThemeColors.of(settings.isDarkMode);
            return ListView(
              padding: const EdgeInsets.only(top: 4),
              children: [
                Padding(
                  padding: const EdgeInsets.only(bottom: 10, left: 4, right: 4),
                  child: Text(
                    l.settingsSearchOnline,
                    style: TextStyle(
                      color: tc.textMuted,
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.4,
                    ),
                  ),
                ),
                for (final r in state.results)
                  OnlineCityResultTile(
                    result: r,
                    tc: tc,
                    autofocus: r == state.results.first,
                    onTap: () => select(r),
                  ),
              ],
            );
        }
      },
    );
  }
}
