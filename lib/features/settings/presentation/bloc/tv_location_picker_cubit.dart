import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/city_translations.dart';
import '../../domain/i_world_city_repository.dart';
import '../logic/location_picker_logic.dart';
import 'location_choice.dart';
import 'tv_location_picker_state.dart';

class TvLocationPickerCubit extends Cubit<TvLocationPickerState> {
  final IWorldCityRepository _worldRepo;
  List<UnifiedCountry> _allCountries = const [];
  List<LocationChoice> _countryChoices = const [];

  TvLocationPickerCubit(
    this._worldRepo, {
    required String currentCountry,
    required String currentCity,
  }) : super(
         TvLocationPickerState.loading(
           currentCountryKey: normalizeCountryKey(currentCountry),
           currentCity: currentCity,
         ),
       );

  Future<void> load({bool showCitiesForCurrentCountry = false}) async {
    // TV shows only DB-backed countries — no GPS / calculated-mode support.
    _allCountries = buildUnifiedCountries(null);
    emit(
      state.copyWith(
        status: TvLocationPickerStatus.ready,
        countries: _allCountries,
        cities: const [],
        query: '',
        clearSelectedCountry: true,
      ),
    );
    if (showCitiesForCurrentCountry) {
      openCurrentCountryCities();
    }
  }

  void updateQuery(String query) {
    if (state.showsCities) {
      emit(
        state.copyWith(
          query: query,
          cities: filterLocationChoices(query, _countryChoices),
        ),
      );
      return;
    }
    emit(
      state.copyWith(
        query: query,
        countries: filterUnifiedCountries(query, _allCountries),
      ),
    );
  }

  void selectCountry(UnifiedCountry country) {
    _countryChoices = buildCountryChoices(country, _worldRepo);
    emit(
      state.copyWith(
        query: '',
        selectedCountry: country,
        cities: _countryChoices,
      ),
    );
  }

  void showCountries() {
    _countryChoices = const [];
    emit(
      state.copyWith(
        query: '',
        countries: _allCountries,
        cities: const [],
        clearSelectedCountry: true,
      ),
    );
  }

  void openCurrentCountryCities() {
    UnifiedCountry? currentCountry;
    for (final country in _allCountries) {
      if (normalizeCountryKey(country.key) == state.currentCountryKey) {
        currentCountry = country;
        break;
      }
    }
    if (currentCountry == null) return;
    selectCountry(currentCountry);
  }
}
