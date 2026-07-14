import 'bus/telemetry_bus.dart';
import 'bus/telemetry_event.dart';
import 'domain/error_record.dart';
import 'policy/error_rate_limiter.dart';
import 'queue/error_upload_flusher.dart';
import 'queue/sqflite_error_queue.dart';

/// The durable tail shared by every capture path: rate-limit → enqueue →
/// wake the flusher → announce on the bus (source=error_reporting, so the
/// breadcrumb/health subscribers see and by contract ignore our own writes —
/// the loop guard).
///
/// Extracted from [ErrorReportingService] so the native-crash bridge persists
/// through the exact same pipeline: one source of persistence truth.
class ErrorRecordSink {
  ErrorRecordSink({
    required SqfliteErrorQueue queue,
    required ErrorUploadFlusher flusher,
    required ErrorRateLimiter rateLimiter,
    required TelemetryBus bus,
  }) : _queue = queue,
       _flusher = flusher,
       _rateLimiter = rateLimiter,
       _bus = bus;

  final SqfliteErrorQueue _queue;
  final ErrorUploadFlusher _flusher;
  final ErrorRateLimiter _rateLimiter;
  final TelemetryBus _bus;

  Future<void> persist(ErrorRecord record) async {
    if (!await _rateLimiter.allow(record.fingerprint)) return;
    final isQueued = await _queue.enqueue(record.toJson());
    if (isQueued) _flusher.nudge();
    _bus.publish(
      source: TelemetrySource.errorReporting,
      name: 'error_recorded',
      params: {
        'fingerprint': record.fingerprint,
        'severity': record.severity.wireName,
        'kind': record.kind,
      },
    );
  }

  Future<void> dispose() => _flusher.dispose();
}
