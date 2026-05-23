/// Lifecycle phase of the QCF v2 font bundle.
enum QuranAssetsStatus {
  /// First mount — we haven't asked the disk yet.
  unknown,

  /// Disk has 0..(total-1) `.woff` files; the gate UI shows the
  /// "Download" prompt with the byte size estimate.
  notDownloaded,

  /// A `Stream<int>` from the repo is actively pulling pages.
  downloading,

  /// All 604 fonts are on disk and registered with the engine; the
  /// reader can render any page synchronously.
  ready,

  /// `deleteAll` is in flight; the UI greys out the surah index.
  deleting,
}

class QuranAssetsState {
  final QuranAssetsStatus status;
  final int downloadedCount;
  final int totalCount;
  final String? error;

  const QuranAssetsState({
    required this.status,
    required this.downloadedCount,
    required this.totalCount,
    this.error,
  });

  const QuranAssetsState.initial(int total)
      : status = QuranAssetsStatus.unknown,
        downloadedCount = 0,
        totalCount = total,
        error = null;

  QuranAssetsState copyWith({
    QuranAssetsStatus? status,
    int? downloadedCount,
    Object? error = _sentinel,
  }) {
    return QuranAssetsState(
      status: status ?? this.status,
      downloadedCount: downloadedCount ?? this.downloadedCount,
      totalCount: totalCount,
      error: identical(error, _sentinel) ? this.error : error as String?,
    );
  }

  double get progress =>
      totalCount == 0 ? 0 : downloadedCount / totalCount;
}

const _sentinel = Object();
