import 'entities/notification_health.dart';

/// Read-only window onto the native engine's runtime state and the actions
/// the user can take to fix any failing check. Implemented in `data/`.
///
/// Methods may throw [NotificationException] from the data layer; the
/// repository implementation catches them and re-raises as Dart `Exception`s
/// so use-cases can convert to `Either<Failure, T>` at the domain edge.
abstract class INotificationHealthPort {
  Future<NotificationHealth> read();

  /// Fires a test notification 15 seconds from now.
  Future<void> runTest();

  /// Opens the OEM-specific Autostart / Protected-apps page when available.
  Future<void> openOemAutostart();

  /// Opens the system pages the user needs for the missing permissions.
  Future<void> openExactAlarmSettings();
  Future<void> openNotificationSettings();
  Future<void> openBatteryOptimizationSettings();

  /// On API 33+, takes the user to the notification settings page so they
  /// can grant POST_NOTIFICATIONS. No-op below that API level.
  Future<void> requestPostNotifications();
}
