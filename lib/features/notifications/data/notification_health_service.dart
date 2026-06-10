import 'dart:convert';

import 'package:flutter/services.dart';

import '../../../core/error/failures.dart';
import '../domain/entities/notification_health.dart';
import '../domain/entities/schedule_log_entry.dart';
import '../domain/i_notification_health_port.dart';
import 'native_notification_engine.dart';

/// Talks to the native engine for diagnostics and remediation actions.
/// Throws [NotificationException] on platform failures so the use-case
/// layer can wrap them in `Either<Failure, T>` per CLAUDE.md §3.
class NotificationHealthService implements INotificationHealthPort {
  static const _notifChannel = MethodChannel('ghasaq/notifications');
  static const _platformChannel = MethodChannel('ghasaq/platform');

  final NativeNotificationEngine _engine;

  NotificationHealthService(this._engine);

  @override
  Future<NotificationHealth> read() async {
    final raw = await _engine.getHealth();
    if (raw == null) return NotificationHealth.empty;
    try {
      final json = jsonDecode(raw) as Map<String, dynamic>;
      return _decodeHealth(json);
    } on FormatException catch (e) {
      throw NotificationException('Malformed health JSON: ${e.message}');
    }
  }

  NotificationHealth _decodeHealth(Map<String, dynamic> json) {
    final oem = json['oem'] as Map<String, dynamic>? ?? const {};
    final logRaw = json['scheduleLog'] as List? ?? const [];
    return NotificationHealth(
      postNotifications: json['postNotifications'] as bool? ?? false,
      exactAlarm: json['exactAlarm'] as bool? ?? false,
      batteryUnrestricted: json['batteryUnrestricted'] as bool? ?? false,
      oem: OemInfo(
        manufacturer: oem['manufacturer'] as String? ?? '',
        brand: oem['brand'] as String? ?? '',
        vendor: oem['vendor'] as String? ?? 'generic',
        isAggressive: oem['isAggressive'] as bool? ?? false,
        autostartAvailable: oem['autostartAvailable'] as bool? ?? false,
      ),
      scheduleLog: List.unmodifiable(
        logRaw.cast<Map>().map(
          (e) => ScheduleLogEntry.fromJson(e.cast<String, dynamic>()),
        ),
      ),
    );
  }

  @override
  Future<void> runTest() async {
    await _engine.runTest();
  }

  @override
  Future<void> openOemAutostart() =>
      _safeInvoke(_notifChannel, 'openOemAutostart');

  @override
  Future<void> openExactAlarmSettings() =>
      _safeInvoke(_notifChannel, 'openExactAlarmSettings');

  @override
  Future<void> openNotificationSettings() =>
      _safeInvoke(_notifChannel, 'openNotificationSettings');

  @override
  Future<void> openBatteryOptimizationSettings() =>
      _safeInvoke(_platformChannel, 'requestIgnoreBatteryOptimization');

  @override
  Future<void> requestPostNotifications() =>
      _safeInvoke(_notifChannel, 'requestPostNotifications');

  Future<void> _safeInvoke(MethodChannel ch, String method) async {
    try {
      await ch.invokeMethod(method);
    } on PlatformException catch (e) {
      throw NotificationException('$method failed: ${e.message}');
    } on MissingPluginException {
      // TV builds: channel never registered. No-op silently — the
      // diagnostic surface is mobile-only and the gate gates this anyway.
    }
  }
}
