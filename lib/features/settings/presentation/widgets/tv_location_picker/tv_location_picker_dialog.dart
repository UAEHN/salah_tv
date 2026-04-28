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
    return BlocListener<LocationSelectionCubit, LocationSelectionState>(
      listenWhen: (prev, next) {
        // Close for world-city saves (no download involved).
        final worldSaved = prev.status != next.status &&
            next.status == LocationSelectionStatus.saved &&
            next.downloadStatus == CityDownloadStatus.idle;
        // Close when DB-city download completes.
        final downloadReady = prev.downloadStatus != next.downloadStatus &&
            next.downloadStatus == CityDownloadStatus.ready;
        return worldSaved || downloadReady;
      },
      listener: (context, _) => Navigator.of(context).pop(),
      child: BlocBuilder<TvLocationPickerCubit, TvLocationPickerState>(
        builder: (context, pickerState) {
          return BlocBuilder<LocationSelectionCubit, LocationSelectionState>(
            builder: (context, selState) {
              return Dialog(
                backgroundColor: const Color(0xFF0A1628),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
                child: SizedBox(
                  width: 920,
                  height: 660,
                  child: pickerState.isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : Column(
                          children: [
                            TvLocationPickerHeader(
                              title: _titleForState(context, pickerState),
                              showBack: pickerState.showsCities,
                              onBack: context
                                  .read<TvLocationPickerCubit>()
                                  .showCountries,
                            ),
                            Padding(
                              padding:
                                  const EdgeInsets.fromLTRB(24, 0, 24, 18),
                              child: TvLocationSearchField(
                                hintText: _hintForState(context, pickerState),
                                onChanged: context
                                    .read<TvLocationPickerCubit>()
                                    .updateQuery,
                              ),
                            ),
                            Expanded(
                              child: Padding(
                                padding:
                                    const EdgeInsets.fromLTRB(24, 0, 24, 24),
                                child: pickerState.showsCities
                                    ? TvLocationCitiesList(
                                        choices: pickerState.cities,
                                        currentCountryKey:
                                            pickerState.currentCountryKey,
                                        currentCity: pickerState.currentCity,
                                        isSaving: selState.status ==
                                            LocationSelectionStatus.saving,
                                      )
                                    : TvLocationCountriesList(
                                        countries: pickerState.countries,
                                        currentCountryKey:
                                            pickerState.currentCountryKey,
                                      ),
                              ),
                            ),
                            if (selState.downloadStatus ==
                                CityDownloadStatus.downloading)
                              const Padding(
                                padding: EdgeInsets.only(bottom: 20),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    SizedBox(
                                      width: 18,
                                      height: 18,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Colors.white70,
                                      ),
                                    ),
                                    SizedBox(width: 12),
                                    Text(
                                      'جارٍ تحميل بيانات المدينة...',
                                      style: TextStyle(
                                        color: Colors.white70,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            if (selState.downloadStatus ==
                                CityDownloadStatus.failed)
                              Padding(
                                padding: const EdgeInsets.only(bottom: 20),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Icon(
                                      Icons.error_outline,
                                      color: Colors.redAccent,
                                      size: 18,
                                    ),
                                    const SizedBox(width: 10),
                                    Text(
                                      selState.downloadError ??
                                          'تعذّر تحميل بيانات المدينة',
                                      style: const TextStyle(
                                        color: Colors.redAccent,
                                        fontSize: 14,
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    TextButton(
                                      onPressed: () => context
                                          .read<LocationSelectionCubit>()
                                          .retry(),
                                      child: const Text(
                                        'إعادة المحاولة',
                                        style: TextStyle(color: Colors.white),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                          ],
                        ),
                ),
              );
            },
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
