import 'package:dio/dio.dart';

import '../../features/quran/data/ayah_audio_service.dart';
import '../../features/quran/data/file_ayah_audio_cache.dart';
import '../../features/quran/data/mushaf_preferences_repository.dart';
import '../../features/quran/data/quran_bookmark_repository.dart';
import '../../features/quran/data/quran_intro_flag_repository.dart';
import '../../features/quran/data/quran_text_repository.dart';
import '../../features/quran/domain/i_ayah_audio_cache.dart';
import '../../features/quran/domain/i_ayah_audio_port.dart';
import '../../features/quran/domain/i_mushaf_preferences_repository.dart';
import '../../features/quran/domain/i_quran_bookmark_repository.dart';
import '../../features/quran/domain/i_quran_intro_flag_repository.dart';
import '../../features/quran/domain/i_quran_text_repository.dart';
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
