import 'package:firebase_analytics/firebase_analytics.dart';

import '../domain/i_analytics_service.dart';

/// Base for [FirebaseAnalyticsService] — wires Firebase SDK access plus the
/// fire-and-forget [logEventInternal] helper consumed by every events
/// mixin. Telemetry calls never await (§7 CLAUDE.md): a slow analytics
/// network must not delay the 1Hz tick or audio engine.
abstract class FirebaseAnalyticsBase implements IAnalyticsService {
  late final FirebaseAnalytics analytics;
  late final FirebaseAnalyticsObserver _observer;

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
      await analytics.setUserProperty(name: 'device_id', value: value);
    } catch (_) {}
  }

  @override
  dynamic get navigatorObserver => _observer;

  void logEventInternal(String name, [Map<String, Object>? params]) {
    // §8 CLAUDE.md: telemetry failure must never crash the caller. Firebase
    // SDK already swallows network errors but we belt-and-brace here.
    try {
      analytics.logEvent(name: name, parameters: params);
    } catch (_) {}
  }
}
