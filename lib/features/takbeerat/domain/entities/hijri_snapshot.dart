/// Domain-shaped Hijri date — the only Hijri type the use-case layer
/// depends on. Concrete implementations of [IHijriDateProvider] are free to
/// use any package as long as they produce this shape.
class HijriSnapshot {
  const HijriSnapshot({
    required this.year,
    required this.month,
    required this.day,
    required this.lengthOfMonth,
  });

  /// Hijri year (e.g. 1447).
  final int year;

  /// 1..12 — 9 = Ramadan, 10 = Shawwal, 12 = Dhul-Hijjah.
  final int month;

  /// 1..30 — day-of-month.
  final int day;

  /// 29 or 30 — needed to detect "the last day of Ramadan" without guessing,
  /// since Ramadan can be either length.
  final int lengthOfMonth;
}
