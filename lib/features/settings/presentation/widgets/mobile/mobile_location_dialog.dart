import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import '../../../../../core/city_translations.dart';
import '../../../../../core/mobile_theme.dart';
import '../../../../../injection.dart';
import '../../../../prayer/data/calculation_method_map.dart';
import '../../../domain/entities/detected_location.dart';
import '../../../domain/entities/world_city.dart';
import '../../../domain/i_world_city_repository.dart';
import 'mobile_location_cities_list.dart';
import 'mobile_location_world_cities_list.dart';
import 'mobile_location_countries_list.dart';
import 'mobile_location_dialog_header.dart';
import 'mobile_location_search_field.dart';
import 'mobile_location_search_utils.dart';
import 'mobile_detect_location_button.dart';

class MobileLocationDialog extends StatefulWidget {
  final String currentCountry;
  final String currentCity;

  /// Called when user selects a DB location (country + city keys).
  final Future<void> Function(String country, String city) onSave;

  /// Called when user selects a worldwide location (GPS or manual).
  final Future<void> Function(
    String country,
    String city,
    double lat,
    double lng,
    String method, {
    double? utcOffsetHours,
  })? onSaveWorld;

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

  IWorldCityRepository? _worldRepo;
  List<UnifiedCountry> _allCountries = [];
  late List<UnifiedCountry> _filteredCountries;
  List<String> _filteredDbCities = [];
  List<WorldCity> _filteredWorldCities = [];

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _allCountries = buildUnifiedCountries(null);
    _filteredCountries = _allCountries;
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
    _searchController.dispose();
    super.dispose();
  }

  void _onQueryChanged(String query) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      if (!mounted) return;
      setState(() => _applyFilter(query));
    });
  }

  void _applyFilter(String query) {
    if (_selectedCountryKey == null) {
      _filteredCountries = filterUnifiedCountries(query, _allCountries);
    } else if (_isSelectedCountryDb) {
      _filteredDbCities = filterDbCities(_selectedCountryKey!, query);
    } else if (_worldRepo != null) {
      _filteredWorldCities = filterWorldCities(
        _selectedCountryKey!, query, _worldRepo!,
      );
    }
  }

  void _onClear() {
    _debounce?.cancel();
    _searchController.clear();
    setState(() => _applyFilter(''));
  }

  void _showCountries() {
    _debounce?.cancel();
    _searchController.clear();
    setState(() {
      _selectedCountryKey = null;
      _filteredDbCities = [];
      _filteredWorldCities = [];
      _filteredCountries = filterUnifiedCountries('', _allCountries);
    });
  }

  void _selectCountry(String countryKey) {
    _debounce?.cancel();
    _searchController.clear();
    final isDb = isDbCountry(countryKey);
    setState(() {
      _selectedCountryKey = countryKey;
      _isSelectedCountryDb = isDb;
      if (isDb) {
        _filteredDbCities = filterDbCities(countryKey, '');
      } else if (_worldRepo != null) {
        _filteredWorldCities = filterWorldCities(
          countryKey, '', _worldRepo!,
        );
      }
    });
  }

  Future<void> _selectDbCity(String cityKey) async {
    await widget.onSave(_selectedCountryKey!, cityKey);
    if (!mounted) return;
    Navigator.of(context).pop();
  }

  Future<void> _selectWorldCity(WorldCity city) async {
    if (widget.onSaveWorld == null) return;
    await widget.onSaveWorld!(
      city.countryArabic,
      city.arabicName,
      city.latitude,
      city.longitude,
      city.calculationMethod,
      utcOffsetHours: city.utcOffset,
    );
    if (!mounted) return;
    Navigator.of(context).pop();
  }

  Future<void> _onLocationDetected(DetectedLocation location) async {
    if (location.isInDb) {
      await widget.onSave(location.dbCountryKey!, location.dbCityKey!);
    } else if (widget.onSaveWorld != null) {
      await widget.onSaveWorld!(
        location.countryName,
        location.cityName,
        location.latitude,
        location.longitude,
        defaultMethodForCountryIso(location.isoCountryCode),
      );
    }
    if (!mounted) return;
    Navigator.of(context).pop();
  }

  String _countryTitle() {
    final match = _allCountries.where(
      (c) => c.key == _selectedCountryKey,
    );
    if (match.isNotEmpty) return match.first.arabicName;
    return countryLabel(_selectedCountryKey!);
  }

  @override
  Widget build(BuildContext context) {
    final showCities = _selectedCountryKey != null;

    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
      child: Container(
        height: MediaQuery.of(context).size.height * 0.75,
        decoration: BoxDecoration(
          color: MobileColors.cardColor(context),
          borderRadius:
              const BorderRadius.vertical(top: Radius.circular(32)),
          border: Border.all(color: MobileColors.border(context)),
        ),
        child: Column(
          children: [
            MobileLocationDialogHeader(
              showCities: showCities,
              title: showCities ? _countryTitle() : 'اختر الدولة',
              onBack: _showCountries,
              onClose: () => Navigator.pop(context),
            ),
            if (!showCities)
              MobileDetectLocationButton(
                onDetected: _onLocationDetected,
              ),
            MobileLocationSearchField(
              controller: _searchController,
              hintText: locationSearchHint(showCities),
              onChanged: _onQueryChanged,
              onClear: _onClear,
            ),
            Expanded(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                switchInCurve: Curves.easeOutCubic,
                switchOutCurve: Curves.easeInCubic,
                child: _buildList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildList() {
    if (_selectedCountryKey == null) {
      return MobileLocationCountriesList(
        countries: _filteredCountries,
        currentCountry: widget.currentCountry,
        onSelect: _selectCountry,
      );
    }
    if (_isSelectedCountryDb) {
      return MobileLocationCitiesList(
        cities: _filteredDbCities,
        currentCountry: widget.currentCountry,
        currentCity: widget.currentCity,
        selectedCountryKey: _selectedCountryKey!,
        onSelect: _selectDbCity,
      );
    }
    return MobileLocationWorldCitiesList(
      cities: _filteredWorldCities,
      currentCountry: widget.currentCountry,
      currentCity: widget.currentCity,
      selectedCountryKey: _selectedCountryKey!,
      onSelect: _selectWorldCity,
    );
  }
}
