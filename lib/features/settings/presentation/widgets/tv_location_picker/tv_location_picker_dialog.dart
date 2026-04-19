import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ghasaq/l10n/app_localizations.dart';

import '../../bloc/location_selection_cubit.dart';
import '../../bloc/tv_location_picker_cubit.dart';
import '../../bloc/tv_location_picker_state.dart';
import 'tv_location_cities_list.dart';
import 'tv_location_countries_list.dart';
import 'tv_location_picker_header.dart';
import 'tv_location_search_field.dart';

class TvLocationPickerDialog extends StatelessWidget {
  const TvLocationPickerDialog({super.key});

  @override
  Widget build(BuildContext context) {
    final settingsState = context.watch<LocationSelectionCubit>().state;
    return BlocListener<LocationSelectionCubit, LocationSelectionState>(
      listenWhen: (prev, next) =>
          prev.status != next.status &&
          next.status == LocationSelectionStatus.saved,
      listener: (context, _) => Navigator.of(context).pop(),
      child: BlocBuilder<TvLocationPickerCubit, TvLocationPickerState>(
        builder: (context, state) {
          return Dialog(
            backgroundColor: const Color(0xFF0A1628),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
            ),
            child: SizedBox(
              width: 920,
              height: 660,
              child: state.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : Column(
                      children: [
                        TvLocationPickerHeader(
                          title: _titleForState(context, state),
                          showBack: state.showsCities,
                          onBack: context
                              .read<TvLocationPickerCubit>()
                              .showCountries,
                        ),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(24, 0, 24, 18),
                          child: TvLocationSearchField(
                            hintText: _hintForState(context, state),
                            onChanged: context
                                .read<TvLocationPickerCubit>()
                                .updateQuery,
                          ),
                        ),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                            child: state.showsCities
                                ? TvLocationCitiesList(
                                    choices: state.cities,
                                    currentCountryKey: state.currentCountryKey,
                                    currentCity: state.currentCity,
                                    isSaving:
                                        settingsState.status ==
                                        LocationSelectionStatus.saving,
                                  )
                                : TvLocationCountriesList(
                                    countries: state.countries,
                                    currentCountryKey: state.currentCountryKey,
                                  ),
                          ),
                        ),
                      ],
                    ),
            ),
          );
        },
      ),
    );
  }

  String _titleForState(BuildContext context, TvLocationPickerState state) {
    final l = AppLocalizations.of(context);
    if (!state.showsCities) return l.settingsSelectCountry;
    return l.settingsSelectCity;
  }

  String _hintForState(BuildContext context, TvLocationPickerState state) {
    final l = AppLocalizations.of(context);
    return state.showsCities ? l.settingsSearchCity : l.settingsSearchCountry;
  }
}
