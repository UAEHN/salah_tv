import 'dart:async';

import 'package:flutter/material.dart';
import 'package:ghasaq/l10n/app_localizations.dart';

import '../../../../../core/city_translations.dart';
import '../../../../../core/country_name_resolver.dart';
import '../../../../../injection.dart';
import '../../../data/online_result_to_detected_location.dart';
import '../../../domain/entities/online_geocoding_result.dart';
import '../../../domain/entities/world_city.dart';
import '../../../domain/i_online_geocoding_repository.dart';
import '../../../domain/i_world_city_repository.dart';
import '../../bloc/online_geocoding_cubit.dart';
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
  String? _selectedCountryKey;
  bool _isSelectedCountryDb = true;
  late final TextEditingController _searchController;
  Timer? _debounce;
  late final LocationDialogCallbacks _callbacks;
  late final OnlineGeocodingCubit _onlineCubit;

  IWorldCityRepository? _worldRepo;
  List<UnifiedCountry> _allCountries = [];
  late List<UnifiedCountry> _filteredCountries;
  List<String> _filteredDbCities = [];
  List<WorldCity> _filteredWorldCities = [];
  OnlineGeocodingState _onlineState = OnlineGeocodingState.idle;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _allCountries = buildUnifiedCountries(null);
    _filteredCountries = _allCountries;
    _callbacks = LocationDialogCallbacks(
      getSelectedCountryKey: () => _selectedCountryKey,
      onSave: widget.onSave,
      onSaveWorld: widget.onSaveWorld,
      contextGetter: () => context,
      isMounted: () => mounted,
    );
    _onlineCubit = OnlineGeocodingCubit(getIt<IOnlineGeocodingRepository>());
    _onlineCubit.stream.listen((state) {
      if (mounted) setState(() => _onlineState = state);
    });
    _loadWorldCities();
  }

  Future<void> _loadWorldCities() async {
    final repo = getIt<IWorldCityRepository>();
    await repo.initialize();
    if (!mounted) return;
    setState(() {
      _worldRepo = repo;
      _allCountries = buildUnifiedCountries(repo);
      _filteredCountries = filterUnifiedCountries(
        _searchController.text,
        _allCountries,
      );
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _onlineCubit.close();
    _searchController.dispose();
    super.dispose();
  }

  void _onQueryChanged(String query) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      if (!mounted) return;
      setState(() => _filter(query));
      _maybeRunOnlineSearch(query);
    });
  }

  /// Runs Nominatim search at every picker level. When a country is selected
  /// we bias results to that country's ISO so users can find any town inside
  /// it that's missing from the bundled DB/world catalog. Disabled only when
  /// the host screen has no `onSaveWorld` callback (no way to persist).
  void _maybeRunOnlineSearch(String query) {
    if (widget.onSaveWorld == null) {
      _onlineCubit.clear();
      return;
    }
    _onlineCubit.searchDebounced(query, countryCode: _selectedCountryIsoBias());
  }

  String? _selectedCountryIsoBias() {
    final k = _selectedCountryKey;
    if (k == null) return null;
    // DB countries use slug keys ("uae"); world entries already use ISO ("DE").
    return _isSelectedCountryDb ? isoForDbCountryKey(k) : k;
  }

  void _onClear() {
    _resetSearch();
    setState(() => _filter(''));
    _onlineCubit.clear();
  }

  void _resetSearch() {
    _debounce?.cancel();
    _searchController.clear();
  }

  void _showCountries() {
    _resetSearch();
    _onlineCubit.clear();
    setState(() {
      _selectedCountryKey = null;
      _filteredDbCities = [];
      _filteredWorldCities = [];
      _filteredCountries = filterUnifiedCountries('', _allCountries);
    });
  }

  void _selectCountry(String key) {
    _resetSearch();
    _onlineCubit.clear();
    FocusManager.instance.primaryFocus?.unfocus();
    final isDb = isDbCountry(key);
    setState(() {
      _selectedCountryKey = key;
      _isSelectedCountryDb = isDb;
      if (isDb) {
        _filteredDbCities = filterDbCities(key, '');
      } else if (_worldRepo != null) {
        _filteredWorldCities = filterWorldCities(key, '', _worldRepo!);
      }
    });
  }

  void _filter(String query) {
    if (_selectedCountryKey == null) {
      _filteredCountries = filterUnifiedCountries(query, _allCountries);
    } else if (_isSelectedCountryDb) {
      _filteredDbCities = filterDbCities(_selectedCountryKey!, query);
    } else if (_worldRepo != null) {
      _filteredWorldCities = filterWorldCities(
        _selectedCountryKey!,
        query,
        _worldRepo!,
      );
    }
  }

  Future<void> _selectOnlineResult(OnlineGeocodingResult r) async {
    // Unified pipeline: same matchers GPS uses (LocationCountryMatcher →
    // LocationCityMatcher → nearest world city fallback) so search picks and
    // GPS detections produce identical DetectedLocation for the same place.
    final detected = await detectedLocationFromOnlineResult(
      r,
      worldRepo: _worldRepo,
    );
    await _callbacks.onLocationDetected(detected);
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final k = _selectedCountryKey;
    final isEn = l.localeName == 'en';
    final matched = k != null
        ? _allCountries.cast<UnifiedCountry?>().firstWhere(
            (c) => c!.key == k,
            orElse: () => null,
          )
        : null;
    final title = k != null
        ? ((isEn ? matched?.englishName : matched?.arabicName) ??
              countryLabel(k, locale: l.localeName))
        : l.settingsSelectCountry;

    return MobileLocationDialogBody(
      selectedCountryKey: k,
      isSelectedCountryDb: _isSelectedCountryDb,
      currentCountry: widget.currentCountry,
      currentCity: widget.currentCity,
      title: title,
      searchController: _searchController,
      filteredCountries: _filteredCountries,
      filteredDbCities: _filteredDbCities,
      filteredWorldCities: _filteredWorldCities,
      onlineState: _onlineState,
      onQueryChanged: _onQueryChanged,
      onClear: _onClear,
      onShowCountries: _showCountries,
      onSelectCountry: _selectCountry,
      onSelectDbCity: _callbacks.selectDbCity,
      onSelectWorldCity: _callbacks.selectWorldCity,
      onLocationDetected: _callbacks.onLocationDetected,
      onSelectOnline: _selectOnlineResult,
    );
  }
}
