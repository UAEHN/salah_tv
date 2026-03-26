/// A thematic grouping of adhkar (e.g. morning, evening, after prayer).
class AdhkarCategory {
  final String id;
  final String nameAr;
  final String icon;
  final int totalCount;

  const AdhkarCategory({
    required this.id,
    required this.nameAr,
    required this.icon,
    required this.totalCount,
  });
}
