import 'package:flutter_test/flutter_test.dart';

import 'package:ghasaq/core/error/failures.dart';
import 'package:ghasaq/features/customization/data/quran_font_catalog_repository_impl.dart';
import 'package:ghasaq/features/customization/domain/usecases/apply_quran_font.dart';
import 'package:ghasaq/features/customization/domain/usecases/get_all_quran_fonts.dart';
import 'package:ghasaq/features/customization/presentation/bloc/font_picker_cubit.dart';
import 'package:ghasaq/features/customization/presentation/bloc/font_picker_state.dart';

import '../fakes/fake_appearance_writer.dart';

void main() {
  group('FontPickerCubit', () {
    test('load → Loaded with current family', () async {
      final writer = FakeAppearanceWriter();
      final cubit = FontPickerCubit(
        getAll: GetAllQuranFontsUseCase(
          const QuranFontCatalogRepositoryImpl(),
        ),
        apply: ApplyQuranFontUseCase(writer),
      );

      await cubit.load('Kufi');

      expect(cubit.state, isA<FontPickerLoaded>());
      final loaded = cubit.state as FontPickerLoaded;
      expect(loaded.selectedFamily, 'Kufi');
      expect(loaded.fonts, isNotEmpty);
      await cubit.close();
    });

    test('select → flips selection and persists', () async {
      final writer = FakeAppearanceWriter();
      final cubit = FontPickerCubit(
        getAll: GetAllQuranFontsUseCase(
          const QuranFontCatalogRepositoryImpl(),
        ),
        apply: ApplyQuranFontUseCase(writer),
      );

      await cubit.load('Kufi');
      await cubit.select('Cairo');

      final loaded = cubit.state as FontPickerLoaded;
      expect(loaded.selectedFamily, 'Cairo');
      expect(writer.fontFamiliesWritten, ['Cairo']);
      await cubit.close();
    });

    test('select → rollback when writer fails', () async {
      final writer = FakeAppearanceWriter()
        ..nextFailure = const CacheFailure('boom');
      final cubit = FontPickerCubit(
        getAll: GetAllQuranFontsUseCase(
          const QuranFontCatalogRepositoryImpl(),
        ),
        apply: ApplyQuranFontUseCase(writer),
      );

      await cubit.load('Kufi');
      await cubit.select('Cairo');

      final loaded = cubit.state as FontPickerLoaded;
      expect(loaded.selectedFamily, 'Kufi');
      await cubit.close();
    });
  });
}
