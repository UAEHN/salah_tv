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

    test('Fajr falls in early-morning band (03:00 – 05:00 local)', () {
      // Seventh-of-the-night auto rule above 48.5°N gives Fajr ≈
      // Sunrise - 1/7 of the night. Paris on summer solstice:
      // Maghrib ~21:55, next Sunrise ~5:50, night ~7h55, 1/7 ~1h8 →
      // Fajr ≈ 4:42 CEST.
      final minutes = times.fajr.hour * 60 + times.fajr.minute;
      expect(minutes, greaterThanOrEqualTo(3 * 60));
      expect(minutes, lessThanOrEqualTo(5 * 60));
    });

    test('Isha falls in late-evening band (22:00 – 23:30 local)', () {
      // Seventh-of-the-night Isha ≈ Maghrib + 1/7 night = ~23:00 CEST.
      final h = times.isha.hour;
      final isLateEvening = h >= 22 && h <= 23;
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

  group(
    'AdhanCalculationSource - London (51.51, MWL + auto HighLatitudeRule)',
    () {
      final times = source.calculateForDate(
        51.5074,
        -0.1278,
        summerSolstice,
        'muslim_world_league',
        utcOffsetHours: 1, // BST
      );

      test(
        'Isha in late-evening band (auto = twilightAngle, not midnight collapse)',
        () {
          final h = times.isha.hour;
          expect(h, isNot(equals(times.maghrib.hour)));
          // twilightAngle scales the 18°/17° angles down with day length.
          // London on summer solstice: expect Isha 21:30 – 23:30 BST.
          final isLateEvening = h >= 21 && h <= 23;
          expect(isLateEvening, isTrue, reason: 'Isha hour=$h');
        },
      );

      test('Fajr separated from Isha by hours, not collapsed to midnight', () {
        expect(times.fajr.isBefore(times.sunrise), isTrue);
        // The bug we fixed: middleOfTheNight would put both Fajr and Isha
        // at ~1:00 AM (1-minute apart). With twilightAngle the gap is
        // multi-hour even on the longest day.
        final ishaThenFajr = times.isha.isBefore(
          times.fajr.add(const Duration(days: 1)),
        );
        expect(ishaThenFajr, isTrue);
        final gapMinutes = times.fajr.difference(times.isha).inMinutes.abs();
        expect(gapMinutes > 60, isTrue, reason: 'gap=$gapMinutes min');
      });
    },
  );

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

    test('GB -> uk (London Central 18°/17°)', () {
      expect(defaultMethodForCountryIso('GB'), 'uk');
      expect(defaultMethodForCountryIso('IE'), 'uk');
    });

    test('DE / German-speaking Europe -> germany (DITIB 18°/17°)', () {
      expect(defaultMethodForCountryIso('DE'), 'germany');
      expect(defaultMethodForCountryIso('AT'), 'germany');
      expect(defaultMethodForCountryIso('NL'), 'germany');
    });

    test('null / unknown -> muslim_world_league', () {
      expect(defaultMethodForCountryIso(null), 'muslim_world_league');
      expect(defaultMethodForCountryIso('ZZ'), 'muslim_world_league');
    });
  });
}
