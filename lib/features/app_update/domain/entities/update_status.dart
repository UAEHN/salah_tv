import 'remote_version_info.dart';

/// Result of comparing the installed build number against the remote
/// version metadata.
enum UpdateStatus {
  /// Installed build is at or above [RemoteVersionInfo.latestVersionCode].
  upToDate,

  /// Installed build is below `latestVersionCode` but at or above
  /// `minSupportedVersionCode`. Show a dismissible prompt.
  optional,

  /// Installed build is below `minSupportedVersionCode`. Show a blocking
  /// dialog — user must update to continue.
  forced,
}

/// Decision payload returned by `CheckForUpdateUseCase`. Carries the source
/// metadata so the UI can show the store URL / message without re-fetching.
class UpdateDecision {
  const UpdateDecision({required this.status, required this.info});

  final UpdateStatus status;
  final RemoteVersionInfo info;

  bool get isActionable =>
      status == UpdateStatus.optional || status == UpdateStatus.forced;
}
