import 'dart:async';

import 'package:get_it/get_it.dart';

import 'app_diagnostics.dart';
import 'diagnostic_level.dart';

/// Fire-and-forget fault reporter for layers that have no [AppDiagnostics]
/// injected (the prayer-data layer, settings persistence, GPS). Looks the sink
/// up from `getIt` guarded so a caught error becomes a NAMED, uploaded
/// diagnostic instead of a silent `debugPrint` — turning "it broke, no idea
/// why" into "it broke because X on this device". Never throws.
void reportFaultError(
  String name, {
  Map<String, Object?> fields = const {},
  Object? error,
}) => _record(DiagnosticLevel.error, name, fields, error);

/// Same as [reportFaultError] but for non-critical faults (a degraded fallback
/// was used, an update check failed) that are worth seeing but not alarming.
void reportFaultWarning(
  String name, {
  Map<String, Object?> fields = const {},
  Object? error,
}) => _record(DiagnosticLevel.warning, name, fields, error);

void _record(
  DiagnosticLevel level,
  String name,
  Map<String, Object?> fields,
  Object? error,
) {
  try {
    if (!GetIt.I.isRegistered<AppDiagnostics>()) return;
    unawaited(
      GetIt.I<AppDiagnostics>().record(
        level,
        name,
        fields: fields,
        error: error,
        forceUpload: true,
      ),
    );
  } catch (_) {
    // Diagnostics must never throw back into the caller's error path.
  }
}
