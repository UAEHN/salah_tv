import 'dart:async';

/// App-wide serializer for Nominatim requests.
///
/// Nominatim's public instance enforces ≤ 1 req/sec. This singleton
/// queues concurrent callers behind a single `Future` chain so the
/// guarantee holds regardless of how many places trigger a search.
/// Callers should re-check their own cancellation state after
/// [acquire] returns — the throttle still consumes the slot if the
/// caller bailed mid-wait, which preserves the rate-limit invariant.
class NominatimThrottler {
  /// Slightly above 1000ms to absorb clock skew and stay polite.
  static const Duration _minGap = Duration(milliseconds: 1100);

  Future<void> _previous = Future.value();
  DateTime? _lastFire;

  Future<void> acquire() {
    final completer = Completer<void>();
    final prev = _previous;
    _previous = completer.future;
    return prev.then((_) async {
      final now = DateTime.now();
      if (_lastFire != null) {
        final delta = now.difference(_lastFire!);
        if (delta < _minGap) {
          await Future.delayed(_minGap - delta);
        }
      }
      _lastFire = DateTime.now();
      completer.complete();
    });
  }
}
