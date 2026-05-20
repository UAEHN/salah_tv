import 'package:flutter_test/flutter_test.dart';

import 'package:ghasaq/core/error/failures.dart';
import 'package:ghasaq/features/customization/domain/usecases/apply_theme_palette.dart';

import '../fakes/fake_appearance_writer.dart';

void main() {
  group('ApplyThemePaletteUseCase', () {
    test('forwards a non-empty key to the writer', () async {
      final writer = FakeAppearanceWriter();
      final useCase = ApplyThemePaletteUseCase(writer);

      final result = await useCase('desert_dawn');

      expect(result.isRight(), isTrue);
      expect(writer.themeKeysWritten, ['desert_dawn']);
    });

    test('returns Left(CacheFailure) on empty key without touching writer',
        () async {
      final writer = FakeAppearanceWriter();
      final useCase = ApplyThemePaletteUseCase(writer);

      final result = await useCase('');

      expect(result.isLeft(), isTrue);
      result.fold(
        (failure) => expect(failure, isA<CacheFailure>()),
        (_) => fail('expected Left'),
      );
      expect(writer.themeKeysWritten, isEmpty);
    });

    test('propagates writer failure', () async {
      final writer = FakeAppearanceWriter()
        ..nextFailure = const CacheFailure('boom');
      final useCase = ApplyThemePaletteUseCase(writer);

      final result = await useCase('blue');

      expect(result.isLeft(), isTrue);
      expect(writer.themeKeysWritten, isEmpty);
    });
  });
}
