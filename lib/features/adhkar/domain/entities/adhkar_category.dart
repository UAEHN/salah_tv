/// A thematic grouping of adhkar (e.g. morning, evening, after prayer).
class AdhkarCategory {
  final String id;
  final String nameAr;
  final String nameEn;
  final String icon;
  final int totalCount;

  const AdhkarCategory({
    required this.id,
    required this.nameAr,
    this.nameEn = '',
    required this.icon,
    required this.totalCount,
  });

  /// Returns the display name based on the given locale code.
  String displayName(String locale) =>
      locale == 'en' && nameEn.isNotEmpty ? nameEn : nameAr;
}
