import '../../analytics/domain/i_analytics_service.dart';
import '../../prayer/data/composite_prayer_repository.dart';
import '../../prayer/domain/usecases/i_download_city_use_case.dart';
import '../../settings/domain/i_settings_repository.dart';
import '../../settings/domain/i_world_city_repository.dart';
import '../../settings/presentation/settings_provider.dart';
import 'onboarding_completion_service.dart';
import 'onboarding_country_loader.dart';
import 'onboarding_cubit.dart';
import 'onboarding_filter_controller.dart';

/// Wires up the runtime dependency graph for [OnboardingCubit]. Kept as a
/// top-level function (instead of a static factory on the cubit) so the cubit
/// file stays under the 150-line cap without mixing wiring with behavior.
OnboardingCubit createOnboardingCubit({
  required SettingsProvider settingsProvider,
  required IWorldCityRepository worldRepo,
  required ISettingsRepository settingsRepository,
  required IDownloadCityUseCase downloadCityUseCase,
  required CompositePrayerRepository compositeRepo,
  IAnalyticsService? analytics,
}) {
  return OnboardingCubit(
    settingsProvider: settingsProvider,
    countryLoader: OnboardingCountryLoader(worldRepo),
    completionService: OnboardingCompletionService(
      settingsProvider,
      settingsRepository,
      downloadCityUseCase,
      compositeRepo,
    ),
    filterController: OnboardingFilterController(),
    analytics: analytics,
  );
}
