import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ghasaq/l10n/app_localizations.dart';

import '../../../../../core/city_translations.dart';
import '../../bloc/location_choice.dart';
import '../../bloc/location_selection_cubit.dart';
import 'tv_location_empty_state.dart';
import 'tv_location_option_tile.dart';

class TvLocationCitiesList extends StatelessWidget {
  final List<LocationChoice> choices;
  final String currentCountryKey;
  final String currentCity;
  final bool isSaving;

  const TvLocationCitiesList({
    required this.choices,
    required this.currentCountryKey,
    required this.currentCity,
    required this.isSaving,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    if (choices.isEmpty) {
      return TvLocationEmptyState(message: l.settingsNoMatchingCities);
    }

    return ListView.builder(
      itemCount: choices.length,
      itemBuilder: (context, index) {
        final choice = choices[index];
        final isSelected =
            normalizeCountryKey(choice.countryKey) ==
                normalizeCountryKey(currentCountryKey) &&
            choice.cityName == currentCity;
        return TvLocationOptionTile(
          title: cityLabel(
            choice.cityName,
            locale: l.localeName,
            countryKey: choice.countryKey,
          ),
          isSelected: isSelected,
          isBusy: isSaving,
          autofocus: index == 0,
          onPressed: () => context.read<LocationSelectionCubit>().save(choice),
        );
      },
    );
  }
}
