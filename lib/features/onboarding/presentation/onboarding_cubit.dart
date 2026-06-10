import 'package:flutter_bloc/flutter_bloc.dart';

import '../../analytics/domain/i_analytics_service.dart';
import '../../settings/domain/entities/detected_location.dart';
import '../../settings/domain/entities/world_city.dart';
import '../../settings/presentation/settings_provider.dart';
import 'onboarding_completion_service.dart';
import 'onboarding_country_loader.dart';
import 'onboarding_filter_controller.dart';
import 'onboarding_filter_mixin.dart';
import 'onboarding_state.dart';
import 'onboarding_state_mapper.dart';

export 'onboarding_state.dart';

class OnboardingCubit extends Cubit<OnboardingState>
    with OnboardingFilterMixin {
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

  @override
  OnboardingFilterController get filterController => _filterController;

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

  /// Selects the language and advances to the country step atomically.
  /// Using a single emit avoids a race condition where the locale change
  /// triggers a widget rebuild that invalidates the caller's context before
  /// [advanceToCountry] can be dispatched separately.
  void selectLanguageAndAdvance(String locale) {
    _settingsProvider.updateLocale(locale);
    emit(
      state.copyWith(
        locale: locale,
        step: 1,
        filteredCountries: state.allCountries,
      ),
    );
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

  void selectDbCity(String key) => emit(state.copyWith(selectedCityKey: key));

  void selectWorldCity(WorldCity city) =>
      emit(state.copyWith(selectedWorldCity: city));

  /// Selects a DB city and immediately completes onboarding atomically.
  /// Avoids calling two cubit methods from the UI layer (CLAUDE.md §3).
  Future<void> selectDbCityAndComplete(String key) async {
    emit(state.copyWith(selectedCityKey: key));
    await complete();
  }

  /// Selects a world city and immediately completes onboarding atomically.
  Future<void> selectWorldCityAndComplete(WorldCity city) async {
    emit(state.copyWith(selectedWorldCity: city));
    await complete();
  }

  Future<void> onLocationDetected(DetectedLocation location) async {
    emit(mapDetectedLocationState(state, location));
    await complete();
  }

  /// Stages a GPS-detected location for user confirmation on the unified
  /// onboarding location page. Commit only happens after [confirmPending].
  void setPendingConfirmation(DetectedLocation location) {
    emit(state.copyWith(pendingConfirmation: location));
  }

  /// Applies the staged location and commits onboarding.
  Future<void> confirmPending() async {
    final pending = state.pendingConfirmation;
    if (pending == null) return;
    emit(
      mapDetectedLocationState(
        state,
        pending,
      ).copyWith(clearPendingConfirmation: true),
    );
    await complete();
  }

  /// Dismisses the confirmation card so the user can search manually.
  void rejectPending() {
    emit(state.copyWith(clearPendingConfirmation: true));
  }

  /// Applies an online (Nominatim) pick and commits directly — explicit user
  /// choice bypasses the confirmation card.
  Future<void> selectOnlineLocationAndComplete(
    DetectedLocation location,
  ) async {
    emit(mapDetectedLocationState(state, location));
    await complete();
  }

  Future<void> complete() async {
    emit(state.copyWith(isLoading: true, clearCompletionError: true));
    final result = await _completion.persistSelection(state);
    if (isClosed) return;
    result.fold(
      (_) => emit(
        state.copyWith(
          isLoading: false,
          completionError: 'تعذّر تحميل بيانات المدينة، تحقّق من الاتصال',
        ),
      ),
      (_) {
        _analytics?.logOnboardingCompleted(
          state.selectedCountryKey ?? '',
          state.selectedCityKey ?? state.selectedWorldCity?.name ?? '',
        );
        emit(state.copyWith(isLoading: false, isComplete: true));
      },
    );
  }

  void clearCompletionError() {
    emit(state.copyWith(clearCompletionError: true));
  }

  @override
  Future<void> close() {
    _filterController.dispose();
    return super.close();
  }
}
