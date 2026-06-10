import '../../features/customization/data/quran_font_catalog_repository_impl.dart';
import '../../features/customization/data/theme_catalog_repository_impl.dart';
import '../../features/customization/domain/i_appearance_writer_port.dart';
import '../../features/customization/domain/i_quran_font_catalog_repository.dart';
import '../../features/customization/domain/i_theme_catalog_repository.dart';
import '../../features/customization/domain/usecases/apply_quran_font.dart';
import '../../features/customization/domain/usecases/apply_theme_palette.dart';
import '../../features/customization/domain/usecases/get_all_quran_fonts.dart';
import '../../features/customization/domain/usecases/get_all_theme_palettes.dart';
import '../../injection.dart';

/// Mobile-only DI for the customization feature (theme & font pickers).
///
/// Repositories are stateless catalogs — `lazySingleton` keeps a single
/// instance per process. Read use-cases are factories. The `Apply*` use-cases
/// take an `IAppearanceWriterPort` runtime parameter because the adapter is
/// constructed in the widget tree where `SettingsProvider` is available
/// (mirrors `INotificationOnboardingFlagPort` pattern, CLAUDE.md §8).
void registerCustomization() {
  getIt.registerLazySingleton<IThemeCatalogRepository>(
    () => const ThemeCatalogRepositoryImpl(),
  );
  getIt.registerLazySingleton<IQuranFontCatalogRepository>(
    () => const QuranFontCatalogRepositoryImpl(),
  );

  getIt.registerFactory<GetAllThemePalettesUseCase>(
    () => GetAllThemePalettesUseCase(getIt<IThemeCatalogRepository>()),
  );
  getIt.registerFactory<GetAllQuranFontsUseCase>(
    () => GetAllQuranFontsUseCase(getIt<IQuranFontCatalogRepository>()),
  );
  getIt.registerFactoryParam<
    ApplyThemePaletteUseCase,
    IAppearanceWriterPort,
    void
  >((writer, _) => ApplyThemePaletteUseCase(writer));
  getIt
      .registerFactoryParam<ApplyQuranFontUseCase, IAppearanceWriterPort, void>(
        (writer, _) => ApplyQuranFontUseCase(writer),
      );
}
