import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ghasaq/l10n/app_localizations.dart';

import '../../../../../../core/city_translations.dart';
import '../../bloc/tv_location_picker_cubit.dart';
import '../../logic/location_picker_logic.dart';
import 'tv_location_empty_state.dart';
import 'tv_location_option_tile.dart';

class TvLocationCountriesList extends StatelessWidget {
  final List<UnifiedCountry> countries;
  final String currentCountryKey;

  const TvLocationCountriesList({
    required this.countries,
    required this.currentCountryKey,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    if (countries.isEmpty) {
      return TvLocationEmptyState(message: l.settingsNoMatchingCountries);
    }

    return ListView.builder(
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
}
