import 'package:package_info_plus/package_info_plus.dart';

import '../domain/i_app_version_info_port.dart';

/// Reads the installed app's build number via `package_info_plus`.
/// Caches the [PackageInfo] after the first lookup.
class PackageInfoService implements IAppVersionInfoPort {
  PackageInfo? _cached;

  @override
  Future<int> currentBuildNumber() async {
    final info = _cached ??= await PackageInfo.fromPlatform();
    return int.tryParse(info.buildNumber) ?? 0;
  }
}
