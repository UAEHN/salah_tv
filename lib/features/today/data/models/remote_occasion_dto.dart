import '../../domain/entities/upcoming_occasion.dart';

/// Wire format for a single occasion in the remote `occasions/manifest.json`.
///
/// Decoding is forward-compatible: unknown fields are ignored, and every
/// known field is read through a null-safe accessor so a malformed entry
/// degrades to "skip this one" rather than throwing.
class RemoteOccasionDto {
  final String id;
  final int hijriMonth;
  final int hijriDay;
  final String? labelAr;
  final String? labelEn;
  final String? iconName;
  final String? bannerUrl;
  final String? ctaUrl;
  final int minVersionCode;
  final int maxVersionCode;

  const RemoteOccasionDto({
    required this.id,
    required this.hijriMonth,
    required this.hijriDay,
    this.labelAr,
    this.labelEn,
    this.iconName,
    this.bannerUrl,
    this.ctaUrl,
    this.minVersionCode = 0,
    this.maxVersionCode = 0,
  });

  /// Returns `null` when the row can't be safely parsed (missing id, invalid
  /// hijri date, type mismatch). Callers should treat `null` as "skip".
  static RemoteOccasionDto? tryFromJson(Object? raw) {
    if (raw is! Map) return null;
    try {
      final id = (raw['id'] as Object?)?.toString().trim() ?? '';
      if (id.isEmpty) return null;

      final month = _asInt(raw['hijri_month']);
      final day = _asInt(raw['hijri_day']);
      if (month == null || day == null) return null;
      if (month < 1 || month > 12) return null;
      if (day < 1 || day > 30) return null;

      return RemoteOccasionDto(
        id: id,
        hijriMonth: month,
        hijriDay: day,
        labelAr: _asNonEmptyString(raw['label_ar']),
        labelEn: _asNonEmptyString(raw['label_en']),
        iconName: _asNonEmptyString(raw['icon']),
        bannerUrl: _asNonEmptyString(raw['banner_url']),
        ctaUrl: _asNonEmptyString(raw['cta_url']),
        minVersionCode: _asInt(raw['min_version_code']) ?? 0,
        maxVersionCode: _asInt(raw['max_version_code']) ?? 0,
      );
    } catch (_) {
      return null;
    }
  }

  /// True when the installed [buildNumber] is inside the configured window.
  /// `0` on either bound means "no limit on that side".
  bool matchesVersion(int buildNumber) {
    if (minVersionCode > 0 && buildNumber < minVersionCode) return false;
    if (maxVersionCode > 0 && buildNumber > maxVersionCode) return false;
    return true;
  }

  UpcomingOccasion toEntity() => UpcomingOccasion(
    id: id,
    labelKey: 'occasion_$id', // unresolved fallback if no remote label
    hijriMonth: hijriMonth,
    hijriDay: hijriDay,
    daysUntil: 0,
    labelAr: labelAr,
    labelEn: labelEn,
    iconName: iconName,
    bannerUrl: bannerUrl,
    ctaUrl: ctaUrl,
  );

  static int? _asInt(Object? v) {
    if (v is int) return v;
    if (v is num) return v.toInt();
    if (v is String) return int.tryParse(v.trim());
    return null;
  }

  static String? _asNonEmptyString(Object? v) {
    if (v is! String) return null;
    final t = v.trim();
    return t.isEmpty ? null : t;
  }
}
