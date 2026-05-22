import 'package:flutter/material.dart';
import '../../../../../core/mobile_theme.dart';
import '../../../domain/entities/detected_location.dart';
import '../../../domain/entities/world_city.dart';
import 'mobile_location_cities_list.dart';
import 'mobile_location_world_cities_list.dart';
import 'mobile_location_countries_list.dart';
import 'mobile_location_dialog_header.dart';
import 'mobile_location_search_field.dart';
import 'mobile_location_search_utils.dart';
import 'mobile_detect_location_button.dart';

class MobileLocationDialogBody extends StatelessWidget {
  final String? selectedCountryKey;
  final bool isSelectedCountryDb;
  final String currentCountry;
  final String currentCity;
  final String title;
  final TextEditingController searchController;
  final List<UnifiedCountry> filteredCountries;
  final List<String> filteredDbCities;
  final List<WorldCity> filteredWorldCities;
  final ValueChanged<String> onQueryChanged;
  final VoidCallback onClear;
  final VoidCallback onShowCountries;
  final ValueChanged<String> onSelectCountry;
  final ValueChanged<String> onSelectDbCity;
  final ValueChanged<WorldCity> onSelectWorldCity;
  final Future<void> Function(DetectedLocation) onLocationDetected;

  const MobileLocationDialogBody({
    super.key,
    required this.selectedCountryKey,
    required this.isSelectedCountryDb,
    required this.currentCountry,
    required this.currentCity,
    required this.title,
    required this.searchController,
    required this.filteredCountries,
    required this.filteredDbCities,
    required this.filteredWorldCities,
    required this.onQueryChanged,
    required this.onClear,
    required this.onShowCountries,
    required this.onSelectCountry,
    required this.onSelectDbCity,
    required this.onSelectWorldCity,
    required this.onLocationDetected,
  });

  @override
  Widget build(BuildContext context) {
    final showCities = selectedCountryKey != null;
    final mq = MediaQuery.of(context);
    final kb = mq.viewInsets.bottom;
    // Lift the sheet above the keyboard by adding bottom padding equal to
    // the keyboard inset, and resize it to fill the area above the
    // keyboard so the list keeps room to scroll instead of vanishing
    // under it.
    final restingHeight = mq.size.height * 0.78;
    final keyboardOpenHeight =
        (mq.size.height - kb - mq.padding.top - 16).clamp(320.0, double.infinity);
    final sheetHeight = kb > 0 ? keyboardOpenHeight : restingHeight;
    return AnimatedPadding(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOutCubic,
      padding: EdgeInsets.only(bottom: kb),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOutCubic,
        height: sheetHeight,
        decoration: BoxDecoration(
          color: MobileColors.cardColor(context),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          border: Border(
            top: BorderSide(color: MobileColors.border(context), width: 1),
          ),
        ),
        child: Column(
          children: [
          MobileLocationDialogHeader(
            showCities: showCities,
            title: title,
            onBack: onShowCountries,
            onClose: () => Navigator.pop(context),
          ),
          MobileLocationSearchField(
            controller: searchController,
            hintText: locationSearchHint(context, showCities),
            onChanged: onQueryChanged,
            onClear: onClear,
            showClearIcon: true,
          ),
          if (!showCities)
            MobileDetectLocationButton(onDetected: onLocationDetected),
            Expanded(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 280),
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
    if (selectedCountryKey == null) {
      return MobileLocationCountriesList(
        countries: filteredCountries,
        currentCountry: currentCountry,
        onSelect: onSelectCountry,
      );
    }
    if (isSelectedCountryDb) {
      return MobileLocationCitiesList(
        cities: filteredDbCities,
        currentCountry: currentCountry,
        currentCity: currentCity,
        selectedCountryKey: selectedCountryKey!,
        onSelect: onSelectDbCity,
      );
    }
    return MobileLocationWorldCitiesList(
      cities: filteredWorldCities,
      currentCountry: currentCountry,
      currentCity: currentCity,
      selectedCountryKey: selectedCountryKey!,
      onSelect: onSelectWorldCity,
    );
  }
}
