import 'package:flutter_test/flutter_test.dart';
import 'package:hijri/hijri_calendar.dart';

import 'package:ghasaq/features/today/data/islamic_occasions_catalog.dart';
import 'package:ghasaq/features/today/data/islamic_occasions_repository_impl.dart';

void main() {
  const repo = IslamicOccasionsRepositoryImpl();

  group('IslamicOccasionsRepositoryImpl', () {
    test('returns a Right with non-null when an occasion is within window',
        () async {
      // Walk Gregorian dates forward and find one where the catalog matches
      // — guarantees the lookup window contains at least one entry.
      DateTime probe = DateTime(2026, 1, 1);
      var found = false;
      for (var i = 0; i < 365; i++) {
        final hijri = HijriCalendar.fromDate(probe);
        final match = kIslamicOccasionsCatalog.any(
          (o) => o.hijriMonth == hijri.hMonth && o.hijriDay == hijri.hDay,
        );
        if (match) {
          found = true;
          break;
        }
        probe = probe.add(const Duration(days: 1));
      }
      expect(found, isTrue, reason: 'catalog should hit within a year');

      final result = await repo.getNextOccasion(probe);
      result.fold((_) => fail('expected Right'), (occasion) {
        expect(occasion, isNotNull);
        expect(occasion!.daysUntil, 0);
      });
    });

    test('daysUntil increases as the start date moves earlier', () async {
      // Pick any catalog entry, find its Gregorian date, then ask from one
      // and three days before — daysUntil should be 1 and 3 respectively.
      DateTime probe = DateTime(2026, 1, 1);
      DateTime? hit;
      for (var i = 0; i < 365; i++) {
        final hijri = HijriCalendar.fromDate(probe);
        if (kIslamicOccasionsCatalog.any(
          (o) => o.hijriMonth == hijri.hMonth && o.hijriDay == hijri.hDay,
        )) {
          hit = probe;
          break;
        }
        probe = probe.add(const Duration(days: 1));
      }
      expect(hit, isNotNull);

      final r1 = await repo.getNextOccasion(
        hit!.subtract(const Duration(days: 1)),
      );
      r1.fold((_) => fail('expected Right'), (o) {
        expect(o!.daysUntil, 1);
      });

      final r3 = await repo.getNextOccasion(
        hit.subtract(const Duration(days: 3)),
      );
      r3.fold((_) => fail('expected Right'), (o) {
        expect(o!.daysUntil, 3);
      });
    });
  });
}
