import 'package:flutter_test/flutter_test.dart';

import 'package:ghasaq/features/today/data/daily_verse_repository_impl.dart';
import 'package:ghasaq/features/today/data/daily_verses_catalog.dart';

void main() {
  const repo = DailyVerseRepositoryImpl();

  group('DailyVerseRepositoryImpl', () {
    test('returns a verse for any in-year date', () async {
      final result = await repo.getVerseForDay(DateTime(2026, 5, 7));
      expect(result.isRight(), isTrue);
    });

    test('same date → same verse (deterministic across calls)', () async {
      final a = await repo.getVerseForDay(DateTime(2026, 5, 7));
      final b = await repo.getVerseForDay(DateTime(2026, 5, 7));
      expect(a, equals(b));
    });

    test('rotation index = dayOfYear % catalog.length', () async {
      // 1 January 2026 → dayOfYear=1, index=1 % 30 = 1
      final result = await repo.getVerseForDay(DateTime(2026, 1, 1));
      result.fold((_) => fail('expected Right'), (v) {
        expect(v, kDailyVersesCatalog[1 % kDailyVersesCatalog.length]);
      });
    });

    test('different dates → different verses (over the rotation)', () async {
      final a = await repo.getVerseForDay(DateTime(2026, 1, 1));
      final b = await repo.getVerseForDay(DateTime(2026, 1, 2));
      a.fold((_) => fail('expected Right'), (av) {
        b.fold((_) => fail('expected Right'), (bv) {
          expect(av, isNot(bv));
        });
      });
    });
  });
}
