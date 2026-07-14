import 'dart:async';

import 'package:flutter/widgets.dart';

import '../bus/telemetry_bus.dart';
import '../bus/telemetry_event.dart';
import '../breadcrumbs/breadcrumb_recorder.dart';
import '../domain/breadcrumb.dart';

/// Tracks the active screen for error context. Two inputs:
/// - [NavigatorObserver] callbacks → named-route changes + `nav` breadcrumbs.
/// - Bus cycle events → a virtual overlay suffix, because on TV the
///   adhan/iqama takeovers are state-driven widget swaps on `/`, not routes;
///   `/#adhan_takeover` is what makes an error's "screen" meaningful there.
class RouteTracker extends NavigatorObserver {
  RouteTracker({BreadcrumbRecorder? recorder}) : _recorder = recorder;

  final BreadcrumbRecorder? _recorder;
  String _currentRoute = '/';
  String? _virtualOverlay;
  StreamSubscription<TelemetryEvent>? _sub; // app-lifetime; dispose() in tests

  static const Map<String, String> _overlayStarts = {
    'adhan_started': 'adhan_takeover',
    'dua_started': 'dua_takeover',
    'iqama_started': 'iqama_takeover',
  };
  static const Set<String> _overlayEnds = {
    'adhan_completed',
    'dua_completed',
    'iqama_completed',
    'cycle_reset',
  };

  String get currentRoute {
    final overlay = _virtualOverlay;
    return overlay == null ? _currentRoute : '$_currentRoute#$overlay';
  }

  void attachTo(TelemetryBus bus) {
    _sub ??= bus.events.listen(_onBusEvent);
  }

  void _onBusEvent(TelemetryEvent event) {
    try {
      final overlay = _overlayStarts[event.name];
      if (overlay != null) {
        _virtualOverlay = overlay;
      } else if (_overlayEnds.contains(event.name)) {
        _virtualOverlay = null;
      }
    } catch (_) {}
  }

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    _record('push', route);
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    _record('pop', previousRoute);
  }

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    _record('replace', newRoute);
  }

  @override
  void didRemove(Route<dynamic> route, Route<dynamic>? previousRoute) {
    _record('remove', previousRoute);
  }

  void _record(String action, Route<dynamic>? nowVisible) {
    try {
      final name = nowVisible?.settings.name;
      if (name != null && name.isNotEmpty) {
        _currentRoute = name;
      }
      _recorder?.add(
        Breadcrumb(
          at: DateTime.now(),
          type: BreadcrumbType.nav,
          name: '$action ${name ?? '(unnamed)'}',
        ),
      );
    } catch (_) {}
  }

  Future<void> dispose() async {
    await _sub?.cancel();
    _sub = null;
  }
}
