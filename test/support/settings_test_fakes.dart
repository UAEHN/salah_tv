import 'package:dartz/dartz.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'package:ghasaq/core/error/failures.dart';
import 'package:ghasaq/core/usecases/success.dart';
import 'package:ghasaq/features/prayer/data/adhan_calculation_source.dart';
import 'package:ghasaq/features/prayer/data/calculated_prayer_repository.dart';
import 'package:ghasaq/features/prayer/data/composite_prayer_repository.dart';
import 'package:ghasaq/features/prayer/data/downloaded_prayer_repository.dart';
import 'package:ghasaq/features/prayer/data/prayer_cache_db_initializer.dart';
import 'package:ghasaq/features/prayer/domain/cancellation_token.dart';
import 'package:ghasaq/features/prayer/domain/usecases/i_download_city_use_case.dart';
import 'package:ghasaq/features/settings/domain/entities/app_settings.dart';
import 'package:ghasaq/features/settings/domain/entities/world_city.dart';
import 'package:ghasaq/features/settings/domain/i_settings_repository.dart';
import 'package:ghasaq/features/settings/domain/i_world_city_repository.dart';

/// Always returns success without hitting the network or a real DB.
class FakeDownloadCityUseCase implements IDownloadCityUseCase {
  @override
  Future<Either<Failure, Success>> call({
    required String countryKey,
    required String cityName,
    required CancellationToken cancelToken,
  }) async =>
      const Right(Success());
}

/// Creates a real in-memory [CompositePrayerRepository] for widget tests.
Future<CompositePrayerRepository> buildFakeCompositeRepo() async {
  sqfliteFfiInit();
  final db = await databaseFactoryFfi.openDatabase(
    inMemoryDatabasePath,
    options: OpenDatabaseOptions(
      version: 1,
      onCreate: (db, _) => PrayerCacheDbInitializer().createSchemaForTest(db),
    ),
  );
  final downloadedRepo = DownloadedPrayerRepository(db);
  final calcRepo = CalculatedPrayerRepository(AdhanCalculationSource());
  return CompositePrayerRepository(downloadedRepo, calcRepo);
}

class FakeSettingsRepository implements ISettingsRepository {
  AppSettings savedSettings = const AppSettings();

  @override
  Future<bool> hasCompletedAppTour() async => false;

  @override
  Future<bool> isFirstLaunch() async => false;

  @override
  Future<Either<Failure, AppSettings>> load() async => Right(savedSettings);

  @override
  Future<void> markAppTourCompleted() async {}

  @override
  Future<void> markLaunched() async {}

  @override
  Future<Either<Failure, Success>> save(AppSettings settings) async {
    savedSettings = settings;
    return const Right(Success());
  }
}

class FakeWorldCityRepository implements IWorldCityRepository {
  final List<WorldCity> _cities;

  FakeWorldCityRepository(this._cities);

  @override
  List<WorldCountry> get countries {
    final seen = <String>{};
    final items = <WorldCountry>[];
    for (final city in _cities) {
      if (seen.add(city.countryKey)) {
        items.add(
          WorldCountry(key: city.countryKey, arabicName: city.countryArabic),
        );
      }
    }
    return items;
  }

  @override
  List<WorldCity> citiesForCountry(String countryKey) {
    return _cities.where((city) => city.countryKey == countryKey).toList();
  }

  @override
  Future<void> initialize() async {}

  @override
  List<WorldCity> searchCities(String query) {
    return _cities.where((city) => city.name.contains(query)).toList();
  }

  @override
  WorldCity? resolveDetectedCity({
    required String countryKey,
    required String cityName,
    required double latitude,
    required double longitude,
  }) => null;
}
