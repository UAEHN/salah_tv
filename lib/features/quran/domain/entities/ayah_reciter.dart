/// One selectable reciter for the mobile Mushaf reader.
///
/// `urlSegment` is the path component that follows `/data/` on everyayah.com
/// (e.g. `Husary_Muallim_128kbps`). The audio port composes the full URL
/// from this segment plus the zero-padded surah/ayah filename.
class AyahReciter {
  final String id;
  final String nameAr;
  final String urlSegment;

  const AyahReciter({
    required this.id,
    required this.nameAr,
    required this.urlSegment,
  });
}
