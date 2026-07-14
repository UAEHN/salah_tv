import 'dart:convert';

import 'package:flutter/services.dart';

import '../domain/breadcrumb.dart';
import '../domain/i_error_reporting_service.dart';

/// On boot, drains the JSON marker the native `NativeCrashMarkerHandler` wrote
/// when the PREVIOUS session died with a JVM-level crash that never reached
/// Dart, and files it as a `native_crash` error event carrying that session's
/// breadcrumb trail.
///
/// Fully fail-soft: a missing marker, a non-Android platform (no channel), or
/// malformed JSON are all silent no-ops — crash recovery can never block boot.
class NativeCrashBridge {
  NativeCrashBridge({
    required IErrorReportingService service,
    MethodChannel channel = const MethodChannel('ghasaq/platform'),
  }) : _service = service,
       _channel = channel;

  final IErrorReportingService _service;
  final MethodChannel _channel;

  Future<void> consumeOnBoot(List<Breadcrumb> previousBreadcrumbs) async {
    try {
      final raw = await _channel.invokeMethod<String>(
        'consumeNativeCrashMarker',
      );
      if (raw == null || raw.isEmpty) return;
      final decoded = jsonDecode(raw);
      if (decoded is! Map) return;
      _service.reportNativeCrash(
        errorType: _str(decoded['error_type'], 'NativeCrash'),
        message: _str(decoded['message'], ''),
        stack: _str(decoded['stack'], ''),
        breadcrumbs: previousBreadcrumbs,
        crashAt: _epoch(decoded['at']),
      );
    } catch (_) {
      // A fault inside crash recovery must never block boot.
    }
  }

  static String _str(Object? value, String fallback) =>
      value is String && value.isNotEmpty ? value : fallback;

  static DateTime? _epoch(Object? value) {
    if (value is int) return DateTime.fromMillisecondsSinceEpoch(value);
    if (value is String) {
      final ms = int.tryParse(value);
      if (ms != null) return DateTime.fromMillisecondsSinceEpoch(ms);
    }
    return null;
  }
}
