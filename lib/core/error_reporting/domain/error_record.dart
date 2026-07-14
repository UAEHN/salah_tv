import 'breadcrumb.dart';
import 'error_severity.dart';

/// Wire values for [ErrorRecord.kind].
class ErrorKind {
  const ErrorKind._();

  static const String exception = 'exception';
  static const String silentFailure = 'silent_failure';
  static const String nativeCrash = 'native_crash';
}

/// Fully-enriched error event, shaped 1:1 like a Firestore `error_events`
/// document (minus `created_at`/`expire_at`, which the uploader appends).
/// [eventId] doubles as the Firestore document id so upload retries are
/// idempotent (the SDK's own offline queue can land a write our timeout
/// already gave up on — same id ⇒ no duplicate documents).
class ErrorRecord {
  const ErrorRecord({
    required this.eventId,
    required this.fingerprint,
    required this.kind,
    required this.severity,
    required this.name,
    required this.errorType,
    required this.message,
    required this.category,
    required this.origin,
    required this.stack,
    required this.breadcrumbs,
    required this.route,
    required this.device,
    required this.app,
    required this.network,
    required this.context,
    required this.clientAt,
    this.flow,
    this.likelyCause,
  });

  final String eventId;
  final String fingerprint;
  final String kind;
  final ErrorSeverity severity;
  final String name;
  final String errorType;
  final String message;
  final String category;
  final Map<String, Object?> origin;
  final String stack;
  final List<Breadcrumb> breadcrumbs;
  final String route;
  final Map<String, Object?>? flow;
  final Map<String, Object?> device;
  final Map<String, Object?> app;
  final Map<String, Object?> network;
  final Map<String, Object?> context;
  final String? likelyCause;
  final DateTime clientAt;

  Map<String, Object?> toJson() {
    return {
      'event_id': eventId,
      'fingerprint': fingerprint,
      'kind': kind,
      'severity': severity.wireName,
      'name': name,
      'error_type': errorType,
      'message': message,
      'category': category,
      'origin': origin,
      'stack': stack,
      'breadcrumbs': [for (final b in breadcrumbs) b.toJson()],
      'route': route,
      'flow': ?flow,
      'device': device,
      'app': app,
      'network': network,
      'context': context,
      'likely_cause': ?likelyCause,
      'client_at': clientAt.toIso8601String(),
    };
  }
}
