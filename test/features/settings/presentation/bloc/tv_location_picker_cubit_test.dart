import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:ghasaq/core/city_translations.dart';
import 'package:ghasaq/core/platform_config.dart';
import 'package:ghasaq/features/settings/domain/entities/world_city.dart';
import 'package:ghasaq/features/settings/presentation/bloc/location_picker_source.dart';
import 'package:ghasaq/features/settings/presentation/bloc/tv_location_picker_cubit.dart';
import 'package:ghasaq/features/settings/presentation/bloc/tv_location_picker_state.dart';
import 'package:ghasaq/features/settings/presentation/logic/location_picker_logic.dart';

import '../../../../support/settings_test_fakes.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    await loadCityTranslations();
    // `kIsTV` reads `PlatformConfig` from GetIt; the test environment
    // never runs `initDependencies`, so register a benign instance.
    if (!GetIt.I.isRegistered<PlatformConfig>()) {
      GetIt.I.registerSingleton<PlatformConfig>(PlatformConfig());
    }
  });

  FakeWorldCityRepository buildWorldRepo() {
    return FakeWorldCityRepository([
      const WorldCity(
        name: 'New York',
        arabicName: 'نيويورك',
        countryKey: 'US',
        countryArabic: 'الولايات المتحدة',
        latitude: 40.7128,
        longitude: -74.0060,
        calculationMethod: 'north_america',
        utcOffset: -5,
      ),
      const WorldCity(
        name: 'Chicago',
        arabicName: 'شيكاغو',
        countryKey: 'US',
        countryArabic: 'الولايات المتحدة',
        latitude: 41.8781,
        longitude: -87.6298,
        calculationMethod: 'north_america',
        utcOffset: -6,
      ),
    ]);
  }

  group('TvLocationPickerCubit', () {
    test('loads merged countries with db and world entries', () async {
      final cubit = TvLocationPickerCubit(
        buildWorldRepo(),
        currentCountry: 'uae',
        currentCity: 'Dubai',
      );

      await cubit.load();

      expect(cubit.state.status, TvLocationPickerStatus.ready);
      expect(
        cubit.state.countries.any((c) => c.key == 'uae' && c.isInDb),
        isTrue,
      );
      expect(
        cubit.state.countries.any((c) => c.key == 'US' && !c.isInDb),
        isTrue,
      );
    });

    test('shows db cities when a db country is selected', () async {
      final cubit = TvLocationPickerCubit(
        buildWorldRepo(),
        currentCountry: 'uae',
        currentCity: 'Dubai',
      );
      await cubit.load();

      cubit.selectCountry(
        const UnifiedCountry(
          key: 'uae',
          arabicName: 'الإمارات',
          englishName: 'United Arab Emirates',
          source: LocationPickerSource.db,
        ),
      );

      expect(cubit.state.showsCities, isTrue);
      expect(
        cubit.state.cities.any((c) => c.cityName == 'Dubai' && c.isDb),
        isTrue,
      );
    });

    test('filters world cities when a world country is selected', () async {
      final cubit = TvLocationPickerCubit(
        buildWorldRepo(),
        currentCountry: 'US',
        currentCity: 'New York',
      );
      await cubit.load();

      cubit.selectCountry(
        const UnifiedCountry(
          key: 'US',
          arabicName: 'الولايات المتحدة',
          englishName: 'United States',
          source: LocationPickerSource.world,
        ),
      );
      cubit.updateQuery('chic');

      expect(cubit.state.cities, hasLength(1));
      expect(cubit.state.cities.single.cityName, 'Chicago');
      expect(cubit.state.cities.single.isDb, isFalse);
    });
  });
}
