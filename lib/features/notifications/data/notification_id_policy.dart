/// Stable id formula shared with the native engine. The id is derived from
/// (type, dayIndex, prayerSlotIndex) so the same prayer keeps the same id
/// across re-syncs — letting AlarmManager dedupe and the store rebuild
/// without orphan registrations.
///
/// Keep in sync with `NotificationType.idBase` in
/// android/app/src/main/kotlin/com/ghasaq/app/notifications/models/NotificationType.kt
class NotificationIdPolicy {
  static const _base = {
    'adhan': 1000,
    'pre_adhan': 2000,
    'iqama': 3000,
    'pre_iqama': 4000,
    'adhkar_morning': 5000,
    'adhkar_evening': 6000,
  };

  static const _prayerSlot = {
    'fajr': 0,
    'dhuhr': 1,
    'asr': 2,
    'maghrib': 3,
    'isha': 4,
  };

  /// Returns the stable id for a per-prayer notification. [dayIndex] = 0
  /// for today, 1 for tomorrow, ... up to 6 for the 7th day.
  static int forPrayer({
    required String type,
    required int dayIndex,
    required String prayerKey,
  }) {
    final base = _base[type] ?? (throw ArgumentError('Unknown type: $type'));
    final slot = _prayerSlot[prayerKey] ??
        (throw ArgumentError('Unknown prayerKey: $prayerKey'));
    return base + dayIndex * 10 + slot;
  }

  /// Returns the stable id for an adhkar notification (no prayerKey).
  static int forAdhkar({required String type, required int dayIndex}) {
    final base = _base[type] ?? (throw ArgumentError('Unknown type: $type'));
    return base + dayIndex;
  }
}
