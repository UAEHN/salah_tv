import 'package:flutter_test/flutter_test.dart';

import 'package:ghasaq/features/customization/data/quran_font_catalog_repository_impl.dart';

void main() {
  group('QuranFontCatalogRepositoryImpl', () {
    const repo = QuranFontCatalogRepositoryImpl();

    test('returns the bundled font catalog', () async {
      final result = await repo.getAll();
      expect(result.isRight(), isTrue);
      result.fold((_) {}, (fonts) {
        expect(fonts, isNotEmpty);
      });
    });

    test('every font id is unique', () async {
      final result = await repo.getAll();
      result.fold((_) => fail('expected Right'), (fonts) {
        final ids = fonts.map((f) => f.id).toSet();
        expect(ids.length, fonts.length);
      });
    });

    test('returned list is unmodifiable', () async {
      final result = await repo.getAll();
      result.fold((_) => fail('expected Right'), (fonts) {
        expect(
          () => fonts.add(fonts.first),
          throwsA(isA<UnsupportedError>()),
        );
      });
    });

    test('default Kufi family is present (matches AppSettings default)',
        () async {
      final result = await repo.getAll();
      result.fold((_) => fail('expected Right'), (fonts) {
        expect(fonts.any((f) => f.id == 'Kufi'), isTrue);
      });
    });

    test('every font carries non-empty labelKey', () async {
      final result = await repo.getAll();
      result.fold((_) => fail('expected Right'), (fonts) {
        for (final f in fonts) {
          expect(f.labelKey, isNotEmpty, reason: 'font ${f.id}');
        }
      });
    });
  });
}
