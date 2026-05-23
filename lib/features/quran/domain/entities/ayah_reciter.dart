/// One selectable reciter for the mobile Mushaf reader.
///
/// `urlSegment` is the path component that follows `/data/` on everyayah.com
/// (e.g. `Husary_Muallim_128kbps`). The audio port composes the full URL
/// from this segment plus the zero-padded surah/ayah filename.
class AyahReciter {
  final String id;
  final String nameAr;
  final String nameEn;
  final String urlSegment;

  const AyahReciter({
    required this.id,
    required this.nameAr,
    required this.nameEn,
    required this.urlSegment,
  });

  /// Returns the reciter name for the given two-letter language code.
  /// Falls back to Arabic when no other localization is available.
  String localizedName(String languageCode) =>
      languageCode == 'ar' ? nameAr : nameEn;
}
