import 'dart:convert';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:package_info_plus/package_info_plus.dart';

import 'device_context_channel.dart';
import 'network_state_monitor.dart';
import 'route_tracker.dart';

/// Merges every context source into the shape [ErrorRecordBuilder] embeds on
/// each record: app (version/env/session), device (native channel), network
/// (connectivity), settings (city/modes, pushed by the settings bridge) and
/// the active route. Every getter is fail-soft.
class ErrorContextCollector {
  ErrorContextCollector({
    required RouteTracker routeTracker,
    required DeviceContextChannel deviceChannel,
    required NetworkStateMonitor networkMonitor,
    required this.isTV,
  }) : _routeTracker = routeTracker,
       _deviceChannel = deviceChannel,
       _networkMonitor = networkMonitor;

  final RouteTracker _routeTracker;
  final DeviceContextChannel _deviceChannel;
  final NetworkStateMonitor _networkMonitor;
  final bool isTV;

  /// Stable install id — set by app_startup once IInstallIdProvider resolves.
  String? installId;

  final String sessionId = _newSessionId();
  Map<String, Object?> _settingsContext = const {};
  String _version = 'unknown';
  String _build = 'unknown';

  Future<void> initialize() async {
    try {
      final info = await PackageInfo.fromPlatform();
      _version = info.version;
      _build = info.buildNumber;
    } catch (_) {
      // Version stays 'unknown' — never blocks startup.
    }
  }

  void setSettingsContext(Map<String, Object?> values) {
    _settingsContext = Map.unmodifiable(values);
  }

  Map<String, Object?> appContext() => {
    'version': _version,
    'build': _build,
    'env': kDebugMode ? 'dev' : 'prod',
    'session_id': sessionId,
    'install_id': installId ?? 'unknown',
    'is_tv': isTV,
  };

  Future<Map<String, Object?>> deviceContext() => _deviceChannel.read();

  Future<Map<String, Object?>> networkContext() => _networkMonitor.snapshot();

  Map<String, Object?> settingsContext() => _settingsContext;

  String currentRoute() => _routeTracker.currentRoute;

  static String _newSessionId() {
    final random = Random.secure();
    final bytes = List<int>.generate(12, (_) => random.nextInt(256));
    return base64UrlEncode(bytes).replaceAll('=', '');
  }
}
