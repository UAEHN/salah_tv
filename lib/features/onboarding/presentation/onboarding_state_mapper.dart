import '../../../core/city_translations.dart';
import '../../settings/domain/entities/detected_location.dart';
import '../../settings/domain/entities/world_city.dart';
import '../../settings/presentation/widgets/mobile/mobile_location_search_utils.dart';
import 'onboarding_state.dart';

OnboardingState mapCountrySelectionState(OnboardingState state, String key) {
  final isDb = kDbCountryKeys.contains(key);
  if (isDb) {
    return state.copyWith(
      step: 2,
      selectedCountryKey: key,
      isSelectedCountryDb: true,
      filteredDbCities: filterDbCities(key, ''),
      clearCity: true,
    );
  }

  final cities = state.worldRepo != null
      ? filterWorldCities(key, '', state.worldRepo!)
      : <WorldCity>[];
  return state.copyWith(
    step: 2,
    selectedCountryKey: key,
    isSelectedCountryDb: false,
    filteredWorldCities: cities,
    clearCity: true,
  );
}

OnboardingState mapDetectedLocationState(
  OnboardingState state,
  DetectedLocation loc,
) {
  if (loc.isInDb) {
    return state.copyWith(
      selectedCountryKey: loc.dbCountryKey,
      isSelectedCountryDb: true,
      selectedCityKey: loc.dbCityKey,
    );
  }

  return state.copyWith(
    selectedCountryKey: loc.isoCountryCode ?? '',
    isSelectedCountryDb: false,
    selectedWorldCity: WorldCity(
      name: loc.cityName,
      arabicName: loc.cityName,
      countryKey: loc.isoCountryCode ?? '',
      countryArabic: loc.countryName,
      latitude: loc.latitude,
      longitude: loc.longitude,
      calculationMethod: 'muslim_world_league',
      utcOffset: 0,
    ),
  );
}
