import 'package:flutter_test/flutter_test.dart';
import 'package:ghasaq/features/settings/presentation/bloc/location_choice.dart';
import 'package:ghasaq/features/settings/presentation/bloc/location_selection_cubit.dart';
import 'package:ghasaq/features/settings/presentation/settings_provider.dart';

import '../../../../support/settings_test_fakes.dart';

void main() {
  group('LocationSelectionCubit', () {
    test('saves database choice through updateLocation', () async {
      final repo = FakeSettingsRepository();
      final provider = SettingsProvider(repo, repo.savedSettings);
      final cubit = LocationSelectionCubit(provider);

      await cubit.save(
        LocationChoice.database(countryKey: 'UAE', cityName: 'Dubai'),
      );

      expect(provider.settings.selectedCountry, 'UAE');
      expect(provider.settings.selectedCity, 'Dubai');
      expect(provider.settings.isCalculatedLocation, isFalse);
      expect(cubit.state.status, LocationSelectionStatus.saved);
    });

    test('saves world choice through updateWorldLocation', () async {
      final repo = FakeSettingsRepository();
      final provider = SettingsProvider(repo, repo.savedSettings);
      final cubit = LocationSelectionCubit(provider);

      await cubit.save(
        LocationChoice.worldFromValues(
          countryKey: 'US',
          cityName: 'New York',
          latitude: 40.7128,
          longitude: -74.0060,
          calculationMethod: 'north_america',
          utcOffsetHours: -5,
        ),
      );

      expect(provider.settings.selectedCountry, 'US');
      expect(provider.settings.selectedCity, 'New York');
      expect(provider.settings.isCalculatedLocation, isTrue);
      expect(provider.settings.selectedLatitude, 40.7128);
      expect(provider.settings.calculationMethod, 'north_america');
      expect(cubit.state.status, LocationSelectionStatus.saved);
    });
  });
}
