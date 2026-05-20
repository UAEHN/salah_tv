import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:ghasaq/core/error/failures.dart';
import 'package:ghasaq/features/customization/data/theme_catalog_repository_impl.dart';
import 'package:ghasaq/features/customization/domain/entities/theme_palette_info.dart';
import 'package:ghasaq/features/customization/domain/i_theme_catalog_repository.dart';
import 'package:ghasaq/features/customization/domain/usecases/apply_theme_palette.dart';
import 'package:ghasaq/features/customization/domain/usecases/get_all_theme_palettes.dart';
import 'package:ghasaq/features/customization/presentation/bloc/theme_picker_cubit.dart';
import 'package:ghasaq/features/customization/presentation/bloc/theme_picker_state.dart';

import '../fakes/fake_appearance_writer.dart';

class _FailingCatalog implements IThemeCatalogRepository {
  @override
  Future<Either<Failure, List<ThemePaletteInfo>>> getAll() async {
    return const Left(CacheFailure('boom'));
  }
}

void main() {
  group('ThemePickerCubit', () {
    test('load → emits Loading then Loaded with current selection', () async {
      final writer = FakeAppearanceWriter();
      final cubit = ThemePickerCubit(
        getAll: GetAllThemePalettesUseCase(
          const ThemeCatalogRepositoryImpl(),
        ),
        apply: ApplyThemePaletteUseCase(writer),
      );

      final emissions = <ThemePickerState>[];
      final sub = cubit.stream.listen(emissions.add);

      await cubit.load('green');
      // Allow listener microtask to flush before reading the buffered list.
      await Future<void>.delayed(Duration.zero);

      expect(emissions.first, isA<ThemePickerLoading>());
      expect(cubit.state, isA<ThemePickerLoaded>());
      final loaded = cubit.state as ThemePickerLoaded;
      expect(loaded.selectedId, 'green');
      expect(loaded.isApplying, isFalse);
      expect(loaded.palettes, isNotEmpty);

      await sub.cancel();
      await cubit.close();
    });

    test('load → emits Error when repo fails', () async {
      final writer = FakeAppearanceWriter();
      final cubit = ThemePickerCubit(
        getAll: GetAllThemePalettesUseCase(_FailingCatalog()),
        apply: ApplyThemePaletteUseCase(writer),
      );

      await cubit.load('green');

      expect(cubit.state, isA<ThemePickerError>());
      await cubit.close();
    });

    test('select → flips selection and persists', () async {
      final writer = FakeAppearanceWriter();
      final cubit = ThemePickerCubit(
        getAll: GetAllThemePalettesUseCase(
          const ThemeCatalogRepositoryImpl(),
        ),
        apply: ApplyThemePaletteUseCase(writer),
      );

      await cubit.load('green');
      await cubit.select('desert_dawn');

      expect(cubit.state, isA<ThemePickerLoaded>());
      final loaded = cubit.state as ThemePickerLoaded;
      expect(loaded.selectedId, 'desert_dawn');
      expect(loaded.isApplying, isFalse);
      expect(writer.themeKeysWritten, ['desert_dawn']);

      await cubit.close();
    });

    test('select with same id → no-op (no write)', () async {
      final writer = FakeAppearanceWriter();
      final cubit = ThemePickerCubit(
        getAll: GetAllThemePalettesUseCase(
          const ThemeCatalogRepositoryImpl(),
        ),
        apply: ApplyThemePaletteUseCase(writer),
      );

      await cubit.load('green');
      await cubit.select('green');

      expect(writer.themeKeysWritten, isEmpty);
      await cubit.close();
    });

    test('select → on writer failure, rolls selection back', () async {
      final writer = FakeAppearanceWriter()
        ..nextFailure = const CacheFailure('persist failed');
      final cubit = ThemePickerCubit(
        getAll: GetAllThemePalettesUseCase(
          const ThemeCatalogRepositoryImpl(),
        ),
        apply: ApplyThemePaletteUseCase(writer),
      );

      await cubit.load('green');
      await cubit.select('desert_dawn');

      final loaded = cubit.state as ThemePickerLoaded;
      expect(loaded.selectedId, 'green');
      expect(loaded.isApplying, isFalse);

      await cubit.close();
    });
  });
}
