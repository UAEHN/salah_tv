import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/i_page_image_repository.dart';
import '../../domain/i_quran_offline_choice_repository.dart';
import 'page_image_download_state.dart';

/// Drives the bulk Mushaf page-image download flow. A lazy singleton —
/// the bottom-nav tap on the Quran tab kicks `probe()`, the choice
/// sheet calls `chooseDownload`/`chooseStayOnline`, and the progress
/// banner subscribes to its state.
class PageImageDownloadCubit extends Cubit<PageImageDownloadState> {
  final IPageImageRepository _imageRepo;
  final IQuranOfflineChoiceRepository _choiceRepo;
  StreamSubscription<int>? _downloadSub;

  PageImageDownloadCubit({
    required IPageImageRepository imageRepo,
    required IQuranOfflineChoiceRepository choiceRepo,
  })  : _imageRepo = imageRepo,
        _choiceRepo = choiceRepo,
        super(PageImageDownloadState.initial(imageRepo.totalPages));

  /// Reads the on-disk page count + the persisted "has been asked"
  /// flag and emits the resolved initial state. Idempotent; safe to
  /// call on every Quran-tab focus.
  Future<void> probe() async {
    final chosen = await _choiceRepo.hasChosenOfflineMode();
    final count = await _imageRepo.downloadedCount();
    final total = _imageRepo.totalPages;
    emit(state.copyWith(
      hasChosenOfflineMode: chosen,
      downloadedCount: count,
      status: count >= total
          ? PageImageDownloadStatus.complete
          : PageImageDownloadStatus.idle,
    ));
  }

  /// User picked "Download the full Mushaf for offline use" from the
  /// choice sheet — persist the flag and kick the bulk download in
  /// the background.
  Future<void> chooseDownload() async {
    await _choiceRepo.markChosen();
    emit(state.copyWith(hasChosenOfflineMode: true));
    await startBulkDownload();
  }

  /// User picked "Keep using online mode" — persist the flag so the
  /// sheet stops appearing. No download is started; the reader will
  /// fetch pages on demand and cache visited ones.
  Future<void> chooseStayOnline() async {
    await _choiceRepo.markChosen();
    emit(state.copyWith(hasChosenOfflineMode: true));
  }

  /// Wipes every cached page PNG. The user triggers this from the
  /// storage card on the Quran tab — handy for freeing the ~25 MB
  /// when the device is low on space.
  Future<void> deleteAll() async {
    await _downloadSub?.cancel();
    _downloadSub = null;
    await _imageRepo.deleteAll();
    emit(state.copyWith(
      status: PageImageDownloadStatus.idle,
      downloadedCount: 0,
    ));
  }

  /// Starts or resumes the bulk download. Safe to call on top of a
  /// running download — returns immediately in that case.
  Future<void> startBulkDownload() async {
    if (state.status == PageImageDownloadStatus.downloading) return;
    emit(state.copyWith(
      status: PageImageDownloadStatus.downloading,
      error: null,
    ));
    await _downloadSub?.cancel();
    _downloadSub = _imageRepo.downloadAll().listen(
          (n) => emit(state.copyWith(downloadedCount: n)),
          onError: (Object e) => emit(state.copyWith(
            status: PageImageDownloadStatus.error,
            error: e.toString(),
          )),
          onDone: () => emit(state.copyWith(
            status: PageImageDownloadStatus.complete,
          )),
        );
  }

  @override
  Future<void> close() async {
    await _downloadSub?.cancel();
    return super.close();
  }
}
