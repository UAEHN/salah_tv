import 'package:dio/dio.dart';

import '../../features/app_update/data/app_update_repository.dart';
import '../../features/app_update/data/in_app_update_service.dart';
import '../../features/app_update/domain/i_app_update_repository.dart';
import '../../features/adhkar/data/adhkar_audio_service.dart';
import '../../features/adhkar/data/adhkar_json_repository.dart';
import '../../features/adhkar/data/adhkar_text_repository.dart';
import '../../features/adhkar/domain/i_adhkar_audio_port.dart';
import '../../features/adhkar/domain/i_adhkar_state_repository.dart';
import '../../features/adhkar/domain/i_adhkar_text_repository.dart';
import '../../features/analytics/data/firebase_analytics_service.dart';
import '../../features/rating/data/rating_service.dart';
import '../../features/rating/domain/i_rating_service.dart';
import '../../features/analytics/domain/i_analytics_service.dart';
import '../../features/notifications/data/prayer_notification_service.dart';
import '../../features/notifications/domain/i_prayer_notification_port.dart';
import '../../features/qibla/data/qibla_repository.dart';
import '../../features/qibla/domain/i_qibla_repository.dart';
import '../../features/quran/data/quran_api_service.dart';
import '../../features/quran/domain/i_quran_api_repository.dart';
import '../../features/settings/data/adhan_preview_service.dart';
import '../../features/settings/data/gps_location_detector.dart';
import '../../features/settings/data/world_city_json_repository.dart';
import '../../features/settings/domain/i_adhan_preview_port.dart';
import '../../features/settings/domain/i_custom_adhan_repository.dart';
import '../../features/settings/domain/usecases/delete_custom_adhan_usecase.dart';
import '../../features/settings/domain/usecases/import_custom_adhan_usecase.dart';
import '../../features/settings/domain/i_location_detector.dart';
import '../../features/settings/domain/i_world_city_repository.dart';
import '../../features/settings/presentation/bloc/adhan_preview_cubit.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../features/feedback/data/firestore_feedback_repository.dart';
import '../../features/feedback/domain/i_feedback_repository.dart';
import '../../features/app_tour/presentation/app_tour_cubit.dart';
import '../../features/settings/domain/i_settings_repository.dart';
import '../../injection.dart';
import '../platform_config.dart';

Future<void> registerFeatureServices(PlatformConfig platformConfig) async {
  await _registerAnalytics(platformConfig);
  await _registerAdhkarCore();
  _registerQuranAndQibla();
  _registerSharedLocationCatalog();
  _registerAppUpdate();
  _registerRating(); // shared: used by TvRatingTrigger (TV) and RatingTrigger (mobile)
  _registerFeedback();
  if (!platformConfig.isTV) {
    await _registerAdhkarReader();
    await _registerMobileOnly();
  }
}

void _registerAppUpdate() {
  getIt.registerLazySingleton<IAppUpdateRepository>(
    () => AppUpdateRepository(),
  );
  getIt.registerLazySingleton<InAppUpdateService>(
    () => InAppUpdateService(),
  );
}

void _registerRating() {
  getIt.registerLazySingleton<IRatingService>(() => RatingService());
}

void _registerFeedback() {
  getIt.registerLazySingleton<IFeedbackRepository>(
    () => FirestoreFeedbackRepository(FirebaseFirestore.instance, getIt<Dio>()),
  );
}

Future<void> _registerAdhkarCore() async {
  final adhkarRepo = AdhkarJsonRepository();
  await adhkarRepo.initialize();
  getIt.registerSingleton<AdhkarJsonRepository>(adhkarRepo);
  getIt.registerSingleton<IAdhkarStateRepository>(adhkarRepo);
  getIt.registerSingleton<IAdhkarAudioPort>(AdhkarAudioService());
}

void _registerQuranAndQibla() {
  getIt.registerLazySingleton<IQuranApiRepository>(
    () => QuranApiService(getIt<Dio>()),
  );
  getIt.registerLazySingleton<IQiblaRepository>(() => QiblaRepository());
}

void _registerSharedLocationCatalog() {
  getIt.registerLazySingleton<IWorldCityRepository>(
    () => WorldCityJsonRepository(),
  );
}

Future<void> _registerAdhkarReader() async {
  final adhkarTextRepo = AdhkarTextRepository();
  await adhkarTextRepo.initialize();
  getIt.registerSingleton<IAdhkarTextRepository>(adhkarTextRepo);
}

Future<void> _registerAnalytics(PlatformConfig platformConfig) async {
  final analyticsService = FirebaseAnalyticsService();
  await analyticsService.initialize(isTV: platformConfig.isTV);
  getIt.registerSingleton<IAnalyticsService>(analyticsService);
}

Future<void> _registerMobileOnly() async {
  final notifService = PrayerNotificationService();
  await notifService.initialize();
  getIt.registerSingleton<IPrayerNotificationPort>(notifService);

  getIt.registerLazySingleton<IAdhanPreviewPort>(
    () => AdhanPreviewService(customAdhans: getIt<ICustomAdhanRepository>()),
  );
  getIt.registerFactory<AdhanPreviewCubit>(
    () => AdhanPreviewCubit(getIt<IAdhanPreviewPort>()),
  );
  getIt.registerFactory<ImportCustomAdhanUseCase>(
    () => ImportCustomAdhanUseCase(getIt<ICustomAdhanRepository>()),
  );
  getIt.registerFactory<DeleteCustomAdhanUseCase>(
    () => DeleteCustomAdhanUseCase(getIt<ICustomAdhanRepository>()),
  );
  getIt.registerLazySingleton<ILocationDetector>(
    () =>
        GpsLocationDetector(worldCityRepository: getIt<IWorldCityRepository>()),
  );
  getIt.registerLazySingleton<AppTourCubit>(
    () => AppTourCubit(getIt<ISettingsRepository>()),
  );
}
