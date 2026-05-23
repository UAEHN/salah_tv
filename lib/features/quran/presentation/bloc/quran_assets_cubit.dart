import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/i_quran_assets_repository.dart';
import 'quran_assets_state.dart';

/// Drives the QCF v2 font bundle's lifecycle: probes the disk on
/// startup, kicks off the on-demand download, and exposes a delete
/// action for the settings sheet.
class QuranAssetsCubit extends Cubit<QuranAssetsState> {
  final IQuranAssetsRepository _repo;
  StreamSubscription<int>? _downloadSub;

  QuranAssetsCubit(this._repo)
      : super(QuranAssetsState.initial(_repo.totalPages));

  /// Reads the disk and, when the bundle is already complete,
  /// registers every page font with the Flutter engine so the reader
  /// can render synchronously. Call once at app startup AND when the
  /// gate widget mounts.
  Future<void> probe() async {
    final count = await _repo.downloadedCount();
    if (count >= _repo.totalPages) {
      await _repo.registerAllFonts();
      emit(state.copyWith(
        status: QuranAssetsStatus.ready,
        downloadedCount: count,
      ));
    } else {
      emit(state.copyWith(
        status: QuranAssetsStatus.notDownloaded,
        downloadedCount: count,
      ));
    }
  }

  /// Starts (or resumes) the bundle download. On completion the fonts
  /// are registered and `status` flips to [QuranAssetsStatus.ready].
  Future<void> startDownload() async {
    if (state.status == QuranAssetsStatus.downloading) return;
    emit(state.copyWith(status: QuranAssetsStatus.downloading, error: null));
    await _downloadSub?.cancel();
    _downloadSub = _repo.download().listen(
      (n) => emit(state.copyWith(downloadedCount: n)),
      onError: (Object e) => emit(state.copyWith(
        status: QuranAssetsStatus.notDownloaded,
        error: e.toString(),
      )),
      onDone: () async {
        await _repo.registerAllFonts();
        emit(state.copyWith(status: QuranAssetsStatus.ready));
      },
    );
  }

  /// Cancels any in-flight download and rolls the status back so the
  /// gate UI surfaces the "Download" prompt again. Files already on
  /// disk are kept — the user can resume later without re-fetching.
  Future<void> cancelDownload() async {
    await _downloadSub?.cancel();
    _downloadSub = null;
    final n = await _repo.downloadedCount();
    emit(state.copyWith(
      status: QuranAssetsStatus.notDownloaded,
      downloadedCount: n,
    ));
  }

  /// Removes every `.woff` from disk. Already-registered fonts remain
  /// in engine memory until the next app launch — see
  /// [IQuranAssetsRepository.deleteAll] for why.
  Future<void> deleteBundle() async {
    emit(state.copyWith(status: QuranAssetsStatus.deleting));
    await _downloadSub?.cancel();
    _downloadSub = null;
    await _repo.deleteAll();
    emit(state.copyWith(
      status: QuranAssetsStatus.notDownloaded,
      downloadedCount: 0,
    ));
  }

  @override
  Future<void> close() async {
    await _downloadSub?.cancel();
    await super.close();
  }
}
