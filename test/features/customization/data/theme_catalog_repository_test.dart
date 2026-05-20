import 'package:flutter_test/flutter_test.dart';

import 'package:ghasaq/core/app_colors.dart';
import 'package:ghasaq/features/customization/data/mobile_theme_palettes.dart';
import 'package:ghasaq/features/customization/data/theme_catalog_repository_impl.dart';

void main() {
  group('ThemeCatalogRepositoryImpl', () {
    const repo = ThemeCatalogRepositoryImpl();

    test('returns legacy + Islamic palettes — total count matches sources',
        () async {
      final result = await repo.getAll();
      expect(
        result.isRight(),
        isTrue,
        reason: 'expected Right but got $result',
      );
      result.fold((_) {}, (palettes) {
        expect(
          palettes.length,
          kThemePalettes.length + kMobileExtraPalettes.length,
        );
      });
    });

    test('legacy palettes precede Islamic palettes in returned order',
        () async {
      final result = await repo.getAll();
      result.fold((_) => fail('expected Right'), (palettes) {
        // Find the index where the first non-legacy entry appears.
        final firstIslamicIndex = palettes.indexWhere((p) => !p.isLegacy);
        // Every entry before it must be legacy.
        for (var i = 0; i < firstIslamicIndex; i++) {
          expect(palettes[i].isLegacy, isTrue);
        }
        // Every entry after it must be islamic.
        for (var i = firstIslamicIndex; i < palettes.length; i++) {
          expect(palettes[i].isLegacy, isFalse);
        }
      });
    });

    test('every palette id is unique', () async {
      final result = await repo.getAll();
      result.fold((_) => fail('expected Right'), (palettes) {
        final ids = palettes.map((p) => p.id).toSet();
        expect(ids.length, palettes.length);
      });
    });

    test('every palette carries a non-empty labelKey', () async {
      final result = await repo.getAll();
      result.fold((_) => fail('expected Right'), (palettes) {
        for (final p in palettes) {
          expect(p.labelKey, isNotEmpty, reason: 'palette ${p.id}');
        }
      });
    });

    test('Islamic palette ids match mobile_theme_palettes keys', () async {
      final result = await repo.getAll();
      result.fold((_) => fail('expected Right'), (palettes) {
        final islamicIds =
            palettes.where((p) => !p.isLegacy).map((p) => p.id).toSet();
        expect(islamicIds, kMobileExtraPalettes.keys.toSet());
      });
    });

    test('legacy palette ids match kThemePalettes keys', () async {
      final result = await repo.getAll();
      result.fold((_) => fail('expected Right'), (palettes) {
        final legacyIds =
            palettes.where((p) => p.isLegacy).map((p) => p.id).toSet();
        expect(legacyIds, kThemePalettes.keys.toSet());
      });
    });
  });
}
