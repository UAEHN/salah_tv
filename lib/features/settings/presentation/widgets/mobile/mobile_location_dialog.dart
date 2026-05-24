import 'dart:async';

import 'package:flutter/material.dart';
import 'package:ghasaq/l10n/app_localizations.dart';

import '../../../../../core/city_translations.dart';
import '../../../../../injection.dart';
import '../../../domain/i_world_city_repository.dart';
import '../../../domain/usecases/resolve_calculation_method_for_iso_usecase.dart';
import '../../../domain/usecases/resolve_timezone_for_coords_usecase.dart';
import '../../logic/location_dialog_filter_controller.dart';
import '../../logic/merged_city_results.dart';
import '../../logic/remote_city_search_controller.dart';
import 'mobile_location_dialog_body.dart';
import 'mobile_location_dialog_callbacks.dart';
import 'mobile_location_search_utils.dart';

class MobileLocationDialog extends StatefulWidget {
  final String currentCountry;
  final String currentCity;
  final DbSaveCallback onSave;
  final WorldSaveCallback? onSaveWorld;

  const MobileLocationDialog({
    super.key,
    required this.currentCountry,
    required this.currentCity,
    required this.onSave,
    this.onSaveWorld,
  });

  @override
  State<MobileLocationDialog> createState() => _MobileLocationDialogState();
}

class _MobileLocationDialogState extends State<MobileLocationDialog> {
  late final TextEditingController _searchController;
  Timer? _debounce;
  late final LocationDialogCallbacks _callbacks;
  late final RemoteCitySearchController _remoteController;
  final LocationDialogFilterController _filter =
      LocationDialogFilterController();

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _filter
      ..initWithDbOnly()
      ..onChanged = _rebuild;
    _callbacks = LocationDialogCallbacks(
      getSelectedCountryKey: () => _filter.selectedCountryKey,
      onSave: widget.onSave,
      onSaveWorld: widget.onSaveWorld,
      contextGetter: () => context,
      isMounted: () => mounted,
      resolveMethod: getIt<ResolveCalculationMethodForIsoUseCase>(),
      resolveTimezone: getIt<ResolveTimezoneForCoordsUseCase>(),
    );
    _remoteController = RemoteCitySearchController(getIt())
      ..onChanged = _rebuild;
    _filter.loadWorld(getIt<IWorldCityRepository>(), _searchController.text);
  }

  void _rebuild() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _remoteController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _onQueryChanged(String query) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      if (!mounted) return;
      _filter.applyQuery(query);
      if (_filter.selectedCountryKey == null) _remoteController.search(query);
    });
  }

  void _onClear() {
    _debounce?.cancel();
    _searchController.clear();
    _filter.applyQuery('');
    _remoteController.search('');
  }

  void _showCountries() {
    _debounce?.cancel();
    _searchController.clear();
    _remoteController.search('');
    _filter.resetToCountries();
  }

  void _selectCountry(String key) {
    _debounce?.cancel();
    _searchController.clear();
    FocusManager.instance.primaryFocus?.unfocus();
    _filter.selectCountry(key);
  }

  String _resolveTitle(AppLocalizations l) {
    final k = _filter.selectedCountryKey;
    if (k == null) return l.settingsSelectCountry;
    final isEn = l.localeName == 'en';
    final matched = _filter.allCountries.cast<UnifiedCountry?>().firstWhere(
      (c) => c!.key == k,
      orElse: () => null,
    );
    return (isEn ? matched?.englishName : matched?.arabicName) ??
        countryLabel(k, locale: l.localeName);
  }

  @override
  Widget build(BuildContext context) {
    final mixedRows = mergeLocalAndRemote(
      _filter.filteredAllWorldCities,
      _remoteController.results,
    );
    return MobileLocationDialogBody(
      selectedCountryKey: _filter.selectedCountryKey,
      isSelectedCountryDb: _filter.isSelectedCountryDb,
      currentCountry: widget.currentCountry,
      currentCity: widget.currentCity,
      title: _resolveTitle(AppLocalizations.of(context)),
      searchController: _searchController,
      filteredCountries: _filter.filteredCountries,
      filteredDbCities: _filter.filteredDbCities,
      filteredWorldCities: _filter.filteredWorldCities,
      mixedCityRows: mixedRows,
      remoteLoading: _remoteController.loading,
      onQueryChanged: _onQueryChanged,
      onClear: _onClear,
      onShowCountries: _showCountries,
      onSelectCountry: _selectCountry,
      onSelectDbCity: _callbacks.selectDbCity,
      onSelectWorldCity: _callbacks.selectWorldCity,
      onSelectRemoteCity: _callbacks.selectRemoteCity,
      onLocationDetected: _callbacks.onLocationDetected,
    );
  }
}
