/// An Islamic (Hijri) occasion the user might want to anticipate.
class UpcomingOccasion {
  /// Stable identifier used for analytics + asset lookup
  /// (`'ramadan'`, `'arafah'`, …).
  final String id;

  /// Localization key for the visible label (e.g. `'occasionRamadan'`).
  final String labelKey;

  /// Hijri month [1..12] when the occasion falls.
  final int hijriMonth;

  /// Hijri day-of-month [1..30] when the occasion falls.
  final int hijriDay;

  /// Days from "today" (computed at query time). Negative is past.
  final int daysUntil;

  const UpcomingOccasion({
    required this.id,
    required this.labelKey,
    required this.hijriMonth,
    required this.hijriDay,
    required this.daysUntil,
  });

  UpcomingOccasion copyWithDaysUntil(int newDaysUntil) => UpcomingOccasion(
        id: id,
        labelKey: labelKey,
        hijriMonth: hijriMonth,
        hijriDay: hijriDay,
        daysUntil: newDaysUntil,
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UpcomingOccasion &&
          other.id == id &&
          other.hijriMonth == hijriMonth &&
          other.hijriDay == hijriDay &&
          other.daysUntil == daysUntil;

  @override
  int get hashCode =>
      Object.hash(id, hijriMonth, hijriDay, daysUntil);
}
