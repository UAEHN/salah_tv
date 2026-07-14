import 'dart:async';
import 'dart:collection';

import '../bus/telemetry_bus.dart';
import '../bus/telemetry_event.dart';
import '../domain/breadcrumb.dart';

/// Rolling trail of the last [_capacity] user/system actions. Fed directly
/// by the key/focus/route/API breadcrumbers and indirectly by the
/// [TelemetryBus] (prayer-cycle + diagnostic events). Bounded ring —
/// eviction rule: oldest dropped beyond capacity (§9 CLAUDE.md).
class BreadcrumbRecorder {
  BreadcrumbRecorder({int capacity = 20}) : _capacity = capacity;

  final int _capacity;
  final ListQueue<Breadcrumb> _ring = ListQueue<Breadcrumb>();
  StreamSubscription<TelemetryEvent>? _sub; // app-lifetime; dispose() in tests

  /// Events too chatty to be useful in a 20-slot trail.
  static const Set<String> _noiseEvents = {'tick_heartbeat', 'screen_view'};

  /// Bus params that repeat on every event and carry no trail value.
  static const Set<String> _droppedParams = {
    'session_id',
    'installation_id',
    'user_id',
    'platform',
    'app_version',
  };

  static const List<String> _cyclePrefixes = [
    'adhan',
    'iqama',
    'dua_',
    'quran',
    'prayer',
    'cycle',
    'tick_',
    'takbeerat',
    'missed_prayer',
    'time_jump',
  ];

  void attachTo(TelemetryBus bus) {
    _sub ??= bus.events.listen(_onBusEvent);
  }

  void _onBusEvent(TelemetryEvent event) {
    try {
      if (event.source == TelemetrySource.errorReporting) return;
      if (_noiseEvents.contains(event.name)) return;
      add(
        Breadcrumb(
          at: event.at,
          type: _typeFor(event.name),
          name: event.name,
          data: _slim(event.params),
        ),
      );
    } catch (_) {
      // A breadcrumb failure must never propagate into the publisher.
    }
  }

  /// Appends a crumb. Consecutive crumbs with the same type+name collapse
  /// into one entry with a `repeat` counter (D-pad bursts, retry loops)
  /// so a burst can never wipe the rest of the trail.
  void add(Breadcrumb crumb) {
    try {
      if (_ring.isNotEmpty) {
        final last = _ring.last;
        if (last.type == crumb.type && last.name == crumb.name) {
          final repeats = ((last.data?['repeat'] as int?) ?? 1) + 1;
          _ring.removeLast();
          _ring.add(
            Breadcrumb(
              at: crumb.at,
              type: crumb.type,
              name: crumb.name,
              data: {...?crumb.data, 'repeat': repeats},
            ),
          );
          return;
        }
      }
      _ring.add(crumb);
      while (_ring.length > _capacity) {
        _ring.removeFirst();
      }
    } catch (_) {}
  }

  List<Breadcrumb> snapshot() => List.unmodifiable(_ring);

  static String _typeFor(String name) {
    if (name == 'app_lifecycle') return BreadcrumbType.lifecycle;
    for (final prefix in _cyclePrefixes) {
      if (name.startsWith(prefix)) return BreadcrumbType.cycle;
    }
    return BreadcrumbType.diag;
  }

  /// Keeps at most 6 short stringified params per crumb — the trail is a
  /// hint, not a payload (Firestore doc budget).
  static Map<String, Object?>? _slim(Map<String, Object?> params) {
    if (params.isEmpty) return null;
    final slim = <String, Object?>{};
    for (final entry in params.entries) {
      if (_droppedParams.contains(entry.key)) continue;
      final value = entry.value?.toString() ?? 'null';
      slim[entry.key] = value.length > 60 ? value.substring(0, 60) : value;
      if (slim.length >= 6) break;
    }
    return slim.isEmpty ? null : slim;
  }

  Future<void> dispose() async {
    await _sub?.cancel();
    _sub = null;
  }
}
