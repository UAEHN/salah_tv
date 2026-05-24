import 'package:flutter/foundation.dart';

/// Lifecycle of the bulk Mushaf-page-image download flow.
enum PageImageDownloadStatus {
  /// First mount — we haven't asked the disk yet.
  unknown,

  /// User hasn't started a bulk download (either chose "stay online"
  /// or hasn't been asked yet). Pages still cache on-disk as the
  /// reader fetches them on demand.
  idle,

  /// A bulk download is actively pulling pages from the CDN.
  downloading,

  /// All 604 pages are on disk — reader works fully offline.
  complete,

  /// The last bulk download failed; [PageImageDownloadState.error]
  /// has the message.
  error,
}

@immutable
class PageImageDownloadState {
  final bool hasChosenOfflineMode;
  final PageImageDownloadStatus status;
  final int downloadedCount;
  final int totalCount;
  final String? error;

  const PageImageDownloadState({
    required this.hasChosenOfflineMode,
    required this.status,
    required this.downloadedCount,
    required this.totalCount,
    this.error,
  });

  const PageImageDownloadState.initial(int total)
      : hasChosenOfflineMode = false,
        status = PageImageDownloadStatus.unknown,
        downloadedCount = 0,
        totalCount = total,
        error = null;

  double get progress =>
      totalCount == 0 ? 0 : downloadedCount / totalCount;

  bool get isDownloading =>
      status == PageImageDownloadStatus.downloading;

  bool get isComplete =>
      status == PageImageDownloadStatus.complete;

  PageImageDownloadState copyWith({
    bool? hasChosenOfflineMode,
    PageImageDownloadStatus? status,
    int? downloadedCount,
    int? totalCount,
    Object? error = _sentinel,
  }) {
    return PageImageDownloadState(
      hasChosenOfflineMode:
          hasChosenOfflineMode ?? this.hasChosenOfflineMode,
      status: status ?? this.status,
      downloadedCount: downloadedCount ?? this.downloadedCount,
      totalCount: totalCount ?? this.totalCount,
      error: identical(error, _sentinel) ? this.error : error as String?,
    );
  }
}

const _sentinel = Object();
