/// An Islamic (Hijri) occasion the user might want to anticipate.
///
/// Fields fall into two groups:
///   • Identity + timing — `id`, `hijriMonth`, `hijriDay`, `daysUntil`.
///   • Display — either the legacy `labelKey` (resolved via `AppLocalizations`)
///     OR remote-driven strings (`labelAr` / `labelEn` / `iconName` / banner /
///     CTA) supplied by the dynamic catalog. Remote strings win when present.
class UpcomingOccasion {
  /// Stable identifier used for analytics + asset lookup
  /// (`'ramadan'`, `'arafah'`, …).
  final String id;

  /// Legacy localization key (e.g. `'occasionRamadan'`). Resolved via
  /// `today_l10n_resolver.dart`. Used when no remote `labelAr/En` is set.
  final String labelKey;

  /// Hijri month [1..12] when the occasion falls.
  final int hijriMonth;

  /// Hijri day-of-month [1..30] when the occasion falls.
  final int hijriDay;

  /// Days from "today" (computed at query time). Negative is past.
  final int daysUntil;

  /// Optional remote-driven Arabic label. `null` → fall back to `labelKey`.
  final String? labelAr;

  /// Optional remote-driven English label. `null` → fall back to `labelKey`.
  final String? labelEn;

  /// Optional Material icon name (e.g. `'mosque'`, `'calendar_month'`). The
  /// widget resolves the actual `IconData` so unknown names degrade
  /// gracefully to the default icon.
  final String? iconName;

  /// Optional banner image URL shown above the title (long-press sheet).
  final String? bannerUrl;

  /// Optional CTA URL opened on tap from the details sheet.
  final String? ctaUrl;

  const UpcomingOccasion({
    required this.id,
    required this.labelKey,
    required this.hijriMonth,
    required this.hijriDay,
    required this.daysUntil,
    this.labelAr,
    this.labelEn,
    this.iconName,
    this.bannerUrl,
    this.ctaUrl,
  });

  UpcomingOccasion copyWithDaysUntil(int newDaysUntil) => UpcomingOccasion(
        id: id,
        labelKey: labelKey,
        hijriMonth: hijriMonth,
        hijriDay: hijriDay,
        daysUntil: newDaysUntil,
        labelAr: labelAr,
        labelEn: labelEn,
        iconName: iconName,
        bannerUrl: bannerUrl,
        ctaUrl: ctaUrl,
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UpcomingOccasion &&
          other.id == id &&
          other.hijriMonth == hijriMonth &&
          other.hijriDay == hijriDay &&
          other.daysUntil == daysUntil &&
          other.labelAr == labelAr &&
          other.labelEn == labelEn &&
          other.iconName == iconName &&
          other.bannerUrl == bannerUrl &&
          other.ctaUrl == ctaUrl;

  @override
  int get hashCode => Object.hash(
        id,
        hijriMonth,
        hijriDay,
        daysUntil,
        labelAr,
        labelEn,
        iconName,
        bannerUrl,
        ctaUrl,
      );
}
