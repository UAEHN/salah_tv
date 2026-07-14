import 'package:firebase_analytics/firebase_analytics.dart';

import '../../../core/error_reporting/bus/telemetry_bus.dart';
import '../../../core/error_reporting/bus/telemetry_event.dart';
import '../domain/i_analytics_service.dart';

/// Base for [FirebaseAnalyticsService] — wires Firebase SDK access plus the
/// fire-and-forget [logEventInternal] helper consumed by every events
/// mixin. Telemetry calls never await (§7 CLAUDE.md): a slow analytics
/// network must not delay the 1Hz tick or audio engine.
abstract class FirebaseAnalyticsBase implements IAnalyticsService {
  late final FirebaseAnalytics analytics;
  late final FirebaseAnalyticsObserver _observer;
  final String _sessionId = DateTime.now().microsecondsSinceEpoch.toRadixString(
    36,
  );
  String? _installationId;
  String? _userId;

  /// In-process mirror for breadcrumbs / functional health — injected by
  /// startup after registration; null-safe on every use.
  TelemetryBus? telemetryBus;

  @override
  Future<void> initialize({required bool isTV}) async {
    analytics = FirebaseAnalytics.instance;
    _observer = FirebaseAnalyticsObserver(analytics: analytics);
    await analytics.setUserProperty(
      name: 'platform_type',
      value: isTV ? 'tv' : 'mobile',
    );
  }

  @override
  Future<void> setDeviceId(String deviceId) async {
    // GA4 caps user-property values at 36 chars; the install id is 22, but
    // trim defensively. Failure must never break startup (§8 CLAUDE.md).
    try {
      final value = deviceId.length > 36 ? deviceId.substring(0, 36) : deviceId;
      _installationId = value;
      await analytics.setUserProperty(name: 'device_id', value: value);
      await analytics.setUserProperty(name: 'installation_id', value: value);
    } catch (_) {}
  }

  @override
  Future<void> setUserId(String userId) async {
    try {
      _userId = userId.length > 36 ? userId.substring(0, 36) : userId;
      await analytics.setUserId(id: _userId);
    } catch (_) {}
  }

  @override
  dynamic get navigatorObserver => _observer;

  void logEventInternal(String name, [Map<String, Object>? params]) {
    // §8 CLAUDE.md: telemetry failure must never crash the caller. Firebase
    // SDK already swallows network errors but we belt-and-brace here.
    try {
      final eventParams = <String, Object>{'session_id': _sessionId};
      final installationId = _installationId;
      final userId = _userId;
      if (installationId != null) {
        eventParams['installation_id'] = installationId;
      }
      if (userId != null) {
        eventParams['user_id'] = userId;
      }
      if (params != null) {
        eventParams.addAll(params);
      }
      telemetryBus?.publish(
        source: TelemetrySource.analytics,
        name: name,
        params: eventParams,
      );
      analytics.logEvent(name: name, parameters: eventParams);
    } catch (_) {}
  }
}
