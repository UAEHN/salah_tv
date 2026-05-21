import 'package:dio/dio.dart';

import '../../features/announcements/data/announcement_repository.dart';
import '../../features/announcements/data/datasources/announcement_remote_config_data_source.dart';
import '../../features/announcements/domain/i_announcement_repository.dart';
import '../../features/app_update/data/app_update_repository.dart';
import '../../features/app_update/data/datasources/remote_config_data_source.dart';
import '../../features/app_update/data/in_app_update_service.dart';
import '../../features/app_update/data/package_info_service.dart';
import '../../features/app_update/data/remote_config_version_repository.dart';
import '../../features/app_update/domain/i_app_update_repository.dart';
import '../../features/app_update/domain/i_app_version_info_port.dart';
import '../../features/app_update/domain/i_remote_version_repository.dart';
import '../../features/app_update/domain/usecases/check_for_update_usecase.dart';
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
import '../../features/notifications/data/native_notification_engine.dart';
import '../../features/notifications/data/notification_health_service.dart';
import '../../features/notifications/domain/i_notification_health_port.dart';
import '../../features/notifications/domain/i_prayer_notification_port.dart';
import '../../features/notifications/domain/i_notification_onboarding_flag_port.dart';
import '../../features/notifications/domain/usecases/get_notification_health.dart';
import '../../features/notifications/domain/usecases/open_permission_settings.dart';
import '../../features/notifications/domain/usecases/run_notification_test.dart';
import '../../features/notifications/presentation/cubit/notification_health_cubit.dart';
import '../../features/notifications/presentation/onboarding/notification_onboarding_cubit.dart';
import '../../features/qibla/data/qibla_repository.dart';
import '../../features/qibla/domain/i_qibla_repository.dart';
import '../../features/takbeerat/data/datasources/takbeerat_remote_config_data_source.dart';
import '../../features/takbeerat/data/hijri_date_provider.dart';
import '../../features/takbeerat/data/takbeerat_config_repository.dart';
import '../../features/takbeerat/domain/i_hijri_date_provider.dart';
import '../../features/takbeerat/domain/i_takbeerat_config_repository.dart';
import '../../features/takbeerat/domain/usecases/should_show_takbeerat_card.dart';
import '../../features/takbeerat/presentation/cubit/takbeerat_visibility_cubit.dart';
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
import '../../features/feedback/data/feedback_diagnostics_collector.dart';
import '../../features/feedback/data/firestore_feedback_repository.dart';
import '../../features/feedback/domain/i_feedback_diagnostics_collector.dart';
import '../../features/feedback/domain/i_feedback_repository.dart';
import '../../features/home_widget/data/datasources/home_widget_data_source.dart';
import '../../features/home_widget/data/home_widget_repository_impl.dart';
import '../../features/home_widget/domain/i_home_widget_repository.dart';
import '../../features/home_widget/domain/usecases/get_upcoming_schedule.dart';
import '../../features/home_widget/domain/usecases/publish_widget_payload.dart';
import '../../features/prayer/domain/i_prayer_times_repository.dart';
import '../../injection.dart';
import '../platform_config.dart';
import 'startup_customization.dart';
import 'startup_quran.dart';
import 'startup_today.dart';

Future<void> registerFeatureServices(PlatformConfig platformConfig) async {
  await _registerAnalytics(platformConfig);
  await _registerAdhkarCore();
  _registerQuranAndQibla();
  _registerSharedLocationCatalog();
  _registerAppUpdate();
  _registerAnnouncements();
  _registerTakbeerat();
  _registerRating(); // shared: used by TvRatingTrigger (TV) and RatingTrigger (mobile)
  _registerFeedback();
  if (!platformConfig.isTV) {
    await _registerAdhkarReader();
    await _registerMobileOnly();
    _registerHomeWidget();
    registerCustomization();
    registerToday();
    registerQuranReader();
  }
}

void _registerHomeWidget() {
  getIt.registerLazySingleton<HomeWidgetDataSource>(
    () => HomeWidgetDataSource(),
  );
  getIt.registerLazySingleton<IHomeWidgetRepository>(
    () => HomeWidgetRepositoryImpl(getIt<HomeWidgetDataSource>()),
  );
  getIt.registerFactory<PublishWidgetPayloadUseCase>(
    () => PublishWidgetPayloadUseCase(getIt<IHomeWidgetRepository>()),
  );
  getIt.registerFactory<GetUpcomingScheduleUseCase>(
    () => GetUpcomingScheduleUseCase(getIt<IPrayerTimesRepository>()),
  );
}

void _registerAppUpdate() {
  getIt.registerLazySingleton<IAppUpdateRepository>(
    () => AppUpdateRepository(),
  );
  getIt.registerLazySingleton<InAppUpdateService>(
    () => InAppUpdateService(),
  );
  // Remote-Config-driven update gating (forced + optional updates).
  getIt.registerLazySingleton<IAppVersionInfoPort>(() => PackageInfoService());
  getIt.registerLazySingleton<RemoteConfigDataSource>(
    () => RemoteConfigDataSource(),
  );
  getIt.registerLazySingleton<IRemoteVersionRepository>(
    () => RemoteConfigVersionRepository(getIt<RemoteConfigDataSource>()),
  );
  getIt.registerFactory<CheckForUpdateUseCase>(
    () => CheckForUpdateUseCase(
      remoteRepo: getIt<IRemoteVersionRepository>(),
      versionInfo: getIt<IAppVersionInfoPort>(),
    ),
  );
}

void _registerAnnouncements() {
  getIt.registerLazySingleton<AnnouncementRemoteConfigDataSource>(
    () => AnnouncementRemoteConfigDataSource(),
  );
  getIt.registerLazySingleton<IAnnouncementRepository>(
    () => AnnouncementRepository(getIt<AnnouncementRemoteConfigDataSource>()),
  );
}

void _registerTakbeerat() {
  // Remote-Config-driven Eid Takbeerat: visibility, season offsets, reciters.
  // Feature ships dark — RC default `takbeerat_feature_enabled=false` keeps
  // [ShouldShowTakbeeratCard] returning hidden until enabled from console.
  getIt.registerLazySingleton<TakbeeratRemoteConfigDataSource>(
    () => TakbeeratRemoteConfigDataSource(),
  );
  getIt.registerLazySingleton<ITakbeeratConfigRepository>(
    () => TakbeeratConfigRepository(getIt<TakbeeratRemoteConfigDataSource>()),
  );
  getIt.registerLazySingleton<IHijriDateProvider>(
    () => const HijriDateProvider(),
  );
  getIt.registerFactory<ShouldShowTakbeeratCard>(
    () => ShouldShowTakbeeratCard(
      configRepo: getIt<ITakbeeratConfigRepository>(),
      hijri: getIt<IHijriDateProvider>(),
    ),
  );
  getIt.registerFactory<TakbeeratVisibilityCubit>(
    () => TakbeeratVisibilityCubit(
      shouldShow: getIt<ShouldShowTakbeeratCard>(),
      configRepo: getIt<ITakbeeratConfigRepository>(),
    ),
  );
}

void _registerRating() {
  getIt.registerLazySingleton<IRatingService>(() => RatingService());
}

void _registerFeedback() {
  getIt.registerLazySingleton<IFeedbackRepository>(
    () => FirestoreFeedbackRepository(FirebaseFirestore.instance, getIt<Dio>()),
  );
  getIt.registerLazySingleton<IFeedbackDiagnosticsCollector>(
    () => FeedbackDiagnosticsCollector(),
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
  // Native notification engine: AlarmManager + ForegroundService + WorkManager
  // running in Kotlin. Replaces flutter_local_notifications. The interface
  // [IPrayerNotificationPort] stays unchanged so the prayer cycle engine and
  // its mixins keep working without modification.
  final notifService = NativeNotificationEngine(getIt<IPrayerTimesRepository>());
  await notifService.initialize();
  getIt.registerSingleton<IPrayerNotificationPort>(notifService);
  getIt.registerSingleton<NativeNotificationEngine>(notifService);

  // Diagnostic surface: read-only port + cubit for the Notification Health
  // screen. Lazy so the channels stay quiet until the user opens the screen.
  getIt.registerLazySingleton<INotificationHealthPort>(
    () => NotificationHealthService(getIt<NativeNotificationEngine>()),
  );
  // Use-cases — every cross-layer call goes through one (CLAUDE.md §3).
  getIt.registerLazySingleton<GetNotificationHealth>(
    () => GetNotificationHealth(getIt<INotificationHealthPort>()),
  );
  getIt.registerLazySingleton<RunNotificationTest>(
    () => RunNotificationTest(getIt<INotificationHealthPort>()),
  );
  getIt.registerLazySingleton<RequestPostNotifications>(
    () => RequestPostNotifications(getIt<INotificationHealthPort>()),
  );
  getIt.registerLazySingleton<OpenExactAlarmSettings>(
    () => OpenExactAlarmSettings(getIt<INotificationHealthPort>()),
  );
  getIt.registerLazySingleton<OpenBatteryOptimizationSettings>(
    () => OpenBatteryOptimizationSettings(getIt<INotificationHealthPort>()),
  );
  getIt.registerLazySingleton<OpenNotificationSettings>(
    () => OpenNotificationSettings(getIt<INotificationHealthPort>()),
  );
  getIt.registerLazySingleton<OpenOemAutostart>(
    () => OpenOemAutostart(getIt<INotificationHealthPort>()),
  );

  getIt.registerFactory<NotificationHealthCubit>(
    () => NotificationHealthCubit(
      getHealth: getIt<GetNotificationHealth>(),
      runTest: getIt<RunNotificationTest>(),
      openNotifSettings: getIt<OpenNotificationSettings>(),
      openExactAlarm: getIt<OpenExactAlarmSettings>(),
      openBattery: getIt<OpenBatteryOptimizationSettings>(),
      openOem: getIt<OpenOemAutostart>(),
    ),
  );
  // Onboarding cubit takes the flag port as a runtime param so the gate
  // can supply the adapter built from SettingsProvider via widget context —
  // keeps this startup file free of settings/presentation imports.
  getIt.registerFactoryParam<
      NotificationOnboardingCubit,
      INotificationOnboardingFlagPort,
      void>(
    (flag, _) => NotificationOnboardingCubit(
      getHealth: getIt<GetNotificationHealth>(),
      requestNotifications: getIt<RequestPostNotifications>(),
      openExactAlarm: getIt<OpenExactAlarmSettings>(),
      openBattery: getIt<OpenBatteryOptimizationSettings>(),
      openOem: getIt<OpenOemAutostart>(),
      runTest: getIt<RunNotificationTest>(),
      flag: flag,
    ),
  );

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
}
