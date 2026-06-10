import 'package:firebase_remote_config/firebase_remote_config.dart';

import '../../../../core/app_config.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/remote_version_info.dart';

/// Reads version-gating parameters out of Firebase Remote Config.
///
/// Assumes RC has already been activated at app startup; this datasource
/// only reads the cached values, so it never blocks. Throws
/// [ServerException] on any failure — repository is responsible for
/// wrapping it into a [Failure].
class RemoteConfigDataSource {
  RemoteConfigDataSource({FirebaseRemoteConfig? rc})
    : _rc = rc ?? FirebaseRemoteConfig.instance;

  final FirebaseRemoteConfig _rc;

  RemoteVersionInfo read() {
    try {
      final latest = _rc.getInt(AppConfig.rcKeyLatestCode);
      final minSupported = _rc.getInt(AppConfig.rcKeyMinSupported);
      final storeUrl = _rc.getString(AppConfig.rcKeyStoreUrl);
      final messageAr = _rc.getString(AppConfig.rcKeyMessageAr);

      return RemoteVersionInfo(
        latestVersionCode: latest,
        minSupportedVersionCode: minSupported,
        storeUrl: storeUrl.isEmpty ? AppConfig.playStoreUrl : storeUrl,
        messageAr: messageAr,
      );
    } catch (e) {
      throw ServerException('Remote Config read failed: $e');
    }
  }
}
