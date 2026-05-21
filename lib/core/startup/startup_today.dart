import '../../features/app_update/domain/i_app_version_info_port.dart';
import '../../features/today/data/daily_verse_repository_impl.dart';
import '../../features/today/data/datasources/occasions_local_data_source.dart';
import '../../features/today/data/datasources/occasions_remote_data_source.dart';
import '../../features/today/data/islamic_occasions_repository_impl.dart';
import '../../features/today/domain/i_daily_verse_repository.dart';
import '../../features/today/domain/i_islamic_occasions_repository.dart';
import '../../features/today/domain/usecases/get_current_greeting.dart';
import '../../features/today/domain/usecases/get_daily_verse.dart';
import '../../features/today/domain/usecases/get_upcoming_occasion.dart';
import '../../injection.dart';

/// Mobile-only DI for the "Today" hub.
/// Verse repo is a stateless bundled catalog — `lazySingleton` keeps a
/// single instance per process. The occasions repo is now backed by a
/// remote manifest with cache + bundled fallback, so it holds in-memory
/// state and must also be a singleton.
void registerToday() {
  getIt.registerLazySingleton<OccasionsRemoteDataSource>(
    () => OccasionsRemoteDataSource(),
  );
  getIt.registerLazySingleton<OccasionsLocalDataSource>(
    () => OccasionsLocalDataSource(),
  );
  getIt.registerLazySingleton<IIslamicOccasionsRepository>(
    () => IslamicOccasionsRepositoryImpl(
      remoteSource: getIt<OccasionsRemoteDataSource>(),
      localSource: getIt<OccasionsLocalDataSource>(),
      versionInfo: getIt<IAppVersionInfoPort>(),
    ),
  );
  getIt.registerLazySingleton<IDailyVerseRepository>(
    () => const DailyVerseRepositoryImpl(),
  );

  getIt.registerFactory<GetCurrentGreetingUseCase>(
    () => const GetCurrentGreetingUseCase(),
  );
  getIt.registerFactory<GetUpcomingOccasionUseCase>(
    () => GetUpcomingOccasionUseCase(getIt<IIslamicOccasionsRepository>()),
  );
  getIt.registerFactory<GetDailyVerseUseCase>(
    () => GetDailyVerseUseCase(getIt<IDailyVerseRepository>()),
  );
}
