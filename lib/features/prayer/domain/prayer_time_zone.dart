import 'package:timezone/data/latest.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

/// Helpers for representing prayer times in a selected city's wall-clock time.
///
/// For calculated locations we may need to show and compare times using a
/// fixed UTC offset from the chosen city rather than the device timezone.
class PrayerTimeZone {
  const PrayerTimeZone._();

  static bool _initialized = false;

  static DateTime now({
    String? timeZoneId,
    double? utcOffsetHours,
    DateTime? clock,
  }) {
    return resolve(
      clock ?? DateTime.now(),
      timeZoneId: timeZoneId,
      utcOffsetHours: utcOffsetHours,
    );
  }

  static DateTime resolve(
    DateTime deviceNow, {
    String? timeZoneId,
    double? utcOffsetHours,
  }) {
    if (timeZoneId != null && timeZoneId.trim().isNotEmpty) {
      return fromUtc(
        deviceNow.toUtc(),
        timeZoneId: timeZoneId,
        utcOffsetHours: utcOffsetHours,
      );
    }
    if (utcOffsetHours == null) return deviceNow.toLocal();
    return fromUtc(deviceNow.toUtc(), utcOffsetHours: utcOffsetHours);
  }

  static DateTime fromUtc(
    DateTime utc, {
    String? timeZoneId,
    double? utcOffsetHours,
  }) {
    final location = _locationFor(timeZoneId);
    if (location != null) {
      return tz.TZDateTime.from(utc.toUtc(), location);
    }

    final offsetHours = utcOffsetHours;
    if (offsetHours == null) return utc.toLocal();
    final shifted = utc.toUtc().add(
      Duration(minutes: (offsetHours * 60).round()),
    );
    return DateTime(
      shifted.year,
      shifted.month,
      shifted.day,
      shifted.hour,
      shifted.minute,
      shifted.second,
    );
  }

  static tz.Location? _locationFor(String? timeZoneId) {
    final value = timeZoneId?.trim();
    if (value == null || value.isEmpty) return null;
    _ensureInitialized();
    try {
      return tz.getLocation(value);
    } catch (_) {
      return null;
    }
  }

  static void _ensureInitialized() {
    if (_initialized) return;
    tz_data.initializeTimeZones();
    _initialized = true;
  }
}
