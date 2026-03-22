import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import '../../../../../core/city_translations.dart';
import '../../../../../core/mobile_theme.dart';
import 'mobile_location_cities_list.dart';
import 'mobile_location_countries_list.dart';
import 'mobile_location_dialog_header.dart';
import 'mobile_location_search_field.dart';
import 'mobile_location_search_utils.dart';

class MobileLocationDialog extends StatefulWidget {
  final String currentCountry;
  final String currentCity;
  final Future<void> Function(String country, String city) onSave;

  const MobileLocationDialog({
    super.key,
    required this.currentCountry,
    required this.currentCity,
    required this.onSave,
  });

  @override
  State<MobileLocationDialog> createState() => _MobileLocationDialogState();
}

class _MobileLocationDialogState extends State<MobileLocationDialog> {
  String? _selectedCountryKey;
  late final TextEditingController _searchController;
  Timer? _debounce;
  late List<CountryInfo> _filteredCountries;
  List<String> _filteredCities = [];

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _filteredCountries = filterCountries('');
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
      setState(() {
        if (_selectedCountryKey != null) {
          _filteredCities = filterCities(_selectedCountryKey!, query);
        } else {
          _filteredCountries = filterCountries(query);
        }
      });
    });
  }

  void _onClear() {
    _debounce?.cancel();
    _searchController.clear();
    setState(() {
      if (_selectedCountryKey != null) {
        _filteredCities = filterCities(_selectedCountryKey!, '');
      } else {
        _filteredCountries = filterCountries('');
      }
    });
  }

  void _showCountries() {
    _debounce?.cancel();
    _searchController.clear();
    setState(() {
      _selectedCountryKey = null;
      _filteredCities = [];
      _filteredCountries = filterCountries('');
    });
  }

  void _selectCountry(String countryKey) {
    _debounce?.cancel();
    _searchController.clear();
    setState(() {
      _selectedCountryKey = countryKey;
      _filteredCities = filterCities(countryKey, '');
    });
  }

  Future<void> _selectCity(String cityKey) async {
    await widget.onSave(_selectedCountryKey!, cityKey);
    if (!mounted) return;
    Navigator.of(context).pop();
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
          borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
          border: Border.all(color: MobileColors.border(context)),
        ),
        child: Column(
          children: [
            MobileLocationDialogHeader(
              showCities: showCities,
              title: showCities
                  ? countryLabel(_selectedCountryKey!)
                  : 'اختر الدولة',
              onBack: _showCountries,
              onClose: () => Navigator.pop(context),
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
                child: showCities
                    ? MobileLocationCitiesList(
                        cities: _filteredCities,
                        currentCountry: widget.currentCountry,
                        currentCity: widget.currentCity,
                        selectedCountryKey: _selectedCountryKey!,
                        onSelect: _selectCity,
                      )
                    : MobileLocationCountriesList(
                        countries: _filteredCountries,
                        currentCountry: widget.currentCountry,
                        onSelect: _selectCountry,
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
