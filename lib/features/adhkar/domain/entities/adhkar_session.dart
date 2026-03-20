/// Identifies which adhkar set applies for the current time window.
enum AdhkarSession { morning, evening, none }

/// Derives the session from the prayer cycle's [nextPrayerKey].
/// - Between Fajr and Dhuhr  → morning  (nextPrayerKey == 'dhuhr')
/// - Between Asr and Isha    → evening  (nextPrayerKey == 'maghrib' or 'isha')
/// - Otherwise               → none
AdhkarSession sessionFromNextPrayer(String nextPrayerKey) {
  switch (nextPrayerKey) {
    case 'dhuhr':
      return AdhkarSession.morning;
    case 'maghrib':
    case 'isha':
      return AdhkarSession.evening;
    default:
      return AdhkarSession.none;
  }
}
