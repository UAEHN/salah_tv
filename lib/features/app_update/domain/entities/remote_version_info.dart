/// Remote version metadata fetched from Firebase Remote Config.
///
/// All version comparisons are done on the integer build number
/// (Android `versionCode` / pubspec `+N`) — never the human-readable
/// version name, which is unreliable.
class RemoteVersionInfo {
  const RemoteVersionInfo({
    required this.latestVersionCode,
    required this.minSupportedVersionCode,
    required this.storeUrl,
    required this.messageAr,
  });

  /// Highest published build number. Clients below this should see a soft
  /// "update available" prompt.
  final int latestVersionCode;

  /// Lowest still-supported build number. Clients below this MUST update —
  /// a non-dismissible dialog is shown.
  final int minSupportedVersionCode;

  /// Override for the Play Store URL — lets us redirect users to a side-load
  /// page if the listing is taken down.
  final String storeUrl;

  /// Optional Arabic message shown in the update dialog (e.g. "إصلاح مهم").
  final String messageAr;
}
