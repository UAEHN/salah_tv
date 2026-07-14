import 'dart:async';
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../domain/breadcrumb.dart';
import 'breadcrumb_recorder.dart';

/// Persists the breadcrumb ring across sessions so a native crash recovered on
/// the next boot carries the trail that led up to it. Writes a compact JSON
/// snapshot every [_interval] — but only when the trail actually changed, so
/// an idle app never rewrites — and exposes the previous session's trail once
/// on boot.
///
/// Deliberately coarse (30 s, not per-crumb) to respect §9 flash-I/O
/// discipline on a 24/7 device: the trail is a debugging hint, not an audit
/// log, so losing the final few seconds before a crash is acceptable.
class BreadcrumbPersistence {
  BreadcrumbPersistence({Duration interval = const Duration(seconds: 30)})
    : _interval = interval;

  static const String _key = 'error.breadcrumbs.prev';
  final Duration _interval;

  Timer? _timer; // app-lifetime; cancelled in dispose()
  BreadcrumbRecorder? _recorder;
  int _lastLength = -1;
  DateTime? _lastAt;

  /// Reads (without clearing) the trail persisted by the previous session.
  /// This session overwrites it later via [start]; the caller must read here
  /// first and hold the result.
  Future<List<Breadcrumb>> loadPrevious() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_key);
      if (raw == null || raw.isEmpty) return const [];
      final decoded = jsonDecode(raw);
      if (decoded is! List) return const [];
      return [
        for (final entry in decoded)
          if (entry is Map)
            Breadcrumb.fromJson(Map<String, Object?>.from(entry)),
      ];
    } catch (_) {
      return const [];
    }
  }

  /// Begins periodic snapshots of [recorder]'s ring. Call AFTER [loadPrevious]
  /// so the previous trail is read before this session overwrites it.
  void start(BreadcrumbRecorder recorder) {
    _recorder = recorder;
    _timer ??= Timer.periodic(_interval, (_) => _save());
  }

  Future<void> _save() async {
    final recorder = _recorder;
    if (recorder == null) return;
    try {
      final crumbs = recorder.snapshot();
      if (crumbs.isEmpty) return;
      final last = crumbs.last;
      // Skip the write when nothing new arrived (a full ring keeps length 20
      // but its last crumb still advances, so compare the tail timestamp too).
      if (crumbs.length == _lastLength && last.at == _lastAt) return;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
        _key,
        jsonEncode([for (final crumb in crumbs) crumb.toJson()]),
      );
      _lastLength = crumbs.length;
      _lastAt = last.at;
    } catch (_) {}
  }

  Future<void> dispose() async {
    _timer?.cancel();
    _timer = null;
    await _save();
  }
}
