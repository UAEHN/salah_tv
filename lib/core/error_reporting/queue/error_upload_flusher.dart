import 'dart:async';
import 'dart:math';

import '../context/network_state_monitor.dart';
import '../upload/firestore_error_uploader.dart';
import 'sqflite_error_queue.dart';

/// Drains the offline queue to Firestore in FIFO order. Triggers: startup,
/// connectivity restored, a 2-minute periodic tick, and a nudge after every
/// enqueue. A failed upload stops the pass and arms exponential backoff so a
/// dead network never spins the loop.
class ErrorUploadFlusher {
  ErrorUploadFlusher({
    required SqfliteErrorQueue queue,
    required FirestoreErrorUploader uploader,
    required NetworkStateMonitor networkMonitor,
    Duration period = const Duration(minutes: 2),
  }) : _queue = queue,
       _uploader = uploader,
       _networkMonitor = networkMonitor,
       _period = period;

  final SqfliteErrorQueue _queue;
  final FirestoreErrorUploader _uploader;
  final NetworkStateMonitor _networkMonitor;
  final Duration _period;

  Timer? _periodicTimer; // disposed in dispose()
  StreamSubscription<bool>? _connectivitySub; // disposed in dispose()
  bool _isFlushing = false;
  int _consecutiveFailures = 0;
  DateTime _nextAttemptAt = DateTime.fromMillisecondsSinceEpoch(0);

  static const int _batchSize = 10;
  static const Duration _baseBackoff = Duration(seconds: 30);
  static const Duration _maxBackoff = Duration(minutes: 15);

  void start() {
    _periodicTimer ??= Timer.periodic(_period, (_) => nudge());
    _connectivitySub ??= _networkMonitor.onOnline.listen((_) {
      _consecutiveFailures = 0;
      _nextAttemptAt = DateTime.fromMillisecondsSinceEpoch(0);
      nudge();
    });
    nudge();
  }

  /// Fire-and-forget flush request — safe to call from anywhere.
  void nudge() {
    unawaited(_flush());
  }

  Future<void> _flush() async {
    if (_isFlushing) return;
    if (DateTime.now().isBefore(_nextAttemptAt)) return;
    _isFlushing = true;
    try {
      // Known-offline: skip the pass instead of burning a 15s upload
      // timeout per row. The onOnline listener re-nudges immediately.
      final network = await _networkMonitor.snapshot();
      if (network['connected'] == false) return;
      while (true) {
        final batch = await _queue.peekOldest(_batchSize);
        if (batch.isEmpty) break;
        final uploadedIds = <int>[];
        var hasFailure = false;
        for (final item in batch) {
          final payload = item.payload;
          if (payload == null) {
            uploadedIds.add(item.id); // Corrupt row — drop it.
            continue;
          }
          if (await _uploader.upload(payload)) {
            uploadedIds.add(item.id);
          } else {
            hasFailure = true;
            break;
          }
        }
        await _queue.delete(uploadedIds);
        if (hasFailure) {
          _registerFailure();
          return;
        }
      }
      _consecutiveFailures = 0;
    } catch (_) {
      _registerFailure();
    } finally {
      _isFlushing = false;
    }
  }

  void _registerFailure() {
    _consecutiveFailures = min(_consecutiveFailures + 1, 6);
    final backoffMs = min(
      _baseBackoff.inMilliseconds * pow(2, _consecutiveFailures - 1).toInt(),
      _maxBackoff.inMilliseconds,
    );
    _nextAttemptAt = DateTime.now().add(Duration(milliseconds: backoffMs));
  }

  Future<void> dispose() async {
    _periodicTimer?.cancel();
    _periodicTimer = null;
    await _connectivitySub?.cancel();
    _connectivitySub = null;
  }
}
