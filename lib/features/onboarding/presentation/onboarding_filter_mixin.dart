import 'package:flutter_bloc/flutter_bloc.dart';

import '../../settings/presentation/widgets/mobile/mobile_location_search_utils.dart';
import 'onboarding_filter_controller.dart';
import 'onboarding_state.dart';

/// Country/city filter handlers, debounced through [OnboardingFilterController].
/// Split out of [OnboardingCubit] to honor the 150-line cap. Implementers
/// must expose [filterController] so the mixin can debounce and dispose it.
mixin OnboardingFilterMixin on Cubit<OnboardingState> {
  OnboardingFilterController get filterController;

  void filterCountries(String query) {
    filterController.runDebounced(() {
      if (isClosed) return;
      emit(
        state.copyWith(
          filteredCountries: filterUnifiedCountries(query, state.allCountries),
        ),
      );
    });
  }

  void filterCities(String query) {
    filterController.runDebounced(() {
      if (isClosed || state.selectedCountryKey == null) return;
      if (state.isSelectedCountryDb) {
        emit(
          state.copyWith(
            filteredDbCities: filterDbCities(state.selectedCountryKey!, query),
          ),
        );
        return;
      }
      if (state.worldRepo != null) {
        emit(
          state.copyWith(
            filteredWorldCities: filterWorldCities(
              state.selectedCountryKey!,
              query,
              state.worldRepo!,
            ),
          ),
        );
      }
    });
  }
}
