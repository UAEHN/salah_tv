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
    // Render DB-backed countries immediately so the picker isn't blank
    // while the world catalogue loads from the asset bundle.
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
    // Then await the world catalogue (`world_cities.json`) — without this
    // `_worldRepo.countries` returns const [] and only DB countries show.
    // Mobile follows the same 2-stage pattern in MobileLocationDialog.
    await _worldRepo.initialize();
    if (isClosed) return;
    // TV allowlist is applied inside buildUnifiedCountries via kIsTV — see
    // location_picker_logic.dart. No filtering needed here.
    _allCountries = buildUnifiedCountries(_worldRepo);
    if (state.showsCities) return;
    // Retry: world-allowlist countries (TR/FR) weren't in the DB-only set on
    // the first pass, so the earlier openCurrentCountryCities() silently
    // failed and the dialog is still stuck on countries-view. Now that the
    // world catalogue is loaded, the lookup succeeds and jumps to cities.
    if (showCitiesForCurrentCountry) {
      openCurrentCountryCities();
      if (state.showsCities) return;
    }
    emit(
      state.copyWith(
        countries: filterUnifiedCountries(state.query, _allCountries),
      ),
    );
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
