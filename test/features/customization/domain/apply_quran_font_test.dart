import 'package:flutter_test/flutter_test.dart';

import 'package:ghasaq/core/error/failures.dart';
import 'package:ghasaq/features/customization/domain/usecases/apply_quran_font.dart';

import '../fakes/fake_appearance_writer.dart';

void main() {
  group('ApplyQuranFontUseCase', () {
    test('forwards a non-empty family to the writer', () async {
      final writer = FakeAppearanceWriter();
      final useCase = ApplyQuranFontUseCase(writer);

      final result = await useCase('Cairo');

      expect(result.isRight(), isTrue);
      expect(writer.fontFamiliesWritten, ['Cairo']);
    });

    test('returns Left(CacheFailure) on empty family', () async {
      final writer = FakeAppearanceWriter();
      final useCase = ApplyQuranFontUseCase(writer);

      final result = await useCase('');

      expect(result.isLeft(), isTrue);
      result.fold(
        (failure) => expect(failure, isA<CacheFailure>()),
        (_) => fail('expected Left'),
      );
      expect(writer.fontFamiliesWritten, isEmpty);
    });
  });
}
