/// Single broadcast announcement pushed via Remote Config.
///
/// `id` is the dedupe key — every user sees a given id at most once. Bumping
/// the id from the Firebase console is how a new announcement reaches users.
///
/// Each user-facing string carries an Arabic and an English version. The
/// dialog picks the one matching the device locale, falling back to the
/// other if the chosen one is empty.
class Announcement {
  const Announcement({
    required this.id,
    required this.titleAr,
    required this.titleEn,
    required this.bodyAr,
    required this.bodyEn,
    required this.ctaUrl,
    required this.ctaLabelAr,
    required this.ctaLabelEn,
    required this.minVersionCode,
    required this.maxVersionCode,
  });

  final String id;
  final String titleAr;
  final String titleEn;
  final String bodyAr;
  final String bodyEn;

  /// Optional. Empty → no CTA button.
  final String ctaUrl;

  /// Optional. Empty → falls back to a default label in the dialog.
  final String ctaLabelAr;
  final String ctaLabelEn;

  /// 0 → no lower bound. Otherwise, hide on builds < [minVersionCode].
  final int minVersionCode;

  /// 0 → no upper bound. Otherwise, hide on builds > [maxVersionCode].
  final int maxVersionCode;

  bool get hasCta => ctaUrl.isNotEmpty;

  /// Picks the title/body/cta-label that matches [localeCode], falling back
  /// to the other language when the preferred one is empty so a single-
  /// language announcement still works.
  String localizedTitle(String localeCode) =>
      _pick(localeCode, titleAr, titleEn);

  String localizedBody(String localeCode) => _pick(localeCode, bodyAr, bodyEn);

  String localizedCtaLabel(String localeCode) =>
      _pick(localeCode, ctaLabelAr, ctaLabelEn);

  static String _pick(String localeCode, String ar, String en) {
    if (localeCode == 'en') {
      return en.isNotEmpty ? en : ar;
    }
    return ar.isNotEmpty ? ar : en;
  }

  bool get isDisplayable =>
      id.isNotEmpty &&
      (titleAr.isNotEmpty ||
          titleEn.isNotEmpty ||
          bodyAr.isNotEmpty ||
          bodyEn.isNotEmpty);

  /// Whether this announcement targets the given installed [buildNumber].
  /// `min`/`max` of 0 act as open bounds, so leaving both 0 = "all users".
  bool matchesVersion(int buildNumber) {
    if (minVersionCode > 0 && buildNumber < minVersionCode) return false;
    if (maxVersionCode > 0 && buildNumber > maxVersionCode) return false;
    return true;
  }
}
