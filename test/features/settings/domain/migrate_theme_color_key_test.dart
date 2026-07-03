import 'package:flutter_test/flutter_test.dart';
import 'package:ghasaq/features/settings/domain/entities/app_settings_decoders.dart';

void main() {
  group('migrateThemeColorKey', () {
    test('migrates the removed green theme to red', () {
      expect(migrateThemeColorKey('green'), 'red');
    });

    test('leaves other valid keys untouched', () {
      expect(migrateThemeColorKey('gold'), 'gold');
      expect(migrateThemeColorKey('blue'), 'blue');
      expect(migrateThemeColorKey('red'), 'red');
      expect(migrateThemeColorKey('desert_dawn'), 'desert_dawn');
    });

    test('falls back to gold for null/empty', () {
      expect(migrateThemeColorKey(null), 'gold');
      expect(migrateThemeColorKey(''), 'gold');
    });
  });
}
