import 'package:dartz/dartz.dart';

import 'package:ghasaq/core/error/failures.dart';
import 'package:ghasaq/core/usecases/success.dart';
import 'package:ghasaq/features/settings/domain/entities/app_settings.dart';
import 'package:ghasaq/features/settings/domain/entities/world_city.dart';
import 'package:ghasaq/features/settings/domain/i_settings_repository.dart';
import 'package:ghasaq/features/settings/domain/i_world_city_repository.dart';

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
