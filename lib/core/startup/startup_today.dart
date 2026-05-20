import '../../features/today/data/daily_verse_repository_impl.dart';
import '../../features/today/data/islamic_occasions_repository_impl.dart';
import '../../features/today/domain/i_daily_verse_repository.dart';
import '../../features/today/domain/i_islamic_occasions_repository.dart';
import '../../features/today/domain/usecases/get_current_greeting.dart';
import '../../features/today/domain/usecases/get_daily_verse.dart';
import '../../features/today/domain/usecases/get_upcoming_occasion.dart';
import '../../injection.dart';

/// Mobile-only DI for the "Today" hub.
/// All repositories are stateless static catalogs — `lazySingleton` keeps
/// a single instance per process. Use-cases stay factories so each consumer
/// gets a fresh, disposable instance.
void registerToday() {
  getIt.registerLazySingleton<IIslamicOccasionsRepository>(
    () => const IslamicOccasionsRepositoryImpl(),
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
