import '../logic/location_picker_logic.dart';
import 'location_choice.dart';

enum TvLocationPickerStatus { loading, ready }

class TvLocationPickerState {
  final TvLocationPickerStatus status;
  final String query;
  final UnifiedCountry? selectedCountry;
  final List<UnifiedCountry> countries;
  final List<LocationChoice> cities;
  final String currentCountryKey;
  final String currentCity;

  const TvLocationPickerState({
    required this.status,
    required this.query,
    required this.selectedCountry,
    required this.countries,
    required this.cities,
    required this.currentCountryKey,
    required this.currentCity,
  });

  factory TvLocationPickerState.loading({
    required String currentCountryKey,
    required String currentCity,
  }) {
    return TvLocationPickerState(
      status: TvLocationPickerStatus.loading,
      query: '',
      selectedCountry: null,
      countries: const [],
      cities: const [],
      currentCountryKey: currentCountryKey,
      currentCity: currentCity,
    );
  }

  bool get isLoading => status == TvLocationPickerStatus.loading;
  bool get showsCities => selectedCountry != null;

  TvLocationPickerState copyWith({
    TvLocationPickerStatus? status,
    String? query,
    UnifiedCountry? selectedCountry,
    bool clearSelectedCountry = false,
    List<UnifiedCountry>? countries,
    List<LocationChoice>? cities,
  }) {
    return TvLocationPickerState(
      status: status ?? this.status,
      query: query ?? this.query,
      selectedCountry: clearSelectedCountry
          ? null
          : (selectedCountry ?? this.selectedCountry),
      countries: countries ?? this.countries,
      cities: cities ?? this.cities,
      currentCountryKey: currentCountryKey,
      currentCity: currentCity,
    );
  }
}
