import 'schedule_log_entry.dart';

/// Snapshot of the native engine's runtime health. Built from the JSON the
/// `getHealth` MethodChannel call returns. Pure value object — safe to put
/// inside a BLoC state.
class NotificationHealth {
  final bool postNotifications;
  final bool exactAlarm;
  final bool batteryUnrestricted;
  final OemInfo oem;
  final List<ScheduleLogEntry> scheduleLog;

  const NotificationHealth({
    required this.postNotifications,
    required this.exactAlarm,
    required this.batteryUnrestricted,
    required this.oem,
    required this.scheduleLog,
  });

  bool get allGreen =>
      postNotifications && exactAlarm && batteryUnrestricted && !oem.needsAttention;

  static const empty = NotificationHealth(
    postNotifications: false,
    exactAlarm: false,
    batteryUnrestricted: false,
    oem: OemInfo.unknown,
    scheduleLog: [],
  );

  NotificationHealth copyWith({List<ScheduleLogEntry>? scheduleLog}) =>
      NotificationHealth(
        postNotifications: postNotifications,
        exactAlarm: exactAlarm,
        batteryUnrestricted: batteryUnrestricted,
        oem: oem,
        scheduleLog: List.unmodifiable(scheduleLog ?? this.scheduleLog),
      );
}

class OemInfo {
  final String manufacturer;
  final String brand;
  final String vendor;
  final bool isAggressive;
  final bool autostartAvailable;

  const OemInfo({
    required this.manufacturer,
    required this.brand,
    required this.vendor,
    required this.isAggressive,
    required this.autostartAvailable,
  });

  static const unknown = OemInfo(
    manufacturer: '',
    brand: '',
    vendor: 'generic',
    isAggressive: false,
    autostartAvailable: false,
  );

  bool get needsAttention => isAggressive && autostartAvailable;
}
