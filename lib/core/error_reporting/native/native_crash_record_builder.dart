import '../classify/error_categorizer.dart';
import '../classify/likely_cause_hints.dart';
import '../context/error_context_collector.dart';
import '../domain/breadcrumb.dart';
import '../domain/error_record.dart';
import '../domain/error_severity.dart';
import '../fingerprint/error_fingerprinter.dart';
import '../fingerprint/stack_frame_parser.dart';

/// Assembles an [ErrorRecord] for a JVM-level crash captured by the native
/// `NativeCrashMarkerHandler` on the PREVIOUS app session (a crash that never
/// reached Dart). Distinct from `ErrorRecordBuilder` because native crashes
/// carry the persisted previous-session breadcrumb trail (not the live ring),
/// always group by the top native frame, and are always fatal.
///
/// Event ids use a dedicated `-nc` infix so they can never collide with the
/// main builder's per-session sequence (both would otherwise start at 1).
class NativeCrashRecordBuilder {
  NativeCrashRecordBuilder({
    required ErrorContextCollector collector,
    ErrorFingerprinter fingerprinter = const ErrorFingerprinter(),
    ErrorCategorizer categorizer = const ErrorCategorizer(),
    StackFrameParser parser = const StackFrameParser(),
  }) : _collector = collector,
       _fingerprinter = fingerprinter,
       _categorizer = categorizer,
       _parser = parser;

  final ErrorContextCollector _collector;
  final ErrorFingerprinter _fingerprinter;
  final ErrorCategorizer _categorizer;
  final StackFrameParser _parser;

  int _sequence = 0;
  static const int _maxMessageLength = 2048;
  static const int _maxStackLength = 16384;

  Future<ErrorRecord> build({
    required String errorType,
    required String message,
    required String stack,
    required List<Breadcrumb> breadcrumbs,
    DateTime? crashAt,
  }) async {
    final stackString = _truncate(stack, _maxStackLength);
    final msg = _truncate(message, _maxMessageLength);
    final frame = _parser.topNativeFrame(stackString);
    // A native crash rarely matches the Dart-oriented rules; default it to the
    // platform bucket rather than the generic Unknown catch-all.
    final base = _categorizer.categorize(
      errorType: errorType,
      message: msg,
      stack: stackString,
    );
    final category = base == ErrorCategories.unknown
        ? ErrorCategories.platformChannel
        : base;
    return ErrorRecord(
      eventId: '${_collector.sessionId}-nc${++_sequence}',
      fingerprint: _fingerprinter.nativeCrashFingerprint(
        errorType: errorType,
        topFrame: '${frame.file}.${frame.member}',
      ),
      kind: ErrorKind.nativeCrash,
      severity: ErrorSeverity.fatal,
      name: 'native_crash',
      errorType: errorType,
      message: msg,
      category: category,
      origin: frame.toJson(),
      stack: stackString,
      breadcrumbs: breadcrumbs,
      route: '',
      device: await _collector.deviceContext(),
      app: _collector.appContext(),
      network: await _collector.networkContext(),
      context: {..._collector.settingsContext(), 'from_previous_session': true},
      likelyCause: LikelyCauseHints.hintFor(errorType: errorType, message: msg),
      clientAt: crashAt ?? DateTime.now(),
    );
  }

  static String _truncate(String value, int max) =>
      value.length > max ? value.substring(0, max) : value;
}
