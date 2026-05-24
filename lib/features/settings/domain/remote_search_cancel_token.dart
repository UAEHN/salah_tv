import 'dart:async';

/// Domain-pure cancel signal for a remote city search.
///
/// The data layer bridges this to `dio.CancelToken` so an in-flight HTTP
/// request is aborted when the user keeps typing. Keeping the domain free
/// of a `dio` import preserves the dependency direction.
class RemoteSearchCancelToken {
  final Completer<void> _completer = Completer<void>();
  bool _cancelled = false;

  bool get isCancelled => _cancelled;

  /// Resolves the moment [cancel] is called.
  Future<void> get whenCancelled => _completer.future;

  void cancel() {
    if (_cancelled) return;
    _cancelled = true;
    _completer.complete();
  }
}
