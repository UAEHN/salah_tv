import 'dart:convert';
import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:ghasaq/core/app_config.dart';
import 'package:ghasaq/core/city_translations.dart';
import 'package:ghasaq/core/error/failures.dart';
import 'package:ghasaq/core/platform_config.dart';
import 'package:ghasaq/features/prayer/data/adhan_calculation_source.dart';
import 'package:ghasaq/features/prayer/data/downloaded_prayer_repository.dart';
import 'package:ghasaq/features/prayer/data/prayer_cache_db_initializer.dart';
import 'package:ghasaq/features/prayer/data/prayer_cache_db_queries.dart';
import 'package:ghasaq/features/prayer/data/prayer_cache_db_writer.dart';
import 'package:ghasaq/features/prayer/data/prayer_city_json_parser.dart';
import 'package:ghasaq/features/prayer/domain/cancellation_token.dart';
import 'package:ghasaq/features/prayer/domain/i_prayer_city_downloader.dart';
import 'package:ghasaq/features/prayer/domain/usecases/download_city_use_case.dart';
import 'package:ghasaq/features/settings/data/datasources/city_catalog_remote_data_source.dart';
import 'package:ghasaq/features/settings/data/world_city_json_repository.dart';
import 'package:ghasaq/features/settings/presentation/logic/location_picker_logic.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

const _region = 'pajara';
const _city = 'Pájara';
const _slug = 'pájara';

String _read(String path) => File('out/prayer_data/$path').readAsStringSync();

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(() {
    GetIt.I.registerSingleton<PlatformConfig>(PlatformConfig());
  });
  tearDownAll(() => GetIt.I.unregister<PlatformConfig>());

  test(
    'published table covers 2026 and matches the existing app calculator',
    () {
      final payload = parseCityJson(_read('$_region/$_slug.json'));
      expect(payload.rows.length, 365);
      final dates = payload.rows.map((r) => r.first).toSet();
      expect(dates.length, 365);
      expect(payload.rows.first.first, 20260101);
      expect(payload.rows.last.first, 20261231);
      final manifest =
          jsonDecode(_read('manifest.json')) as Map<String, dynamic>;
      expect((manifest['cities'] as Map)['$_region/$_slug'], payload.hash);
      final source = AdhanCalculationSource();
      for (final row in payload.rows) {
        final date = DateTime(
          row[0] ~/ 10000,
          row[0] ~/ 100 % 100,
          row[0] % 100,
        );
        final calculated = source.calculateForDate(
          28.35039,
          -14.1076,
          date,
          'muslim_world_league',
          timeZoneId: 'Atlantic/Canary',
        );
        final times = [
          calculated.fajr,
          calculated.sunrise,
          calculated.dhuhr,
          calculated.asr,
          calculated.maghrib,
          calculated.isha,
        ];
        expect(
          row.skip(1),
          times.map((t) => t.hour * 60 + t.minute),
          reason: '$date must match the existing calculation convention',
        );
        expect(AdhanCalculationSource.isValid(calculated), isTrue);
        for (var i = 1; i < row.length; i++) {
          expect(row[i], inInclusiveRange(0, 1439));
          if (i > 1) expect(row[i], greaterThan(row[i - 1]));
        }
      }
    },
  );

  test('winter transition shifts all six clock times on the correct day', () {
    final rows = parseCityJson(_read('$_region/$_slug.json')).rows;
    final before = rows.singleWhere((r) => r[0] == 20261024);
    final after = rows.singleWhere((r) => r[0] == 20261025);
    final next = rows.singleWhere((r) => r[0] == 20261026);
    for (var i = 1; i < 7; i++) {
      expect(before[i] - after[i], inInclusiveRange(58, 62));
      expect((next[i] - after[i]).abs(), lessThanOrEqualTo(2));
    }
  });

  test(
    'existing remote catalog exposes Pajara as a downloadable DB choice',
    () async {
      await loadCityTranslations();
      expect(kDbCountryKeys, isNot(contains(_region)));
      final catalog = CityCatalogRemoteDataSource.parse(_read('catalog.json'));
      final region = catalog.countries.singleWhere((c) => c.key == _region);
      expect(region.arabicName, 'باخارا');
      expect(region.englishName, 'Pájara');
      expect(
        catalog.countries.any(
          (c) => c.key == 'canary_islands' || c.key == 'spain',
        ),
        isFalse,
      );
      expect(region.cities.single.englishName, _city);
      expect(region.cities.single.arabicName, 'باخارا');
      mergeRemoteCatalog(catalog);
      final country = buildUnifiedCountries(
        null,
      ).singleWhere((c) => c.key == _region);
      expect(country.isInDb, isTrue);
      final choice = buildCountryChoices(country, null).single;
      expect(choice.isDb, isTrue);
      expect(choice.cityName, _city);
      final world = WorldCityJsonRepository();
      await world.initialize();
      final choices = buildUnifiedCountries(world);
      expect(
        choices.where((c) => c.key == 'ES' || c.key == 'spain'),
        hasLength(1),
      );
      expect(choices.singleWhere((c) => c.key == 'ES').isInDb, isFalse);
    },
  );

  test('previous Canary download remains valid for existing selections', () {
    final current = parseCityJson(_read('$_region/$_slug.json'));
    for (final region in ['canary_islands', 'spain']) {
      final previous = parseCityJson(
        _read('$region/pajara_-_fuerteventura.json'),
      );
      expect(current.rows, previous.rows);
      expect(current.hash, previous.hash);
    }
  });

  test('Spanish accented city name is encoded correctly in download URLs', () {
    final uri = Uri.parse(AppConfig.prayerCityUrl(_region, _slug));
    expect(uri.toString(), contains('p%C3%A1jara.json'));
    expect(uri.pathSegments.last, 'pájara.json');
  });

  test(
    'existing downloader writes the table and repository reads winter time',
    () async {
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
      final db = await databaseFactory.openDatabase(inMemoryDatabasePath);
      addTearDown(db.close);
      await PrayerCacheDbInitializer().createSchemaForTest(db);
      final queries = PrayerCacheDbQueries();
      final download = DownloadCityUseCase(
        db,
        queries,
        _TableDownloader(),
        PrayerCacheDbWriter(),
      );
      final result = await download(
        countryKey: _region,
        cityName: _city,
        cancelToken: CancellationToken(),
      );
      expect(result.isRight(), isTrue);
      expect(await queries.isCityCached(db, _region, _city, 2026), isTrue);
      final repository = DownloadedPrayerRepository(db);
      await repository.loadCity(_region, _city);
      final day = (await repository.getByDate(
        DateTime(2026, 10, 25),
      )).fold((failure) => throw TestFailure('$failure'), (day) => day);
      expect(day, isNotNull);
      final row = parseCityJson(
        _read('$_region/$_slug.json'),
      ).rows.singleWhere((r) => r[0] == 20261025);
      expect(day?.fajr, DateTime(2026, 10, 25, row[1] ~/ 60, row[1] % 60));
      expect(day?.isha, DateTime(2026, 10, 25, row[6] ~/ 60, row[6] % 60));
    },
  );
}

class _TableDownloader implements IPrayerCityDownloader {
  @override
  Future<Either<Failure, CityJsonPayload>> fetchCity(
    String country,
    String citySlug,
    CancellationToken cancelToken,
  ) async {
    expect(country, _region);
    expect(citySlug, _slug);
    return Right(parseCityJson(_read('$country/$citySlug.json')));
  }

  @override
  Future<Map<String, String>?> fetchManifest() async => null;
}
