/// URL builder for the Madinah Mushaf page images served by the
/// official quran_android CDN at files.quran.app (BunnyCDN edge for
/// the quran.app file host).
///
/// quran_android publishes the printed-Mushaf scans at several widths
/// (`width_320` … `width_1920`). Each width is a separate set; a
/// device just picks the closest one to its physical resolution.
///
/// We default to 1024px wide — sharp on every phone, ~30-50 KB per
/// page, ~25 MB for the full Mushaf cache. The CDN sends a
/// `Cache-Control: max-age=25600000` header so aggressive on-disk
/// caching is safe.
class QuranPageImageUrls {
  /// Base CDN path. The old `android.quran.com/data` host 301-redirects
  /// here, so we hit the canonical host directly to skip the redirect
  /// round-trip on every first-fetch.
  static const String _base = 'https://files.quran.app/hafs/madani';

  /// Image width in pixels. Verified working widths on the CDN:
  /// 320, 512, 800, 1024, 1260, 1920.
  static const int defaultWidth = 1024;

  /// Page numbers run 1..604 (Madinah Mushaf). The CDN expects them
  /// zero-padded to three digits.
  static String forPage(int pageNumber, {int width = defaultWidth}) {
    final padded = pageNumber.toString().padLeft(3, '0');
    return '$_base/width_$width/page$padded.png';
  }
}
