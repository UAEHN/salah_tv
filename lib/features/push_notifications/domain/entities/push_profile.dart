/// Server-side snapshot of one device's push subscription.
/// Persisted in Firestore at `push_profiles/{installId}`. Cloud Functions
/// read it to deliver timezone-aware, language-correct broadcasts.
///
/// [installId] is a per-install UUID generated once and stored on-device —
/// stable across token rotations (so the server document is never orphaned)
/// and reset only on app reinstall.
class PushProfile {
  final String installId;
  final String fcmToken;
  final String language;
  final String country;
  final String? city;
  final String timezone;
  final String platform;
  final String appVersion;

  const PushProfile({
    required this.installId,
    required this.fcmToken,
    required this.language,
    required this.country,
    required this.timezone,
    required this.platform,
    required this.appVersion,
    this.city,
  });
}
