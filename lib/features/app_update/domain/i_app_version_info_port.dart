/// Reads the installed app's build number (Android `versionCode`).
///
/// Defined as a port so the domain layer never depends on
/// `package_info_plus` directly — keeping `domain/` Flutter-free per
/// the architecture rules.
abstract class IAppVersionInfoPort {
  Future<int> currentBuildNumber();
}
