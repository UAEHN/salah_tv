import 'package:dio/dio.dart';

import '../../features/adhkar/data/adhkar_audio_service.dart';
import '../../features/adhkar/data/adhkar_json_repository.dart';
import '../../features/adhkar/data/adhkar_text_repository.dart';
import '../../features/adhkar/domain/i_adhkar_audio_port.dart';
import '../../features/adhkar/domain/i_adhkar_state_repository.dart';
import '../../features/adhkar/domain/i_adhkar_text_repository.dart';
import '../../features/analytics/data/firebase_analytics_service.dart';
import '../../features/analytics/domain/i_analytics_service.dart';
import '../../features/notifications/data/prayer_notification_service.dart';
import '../../features/notifications/domain/i_prayer_notification_port.dart';
import '../../features/qibla/data/qibla_repository.dart';
import '../../features/qibla/domain/i_qibla_repository.dart';
import '../../features/quran/data/quran_api_service.dart';
import '../../features/quran/domain/i_quran_api_repository.dart';
import '../../features/settings/data/gps_location_detector.dart';
import '../../features/settings/data/world_city_json_repository.dart';
import '../../features/settings/domain/i_location_detector.dart';
import '../../features/settings/domain/i_world_city_repository.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../features/feedback/data/firestore_feedback_repository.dart';
import '../../features/feedback/domain/i_feedback_repository.dart';
import '../../features/tasbih/data/tasbih_repository.dart';
import '../../features/tasbih/domain/i_tasbih_repository.dart';
import '../../injection.dart';
import '../platform_config.dart';

Future<void> registerFeatureServices(PlatformConfig platformConfig) async {
  await _registerAnalytics(platformConfig);
  await _registerAdhkarCore();
  _registerQuranAndQibla();
  if (!platformConfig.isTV) {
    await _registerAdhkarReader();
    await _registerMobileOnly();
  }
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

  getIt.registerLazySingleton<ILocationDetector>(() => GpsLocationDetector());
  getIt.registerLazySingleton<IWorldCityRepository>(
    () => WorldCityJsonRepository(),
  );
  getIt.registerLazySingleton<ITasbihRepository>(() => TasbihRepository());
  getIt.registerLazySingleton<IFeedbackRepository>(
    () => FirestoreFeedbackRepository(FirebaseFirestore.instance, getIt<Dio>()),
  );
}
