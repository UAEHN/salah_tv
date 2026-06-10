import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ghasaq/l10n/app_localizations.dart';

import '../../../../../core/app_colors.dart';
import '../../../domain/entities/online_geocoding_result.dart';
import '../../bloc/location_selection_cubit.dart';
import '../../bloc/online_geocoding_cubit.dart';
import '../../bloc/tv_location_picker_cubit.dart';
import '../../bloc/tv_location_picker_state.dart';
import '../../settings_provider.dart';
import 'tv_location_cities_list.dart';
import 'tv_location_countries_list.dart';
import 'tv_location_picker_header.dart';
import 'tv_location_search_field.dart';
import 'tv_online_location_flow.dart';

class TvLocationPickerDialog extends StatelessWidget {
  const TvLocationPickerDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<LocationSelectionCubit, LocationSelectionState>(
      listenWhen: (prev, next) {
        final worldSaved =
            prev.status != next.status &&
            next.status == LocationSelectionStatus.saved &&
            next.downloadStatus == CityDownloadStatus.idle;
        final downloadReady =
            prev.downloadStatus != next.downloadStatus &&
            next.downloadStatus == CityDownloadStatus.ready;
        return worldSaved || downloadReady;
      },
      listener: (context, _) => Navigator.of(context).pop(),
      child: BlocBuilder<TvLocationPickerCubit, TvLocationPickerState>(
        builder: (context, pickerState) =>
            BlocBuilder<LocationSelectionCubit, LocationSelectionState>(
              builder: (context, selState) =>
                  _Body(pickerState: pickerState, selState: selState),
            ),
      ),
    );
  }
}

class _Body extends StatelessWidget {
  final TvLocationPickerState pickerState;
  final LocationSelectionState selState;
  const _Body({required this.pickerState, required this.selState});

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>().settings;
    final tc = ThemeColors.of(settings.isDarkMode);
    final accent = getThemePalette(settings.themeColorKey).primary;
    final isBusy = selState.downloadStatus == CityDownloadStatus.downloading;
    // Remote BACK is a step-back, not a hard close: from the cities list it
    // returns to the countries list; only from the countries list does it close
    // the dialog. Mirrors the header's on-screen back arrow so D-pad and the
    // visible button behave identically. Blocked while a city download is busy.
    return PopScope(
      canPop: !isBusy && !pickerState.showsCities,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop && !isBusy && pickerState.showsCities) {
          context.read<TvLocationPickerCubit>().showCountries();
        }
      },
      child: Dialog(
        backgroundColor: tc.bgSurface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: BorderSide(color: accent.withValues(alpha: 0.20)),
        ),
        child: SizedBox(
          width: 920,
          height: 660,
          child: pickerState.isLoading
              ? const Center(child: CircularProgressIndicator())
              : Column(
                  children: [
                    TvLocationPickerHeader(
                      title: _title(context),
                      showBack: pickerState.showsCities,
                      onBack: context
                          .read<TvLocationPickerCubit>()
                          .showCountries,
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(24, 0, 24, 18),
                      child: TvLocationSearchField(
                        hintText: _hint(context),
                        onChanged: (q) => _onQueryChanged(context, q),
                      ),
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                        child: pickerState.showsCities
                            ? TvLocationCitiesList(
                                choices: pickerState.cities,
                                currentCountryKey:
                                    pickerState.currentCountryKey,
                                currentCity: pickerState.currentCity,
                                isSaving:
                                    selState.status ==
                                    LocationSelectionStatus.saving,
                              )
                            : TvLocationCountriesList(
                                countries: pickerState.countries,
                                currentCountryKey:
                                    pickerState.currentCountryKey,
                                onSelectOnline: (r) =>
                                    _onSelectOnline(context, r),
                              ),
                      ),
                    ),
                    if (selState.downloadStatus ==
                        CityDownloadStatus.downloading)
                      _DownloadingStrip(tc: tc, accent: accent),
                    if (selState.downloadStatus == CityDownloadStatus.failed)
                      _DownloadErrorStrip(
                        message: selState.downloadError,
                        accent: accent,
                      ),
                  ],
                ),
        ),
      ),
    );
  }

  String _title(BuildContext context) {
    final l = AppLocalizations.of(context);
    return pickerState.showsCities
        ? l.settingsSelectCity
        : l.settingsSelectCountry;
  }

  String _hint(BuildContext context) {
    final l = AppLocalizations.of(context);
    return pickerState.showsCities
        ? l.settingsSearchCity
        : l.settingsSearchCountry;
  }

  void _onQueryChanged(BuildContext context, String q) {
    context.read<TvLocationPickerCubit>().updateQuery(q);
    if (pickerState.showsCities) {
      context.read<OnlineGeocodingCubit>().clear();
    } else {
      context.read<OnlineGeocodingCubit>().searchDebounced(q);
    }
  }

  Future<void> _onSelectOnline(
    BuildContext context,
    OnlineGeocodingResult picked,
  ) async {
    await TvOnlineLocationFlow(
      selectionCubit: context.read<LocationSelectionCubit>(),
      rootNavigator: Navigator.of(context, rootNavigator: true),
      contextGetter: () => context,
      isContextMounted: () => context.mounted,
    ).runFrom(picked);
  }
}

class _DownloadingStrip extends StatelessWidget {
  final ThemeColors tc;
  final Color accent;
  const _DownloadingStrip({required this.tc, required this.accent});

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 20),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(
          width: 18,
          height: 18,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation(accent),
          ),
        ),
        const SizedBox(width: 12),
        Text(
          'جارٍ تحميل بيانات المدينة...',
          style: TextStyle(color: tc.textSecondary, fontSize: 14),
        ),
      ],
    ),
  );
}

class _DownloadErrorStrip extends StatelessWidget {
  final String? message;
  final Color accent;
  const _DownloadErrorStrip({required this.message, required this.accent});

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 20),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Icons.error_outline, color: Colors.redAccent, size: 18),
        const SizedBox(width: 10),
        Text(
          message ?? 'تعذّر تحميل بيانات المدينة',
          style: const TextStyle(color: Colors.redAccent, fontSize: 14),
        ),
        const SizedBox(width: 16),
        TextButton(
          onPressed: () => context.read<LocationSelectionCubit>().retry(),
          child: Text('إعادة المحاولة', style: TextStyle(color: accent)),
        ),
      ],
    ),
  );
}
