import 'package:flutter_bloc/flutter_bloc.dart';

import '../../analytics/domain/i_analytics_service.dart';
import '../../settings/domain/entities/detected_location.dart';
import '../../settings/domain/entities/world_city.dart';
import '../../settings/domain/i_settings_repository.dart';
import '../../settings/domain/i_world_city_repository.dart';
import '../../settings/presentation/settings_provider.dart';
import '../../settings/presentation/widgets/mobile/mobile_location_search_utils.dart';
import 'onboarding_completion_service.dart';
import 'onboarding_country_loader.dart';
import 'onboarding_filter_controller.dart';
import 'onboarding_state.dart';
import 'onboarding_state_mapper.dart';

export 'onboarding_state.dart';

class OnboardingCubit extends Cubit<OnboardingState> {
  final SettingsProvider _settingsProvider;
  final OnboardingCountryLoader _countryLoader;
  final OnboardingCompletionService _completion;
  final OnboardingFilterController _filterController;
  final IAnalyticsService? _analytics;

  OnboardingCubit({
    required SettingsProvider settingsProvider,
    required OnboardingCountryLoader countryLoader,
    required OnboardingCompletionService completionService,
    required OnboardingFilterController filterController,
    IAnalyticsService? analytics,
  }) : _settingsProvider = settingsProvider,
       _countryLoader = countryLoader,
       _completion = completionService,
       _filterController = filterController,
       _analytics = analytics,
       super(const OnboardingState()) {
    _initCountries();
  }

  factory OnboardingCubit.fromDependencies({
    required SettingsProvider settingsProvider,
    required IWorldCityRepository worldRepo,
    required ISettingsRepository settingsRepository,
    IAnalyticsService? analytics,
  }) {
    return OnboardingCubit(
      settingsProvider: settingsProvider,
      countryLoader: OnboardingCountryLoader(worldRepo),
      completionService: OnboardingCompletionService(
        settingsProvider,
        settingsRepository,
      ),
      filterController: OnboardingFilterController(),
      analytics: analytics,
    );
  }

  Future<void> _initCountries() async {
    final result = await _countryLoader.load();
    if (isClosed) return;
    emit(
      state.copyWith(
        worldRepo: result.worldRepo,
        allCountries: result.countries,
        filteredCountries: result.countries,
      ),
    );
  }

  void selectLanguage(String locale) {
    emit(state.copyWith(locale: locale));
    _settingsProvider.updateLocale(locale);
  }

  void advanceToCountry() {
    emit(state.copyWith(step: 1, filteredCountries: state.allCountries));
  }

  void selectCountry(String key) {
    emit(mapCountrySelectionState(state, key));
  }

  void goBackToCountry() {
    emit(
      state.copyWith(
        step: 1,
        filteredCountries: state.allCountries,
        clearCity: true,
      ),
    );
  }

  void filterCountries(String query) {
    _filterController.runDebounced(() {
      if (isClosed) return;
      emit(
        state.copyWith(
          filteredCountries: filterUnifiedCountries(query, state.allCountries),
        ),
      );
    });
  }

  void filterCities(String query) {
    _filterController.runDebounced(() {
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

  void selectDbCity(String key) => emit(state.copyWith(selectedCityKey: key));

  void selectWorldCity(WorldCity city) =>
      emit(state.copyWith(selectedWorldCity: city));

  Future<void> onLocationDetected(DetectedLocation location) async {
    emit(mapDetectedLocationState(state, location));
    await complete();
  }

  Future<void> complete() async {
    emit(state.copyWith(isLoading: true));
    await _completion.persistSelection(state);
    if (isClosed) return;
    _analytics?.logOnboardingCompleted(
      state.selectedCountryKey ?? '',
      state.selectedCityKey ?? state.selectedWorldCity?.name ?? '',
    );
    emit(state.copyWith(isLoading: false, isComplete: true));
  }

  @override
  Future<void> close() {
    _filterController.dispose();
    return super.close();
  }
}
