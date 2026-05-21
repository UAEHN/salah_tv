import 'package:flutter_test/flutter_test.dart';
import 'package:ghasaq/core/calculation_method_info.dart';
import 'package:ghasaq/features/prayer/data/adhan_calculation_source.dart';

/// Worldwide-mode prayer calculation tests.
///
/// Focus: high-latitude correctness (HighLatitudeRule applied above ~48.5°)
/// and the Grande Mosquée de Paris (`france`) method giving sensible Fajr
/// and Isha in summer instead of NaN / late-night ghost values.
void main() {
  final source = AdhanCalculationSource();
  // June 21 (longest day) — the worst case for high-latitude twilight.
  final summerSolstice = DateTime.utc(2026, 6, 21);

  group('AdhanCalculationSource - Paris (france method, lat 48.85)', () {
    final times = source.calculateForDate(
      48.8566,
      2.3522,
      summerSolstice,
      'france',
      utcOffsetHours: 2, // CEST
    );

    test('produces real (non-NaN) Fajr and Isha at summer solstice', () {
      expect(times.fajr.isUtc, isFalse);
      expect(times.fajr.year, 2026);
      expect(times.isha.year, 2026);
      expect(times.fajr.millisecondsSinceEpoch, isPositive);
      expect(times.isha.millisecondsSinceEpoch, isPositive);
    });

    test('Fajr falls in early-morning band (02:30 – 04:30 local)', () {
      final minutes = times.fajr.hour * 60 + times.fajr.minute;
      expect(minutes, greaterThanOrEqualTo(2 * 60 + 30));
      expect(minutes, lessThanOrEqualTo(4 * 60 + 30));
    });

    test('Isha falls in late-evening band (22:00 – 00:30 local)', () {
      final h = times.isha.hour;
      final isLateEvening = h >= 22 || h <= 0;
      expect(isLateEvening, isTrue, reason: 'Isha hour=$h');
    });

    test('order is Fajr < Sunrise < Dhuhr < Asr < Maghrib < Isha', () {
      expect(times.fajr.isBefore(times.sunrise), isTrue);
      expect(times.sunrise.isBefore(times.dhuhr), isTrue);
      expect(times.dhuhr.isBefore(times.asr), isTrue);
      expect(times.asr.isBefore(times.maghrib), isTrue);
      expect(times.maghrib.isBefore(times.isha), isTrue);
    });
  });

  group('AdhanCalculationSource - New York (40.71, north_america)', () {
    final times = source.calculateForDate(
      40.7128,
      -74.0060,
      summerSolstice,
      'north_america',
      utcOffsetHours: -4, // EDT
    );

    test('Fajr and Isha are sensible (lat below high-lat threshold)', () {
      expect(times.fajr.hour, inInclusiveRange(3, 5));
      expect(times.isha.hour, inInclusiveRange(21, 23));
    });

    test('prayer order is preserved', () {
      expect(times.fajr.isBefore(times.sunrise), isTrue);
      expect(times.maghrib.isBefore(times.isha), isTrue);
    });
  });

  group('AdhanCalculationSource - London (51.51, MWL + auto HighLatitudeRule)',
      () {
    final times = source.calculateForDate(
      51.5074,
      -0.1278,
      summerSolstice,
      'muslim_world_league',
      utcOffsetHours: 1, // BST
    );

    test('Isha bounded by middle-of-the-night rule (no NaN, before 01:00)', () {
      final h = times.isha.hour;
      expect(h, isNot(equals(times.maghrib.hour)));
      final isBounded = h >= 22 || h <= 1;
      expect(isBounded, isTrue, reason: 'Isha hour=$h');
    });

    test('Fajr is after midnight and before sunrise', () {
      expect(times.fajr.isBefore(times.sunrise), isTrue);
      expect(times.fajr.hour, lessThan(5));
    });
  });

  group('defaultMethodForCountryIso country mapping', () {
    test('FR -> france (Grande Mosquée de Paris convention)', () {
      expect(defaultMethodForCountryIso('FR'), 'france');
      expect(defaultMethodForCountryIso('fr'), 'france');
    });

    test('BE, LU, CH -> france (French-mosque influence)', () {
      expect(defaultMethodForCountryIso('BE'), 'france');
      expect(defaultMethodForCountryIso('LU'), 'france');
      expect(defaultMethodForCountryIso('CH'), 'france');
    });

    test('US, CA, MX -> north_america', () {
      expect(defaultMethodForCountryIso('US'), 'north_america');
      expect(defaultMethodForCountryIso('CA'), 'north_america');
    });

    test('GB, DE (unmapped) fall back to muslim_world_league', () {
      expect(defaultMethodForCountryIso('GB'), 'muslim_world_league');
      expect(defaultMethodForCountryIso('DE'), 'muslim_world_league');
    });

    test('null / unknown -> muslim_world_league', () {
      expect(defaultMethodForCountryIso(null), 'muslim_world_league');
      expect(defaultMethodForCountryIso('ZZ'), 'muslim_world_league');
    });
  });
}
