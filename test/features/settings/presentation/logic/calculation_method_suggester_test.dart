import 'package:flutter_test/flutter_test.dart';
import 'package:ghasaq/features/prayer/data/high_latitude_rule_map.dart';
import 'package:ghasaq/features/settings/presentation/logic/calculation_method_suggester.dart';

void main() {
  group('suggestMethodForLocation — country → method', () {
    test('FR → uoif (Phase 3 default kept consistent with France default)',
        () {
      // Actually the curated default for FR is "france" (Mosquée de Paris).
      // Verified via the shared mapper.
      final s = suggestMethodForLocation(
        isoCountryCode: 'FR',
        latitude: 48.85,
      );
      expect(s.method, 'france');
    });

    test('DE → germany (18°/17°)', () {
      final s = suggestMethodForLocation(
        isoCountryCode: 'DE',
        latitude: 52.52,
      );
      expect(s.method, 'germany');
    });

    test('GB → uk (London Central 18°/17°)', () {
      final s = suggestMethodForLocation(
        isoCountryCode: 'GB',
        latitude: 51.5,
      );
      expect(s.method, 'uk');
    });

    test('US → north_america', () {
      final s = suggestMethodForLocation(
        isoCountryCode: 'US',
        latitude: 40.0,
      );
      expect(s.method, 'north_america');
    });

    test('AE → dubai', () {
      final s = suggestMethodForLocation(
        isoCountryCode: 'AE',
        latitude: 25.2,
      );
      expect(s.method, 'dubai');
    });

    test('unknown / null ISO → muslim_world_league fallback', () {
      final s = suggestMethodForLocation(
        isoCountryCode: null,
        latitude: 12.0,
      );
      expect(s.method, 'muslim_world_league');
    });
  });

  group('suggestMethodForLocation — latitude → band & rule', () {
    test('low latitude → normal band, auto rule', () {
      final s = suggestMethodForLocation(
        isoCountryCode: 'AE',
        latitude: 25.2,
      );
      expect(s.band, HighLatitudeBand.normal);
      expect(s.highLatitudeRule, HighLatitudeRuleKey.auto);
    });

    test('boundary 47.9° → still normal band', () {
      final s = suggestMethodForLocation(
        isoCountryCode: 'FR',
        latitude: 47.9,
      );
      expect(s.band, HighLatitudeBand.normal);
      expect(s.highLatitudeRule, HighLatitudeRuleKey.auto);
    });

    test('boundary 48.0° → high band, twilight_angle rule', () {
      final s = suggestMethodForLocation(
        isoCountryCode: 'FR',
        latitude: 48.0,
      );
      expect(s.band, HighLatitudeBand.high);
      expect(s.highLatitudeRule, HighLatitudeRuleKey.twilightAngle);
    });

    test('Berlin (52.52) → high band', () {
      final s = suggestMethodForLocation(
        isoCountryCode: 'DE',
        latitude: 52.52,
      );
      expect(s.band, HighLatitudeBand.high);
    });

    test('Stockholm (59.33) → extreme band', () {
      final s = suggestMethodForLocation(
        isoCountryCode: 'SE',
        latitude: 59.33,
      );
      expect(s.band, HighLatitudeBand.extreme);
      expect(s.highLatitudeRule, HighLatitudeRuleKey.twilightAngle);
    });

    test('Reykjavik (64.13) → extreme band', () {
      final s = suggestMethodForLocation(
        isoCountryCode: 'IS',
        latitude: 64.13,
      );
      expect(s.band, HighLatitudeBand.extreme);
    });

    test('southern hemisphere latitude is treated by absolute value', () {
      final s = suggestMethodForLocation(
        isoCountryCode: 'NZ',
        latitude: -50.0,
      );
      expect(s.band, HighLatitudeBand.high);
      expect(s.highLatitudeRule, HighLatitudeRuleKey.twilightAngle);
    });
  });
}
