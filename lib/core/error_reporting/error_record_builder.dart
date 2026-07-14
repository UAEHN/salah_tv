import 'breadcrumbs/breadcrumb_recorder.dart';
import 'classify/error_categorizer.dart';
import 'classify/likely_cause_hints.dart';
import 'context/error_context_collector.dart';
import 'domain/error_record.dart';
import 'domain/error_severity.dart';
import 'fingerprint/error_fingerprinter.dart';
import 'fingerprint/stack_frame_parser.dart';

/// Pure assembly of [ErrorRecord]s: enriches a raw error (or silent failure)
/// with origin, category, fingerprint, breadcrumbs, hint and all context
/// snapshots. Keeps [ErrorReportingService] a thin orchestrator.
class ErrorRecordBuilder {
  ErrorRecordBuilder({
    required ErrorContextCollector collector,
    required BreadcrumbRecorder breadcrumbs,
    ErrorFingerprinter fingerprinter = const ErrorFingerprinter(),
    ErrorCategorizer categorizer = const ErrorCategorizer(),
    StackFrameParser parser = const StackFrameParser(),
  }) : _collector = collector,
       _breadcrumbs = breadcrumbs,
       _fingerprinter = fingerprinter,
       _categorizer = categorizer,
       _parser = parser;

  final ErrorContextCollector _collector;
  final BreadcrumbRecorder _breadcrumbs;
  final ErrorFingerprinter _fingerprinter;
  final ErrorCategorizer _categorizer;
  final StackFrameParser _parser;

  /// Monotonic per-session sequence — combined with the session id it makes
  /// every record's [ErrorRecord.eventId] unique and retry-stable.
  int _sequence = 0;

  static const int _maxMessageLength = 2048;
  static const int _maxStackLength = 16384;

  String _nextEventId() => '${_collector.sessionId}-${++_sequence}';

  Future<ErrorRecord> buildException({
    required String name,
    required Object error,
    required ErrorSeverity severity,
    StackTrace? stack,
    String? categoryOverride,
    Map<String, Object?>? extra,
  }) async {
    final stackString = _truncate(
      (stack ?? StackTrace.current).toString(),
      _maxStackLength,
    );
    final message = _truncate(error.toString(), _maxMessageLength);
    final errorType = error.runtimeType.toString();
    final frame = _parser.topAppFrame(stackString);
    final category =
        categoryOverride ??
        _categorizer.categorize(
          errorType: errorType,
          message: message,
          stack: stackString,
        );
    final route = _collector.currentRoute();
    return ErrorRecord(
      eventId: _nextEventId(),
      fingerprint: _fingerprinter.fingerprint(
        errorType: errorType,
        category: category,
        message: message,
        route: route,
        topFrame: frame,
      ),
      kind: ErrorKind.exception,
      severity: severity,
      name: name,
      errorType: errorType,
      message: message,
      category: category,
      origin: frame?.toJson() ?? const {'file': 'unknown', 'member': 'unknown'},
      stack: stackString,
      breadcrumbs: _breadcrumbs.snapshot(),
      route: route,
      device: await _collector.deviceContext(),
      app: _collector.appContext(),
      network: await _collector.networkContext(),
      context: {..._collector.settingsContext(), ...?extra},
      likelyCause: LikelyCauseHints.hintFor(
        errorType: errorType,
        message: message,
      ),
      clientAt: DateTime.now(),
    );
  }

  Future<ErrorRecord> buildSilentFailure({
    required String name,
    required String flow,
    required String prayerKey,
    required String failedStep,
    required List<String> stepsCompleted,
    required int waitedMs,
    required ErrorSeverity severity,
    int? secondsPlayed,
    String? expected,
    String? actual,
    String? message,
    Map<String, Object?>? evidence,
  }) async {
    return ErrorRecord(
      eventId: _nextEventId(),
      fingerprint: _fingerprinter.silentFailureFingerprint(
        flow: flow,
        failedStep: failedStep,
      ),
      kind: ErrorKind.silentFailure,
      severity: severity,
      name: name,
      errorType: 'SilentFailure',
      message: _truncate(message ?? name, _maxMessageLength),
      category: ErrorCategories.functionalHealth,
      origin: {'file': 'core/error_reporting/health', 'member': flow},
      stack: '',
      breadcrumbs: _breadcrumbs.snapshot(),
      route: _collector.currentRoute(),
      flow: {
        'flow': flow,
        'prayer_key': prayerKey,
        'failed_step': failedStep,
        'steps_completed': stepsCompleted,
        'waited_ms': waitedMs,
        'seconds_played': ?secondsPlayed,
        'expected': ?expected,
        'actual': ?actual,
        // Decisive signals for triage without reading breadcrumbs: whether the
        // sound provably played, whether the app was foreground, any clock jump.
        'evidence': ?evidence,
      },
      device: await _collector.deviceContext(),
      app: _collector.appContext(),
      network: await _collector.networkContext(),
      context: _collector.settingsContext(),
      clientAt: DateTime.now(),
    );
  }

  static String _truncate(String value, int max) =>
      value.length > max ? value.substring(0, max) : value;
}
