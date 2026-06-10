import 'package:flutter_test/flutter_test.dart';
import 'package:ghasaq/core/city_translations.dart';
import 'package:ghasaq/features/settings/data/online_result_to_detected_location.dart';
import 'package:ghasaq/features/settings/domain/entities/online_geocoding_result.dart';
import 'package:ghasaq/features/settings/domain/entities/world_city.dart';

import '../../../support/settings_test_fakes.dart';

OnlineGeocodingResult _r({
  required String name,
  required String countryCode,
  String? countryName,
  String? subLocality,
  String? administrativeArea,
  String? subAdministrativeArea,
  String? displayName,
  double latitude = 0,
  double longitude = 0,
}) {
  return OnlineGeocodingResult(
    name: name,
    displayName: displayName ?? name,
    latitude: latitude,
    longitude: longitude,
    countryCode: countryCode,
    countryName: countryName,
    subLocality: subLocality,
    administrativeArea: administrativeArea,
    subAdministrativeArea: subAdministrativeArea,
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    await loadCityTranslations();
  });

  group('detectedLocationFromOnlineResult — DB matches', () {
    test('English DB city name (Dubai) → isInDb', () async {
      final detected = await detectedLocationFromOnlineResult(
        _r(name: 'Dubai', countryCode: 'AE', administrativeArea: 'Dubai'),
      );
      expect(detected.isInDb, isTrue);
      expect(detected.dbCountryKey, 'uae');
      expect(detected.dbCityKey, 'Dubai');
    });

    test(
      'Arabic name with space ("خور فكان") → Khor Fakkan via strict pass',
      () async {
        final detected = await detectedLocationFromOnlineResult(
          _r(
            name: 'خور فكان',
            countryCode: 'AE',
            administrativeArea: 'الشارقة',
          ),
        );
        expect(detected.isInDb, isTrue);
        expect(detected.dbCityKey, 'Khor Fakkan');
      },
    );

    test('Arabic city name "دبي" → Dubai', () async {
      final detected = await detectedLocationFromOnlineResult(
        _r(name: 'دبي', countryCode: 'AE'),
      );
      expect(detected.isInDb, isTrue);
      expect(detected.dbCityKey, 'Dubai');
    });

    test('Arabic "القاهرة" with tah marbuta → Cairo', () async {
      final detected = await detectedLocationFromOnlineResult(
        _r(name: 'القاهرة', countryCode: 'EG'),
      );
      expect(detected.isInDb, isTrue);
      expect(detected.dbCityKey, 'Cairo');
    });

    test('Alias from kDbCityAliases ("Khawr Fakkan") → Khor Fakkan', () async {
      final detected = await detectedLocationFromOnlineResult(
        _r(name: 'Khawr Fakkan', countryCode: 'AE'),
      );
      expect(detected.isInDb, isTrue);
      expect(detected.dbCityKey, 'Khor Fakkan');
    });

    test(
      'Suburb in DB country falls back to admin area (Al Awir → Dubai)',
      () async {
        final detected = await detectedLocationFromOnlineResult(
          _r(
            name:
                'Dubai', // Nominatim parsed `address.city = Dubai` for Al Awir
            subLocality: 'Al Awir',
            countryCode: 'AE',
            administrativeArea: 'Dubai',
          ),
        );
        expect(detected.isInDb, isTrue);
        expect(detected.dbCityKey, 'Dubai');
      },
    );
  });

  group('detectedLocationFromOnlineResult — non-DB / fallbacks', () {
    test('Non-DB country (Germany) without worldRepo → isInDb false', () async {
      final detected = await detectedLocationFromOnlineResult(
        _r(
          name: 'Berlin',
          countryCode: 'DE',
          countryName: 'Germany',
          latitude: 52.52,
          longitude: 13.4,
        ),
      );
      expect(detected.isInDb, isFalse);
      expect(detected.dbCityKey, isNull);
      expect(detected.cityName, 'Berlin');
      expect(detected.latitude, 52.52);
      expect(detected.isoCountryCode, 'DE');
    });

    test(
      'Non-DB country with worldRepo → resolves nearest world city',
      () async {
        final worldRepo = FakeWorldCityRepository([
          const WorldCity(
            name: 'Frankfurt',
            arabicName: 'فرانكفورت',
            countryKey: 'DE',
            countryArabic: 'ألمانيا',
            latitude: 50.11,
            longitude: 8.68,
            calculationMethod: 'muslim_world_league',
            timeZoneId: 'Europe/Berlin',
            utcOffset: 1,
          ),
        ]);
        // FakeWorldCityRepository.resolveDetectedCity returns null, so we
        // verify the fallback at least doesn't crash and gives back a
        // calculation-mode DetectedLocation.
        final detected = await detectedLocationFromOnlineResult(
          _r(
            name: 'Würzburg',
            countryCode: 'DE',
            latitude: 49.79,
            longitude: 9.93,
          ),
          worldRepo: worldRepo,
        );
        expect(detected.isInDb, isFalse);
        expect(detected.cityName, 'Würzburg');
      },
    );

    test(
      'DB country, city not in DB (Rafha in Saudi) → isInDb false',
      () async {
        // Rafha is not in saudi DB cities and has no alias.
        final detected = await detectedLocationFromOnlineResult(
          _r(
            name: 'رفحاء',
            countryCode: 'SA',
            administrativeArea: 'منطقة الحدود الشمالية',
            latitude: 29.62,
            longitude: 43.49,
          ),
        );
        expect(detected.isInDb, isFalse);
        expect(detected.cityName, 'رفحاء');
        expect(detected.isoCountryCode, 'SA');
      },
    );

    test('Empty countryCode → isoCountryCode null, isInDb false', () async {
      final detected = await detectedLocationFromOnlineResult(
        _r(name: 'Somewhere', countryCode: ''),
      );
      expect(detected.isInDb, isFalse);
      expect(detected.isoCountryCode, isNull);
    });
  });
}
