import 'package:dio/dio.dart';

import '../../features/quran/data/ayah_audio_service.dart';
import '../../features/quran/data/ayah_bounds_repository.dart';
import '../../features/quran/data/file_ayah_audio_cache.dart';
import '../../features/quran/data/mushaf_preferences_repository.dart';
import '../../features/quran/data/quran_bookmark_repository.dart';
import '../../features/quran/data/quran_intro_flag_repository.dart';
import '../../features/quran/data/quran_offline_choice_repository.dart';
import '../../features/quran/data/quran_page_image_repository.dart';
import '../../features/quran/data/quran_text_repository.dart';
import '../../features/quran/domain/i_ayah_audio_cache.dart';
import '../../features/quran/domain/i_ayah_audio_port.dart';
import '../../features/quran/domain/i_ayah_bounds_repository.dart';
import '../../features/quran/domain/i_mushaf_preferences_repository.dart';
import '../../features/quran/domain/i_page_image_repository.dart';
import '../../features/quran/domain/i_quran_bookmark_repository.dart';
import '../../features/quran/domain/i_quran_intro_flag_repository.dart';
import '../../features/quran/domain/i_quran_offline_choice_repository.dart';
import '../../features/quran/domain/i_quran_text_repository.dart';
import '../../features/quran/presentation/bloc/page_image_download_cubit.dart';
import '../../features/quran/domain/usecases/get_bookmark_usecase.dart';
import '../../features/quran/domain/usecases/get_mushaf_page_usecase.dart';
import '../../features/quran/domain/usecases/play_ayah_usecase.dart';
import '../../features/quran/domain/usecases/quran_intro_usecases.dart';
import '../../features/quran/domain/usecases/save_bookmark_usecase.dart';
import '../../features/quran/presentation/bloc/mushaf_reader_cubit.dart';
import '../../injection.dart';

/// Registers the mobile Mushaf reader stack.
/// Mobile-only: TV uses the older background Quran-stream player and does
/// not need per-ayah audio or bookmarks.
void registerQuranReader() {
  getIt.registerLazySingleton<IQuranTextRepository>(
    () => QuranTextRepository(),
  );
  getIt.registerLazySingleton<IQuranBookmarkRepository>(
    () => QuranBookmarkRepository(),
  );
  getIt.registerLazySingleton<IAyahAudioCache>(
    () => FileAyahAudioCache(getIt<Dio>()),
  );
  getIt.registerLazySingleton<IAyahAudioPort>(
    () => AyahAudioService(getIt<IAyahAudioCache>()),
  );
  getIt.registerLazySingleton<IMushafPreferencesRepository>(
    () => MushafPreferencesRepository(),
  );
  getIt.registerLazySingleton<IQuranIntroFlagRepository>(
    () => QuranIntroFlagRepository(),
  );
  // Per-glyph bounding boxes for tap-to-play + highlight overlay.
  // Lazy: the DB download runs the first time the reader opens.
  getIt.registerLazySingleton<IAyahBoundsRepository>(
    () => AyahBoundsRepository(getIt<Dio>()),
  );
  // On-disk store for the 604 Madinah page PNGs. Files land in
  // {appDocs}/quran_pages/ so they survive OS cache eviction —
  // the reader stays usable offline indefinitely.
  getIt.registerLazySingleton<IPageImageRepository>(
    () => QuranPageImageRepository(getIt<Dio>()),
  );
  // One-shot flag for the "download Mushaf for offline?" sheet.
  getIt.registerLazySingleton<IQuranOfflineChoiceRepository>(
    () => QuranOfflineChoiceRepository(),
  );
  // Lazy singleton so the bottom-nav trigger, the choice sheet and
  // the progress banner all see the same state.
  getIt.registerLazySingleton<PageImageDownloadCubit>(
    () => PageImageDownloadCubit(
      imageRepo: getIt<IPageImageRepository>(),
      choiceRepo: getIt<IQuranOfflineChoiceRepository>(),
    ),
  );

  getIt.registerFactory<HasSeenMushafIntroUseCase>(
    () => HasSeenMushafIntroUseCase(getIt<IQuranIntroFlagRepository>()),
  );
  getIt.registerFactory<MarkMushafIntroSeenUseCase>(
    () => MarkMushafIntroSeenUseCase(getIt<IQuranIntroFlagRepository>()),
  );

  getIt.registerFactory<GetMushafPageUseCase>(
    () => GetMushafPageUseCase(getIt<IQuranTextRepository>()),
  );
  getIt.registerFactory<GetBookmarkUseCase>(
    () => GetBookmarkUseCase(getIt<IQuranBookmarkRepository>()),
  );
  getIt.registerFactory<SaveBookmarkUseCase>(
    () => SaveBookmarkUseCase(getIt<IQuranBookmarkRepository>()),
  );
  getIt.registerFactory<PlayAyahUseCase>(
    () => PlayAyahUseCase(getIt<IAyahAudioPort>()),
  );
  getIt.registerFactory<StopAyahAudioUseCase>(
    () => StopAyahAudioUseCase(getIt<IAyahAudioPort>()),
  );

  getIt.registerFactory<MushafReaderCubit>(
    () => MushafReaderCubit(
      textRepo: getIt<IQuranTextRepository>(),
      getPage: getIt<GetMushafPageUseCase>(),
      getBookmark: getIt<GetBookmarkUseCase>(),
      saveBookmark: getIt<SaveBookmarkUseCase>(),
      playAyah: getIt<PlayAyahUseCase>(),
      stopAyah: getIt<StopAyahAudioUseCase>(),
      audioPort: getIt<IAyahAudioPort>(),
      prefsRepo: getIt<IMushafPreferencesRepository>(),
      hasSeenIntro: getIt<HasSeenMushafIntroUseCase>(),
      markIntroSeen: getIt<MarkMushafIntroSeenUseCase>(),
    ),
  );
}
