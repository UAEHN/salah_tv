import 'package:flutter/services.dart';

import '../../prayer/domain/entities/daily_prayer_times.dart';
import '../../prayer/domain/i_prayer_times_repository.dart';
import '../../settings/domain/entities/app_settings.dart';
import '../domain/i_prayer_notification_port.dart';
import 'horizon_builder.dart';
import 'notification_serializer.dart';
import 'notification_tap_router.dart';

/// Implements [IPrayerNotificationPort] by delegating to the native Kotlin
/// engine via the `ghasaq/notifications` MethodChannel. The Dart side stays
/// thin: it builds the 7-day horizon, serialises it, and ships it.
///
/// Both `scheduleForDay` and `scheduleAdhkar` collapse into a single sync
/// payload — the native engine treats every notification (adhan, pre-adhan,
/// iqama, pre-iqama, adhkar) the same way. We expose the legacy two-method
/// shape so the prayer cycle engine doesn't need to know the internals.
class NativeNotificationEngine implements IPrayerNotificationPort {
  static const _channel = MethodChannel('ghasaq/notifications');

  final IPrayerTimesRepository _repo;
  final HorizonBuilder _horizon;
  final NotificationSerializer _serializer;
  final DateTime Function() _clock;

  NativeNotificationEngine(
    this._repo, {
    HorizonBuilder? horizon,
    NotificationSerializer? serializer,
    DateTime Function()? clock,
  }) : _horizon = horizon ?? HorizonBuilder(_repo),
       _serializer = serializer ?? NotificationSerializer(),
       _clock = clock ?? DateTime.now;

  @override
  Future<void> initialize() async {
    initializeNotificationTapRouter();
    await _invoke<bool>('initialize');
    await primeColdStartPayload();
  }

  @override
  Future<void> scheduleForDay(
    DailyPrayerTimes today,
    DailyPrayerTimes? tomorrow,
    AppSettings settings,
  ) async {
    final days = _horizon.build(_clock());
    if (days.isEmpty) return;
    final json = _serializer.build(days, settings);
    await _invoke<int>('sync', json);
  }

  @override
  Future<void> scheduleAdhkar(AppSettings settings) async {
    // Adhkar lives inside the same sync payload as prayer notifications,
    // so changing adhkar settings means re-sending the full horizon. The
    // engine compares per-id and updates only what changed.
    final today = _repo.getToday();
    if (today == null) return;
    await scheduleForDay(today, null, settings);
  }

  @override
  Future<void> cancelAll() async {
    await _invoke<void>('cancelAll');
  }

  /// Diagnostic — fires a test notification 15 seconds from now.
  Future<int?> runTest() async => _invoke<int>('runTest');

  /// Debug-only — fires the Friday Al-Kahf reminder 5 seconds from now so
  /// the user can verify the channel, sound, and tap-route end-to-end
  /// without waiting until Friday. Surfaced behind a `kDebugMode` button.
  Future<int?> runAlKahfTest() async => _invoke<int>('runAlKahfTest');

  /// Diagnostic — returns a JSON snapshot of permission state + recent
  /// schedule log. Consumed by the notification health screen.
  Future<String?> getHealth() async => _invoke<String>('getHealth');

  Future<T?> _invoke<T>(String method, [Object? arg]) async {
    try {
      return await _channel.invokeMethod<T>(method, arg);
    } on PlatformException {
      // Native side has its own logging — swallow here so a single broken
      // call doesn't take down the prayer cycle.
      return null;
    } on MissingPluginException {
      // TV builds: channel never registered. No-op silently.
      return null;
    }
  }
}
