import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/i_quran_assets_repository.dart';
import 'quran_assets_state.dart';

/// Drives the QCF v2 font bundle's lifecycle: probes the disk on
/// startup, kicks off the on-demand download, and exposes a delete
/// action for the settings sheet.
///
/// Font *registration* is no longer the cubit's job — see
/// [IQuranAssetsRepository.ensureFontForPage]. The reader page widget
/// pulls its own font on first paint and prefetches neighbors, so the
/// cubit only tracks gross lifecycle states (downloaded vs not).
class QuranAssetsCubit extends Cubit<QuranAssetsState> {
  final IQuranAssetsRepository _repo;
  StreamSubscription<int>? _downloadSub;

  QuranAssetsCubit(this._repo)
      : super(QuranAssetsState.initial(_repo.totalPages));

  /// Cheap disk probe. With the rewritten repository this is a single
  /// `Directory.list()` (≈ 5–20 ms) — no font registration, no
  /// per-page `File.exists()` storm. Safe to call from any `initState`.
  Future<void> probe() async {
    final count = await _repo.downloadedCount();
    emit(state.copyWith(
      status: count >= _repo.totalPages
          ? QuranAssetsStatus.ready
          : QuranAssetsStatus.notDownloaded,
      downloadedCount: count,
    ));
  }

  /// Starts (or resumes) the bundle download. On completion the
  /// status flips to [QuranAssetsStatus.ready]; individual page fonts
  /// are registered lazily from the reader as the user swipes.
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
      onDone: () => emit(state.copyWith(status: QuranAssetsStatus.ready)),
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

  /// Forwards to the repository so the reader page widget can request
  /// its font right before painting. Idempotent and coalesced — see
  /// [IQuranAssetsRepository.ensureFontForPage].
  Future<bool> ensureFontForPage(int pageNumber) =>
      _repo.ensureFontForPage(pageNumber);

  /// Sync probe used by the reader to skip a `FutureBuilder` rebuild
  /// when the page's font is already live.
  bool isFontRegistered(int pageNumber) => _repo.isFontRegistered(pageNumber);

  @override
  Future<void> close() async {
    await _downloadSub?.cancel();
    await super.close();
  }
}
