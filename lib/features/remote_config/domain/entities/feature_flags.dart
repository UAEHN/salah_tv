import '../i_remote_config_repository.dart';
import 'remote_config_keys.dart';

/// Ergonomic, typed view over the boolean Remote Config flags.
///
/// Widgets and BLoCs depend on this class instead of reading raw keys from
/// [IRemoteConfigRepository] directly, so the call-sites stay readable
/// (`flags.isQiblaEnabled`) and adding a new flag is a one-line change
/// here plus a key in [RemoteConfigKeys].
///
/// Reads are evaluated lazily on each getter call, so the repo's hourly
/// background refresh is picked up without rebuilding this object.
class FeatureFlags {
  const FeatureFlags(this._rc);

  final IRemoteConfigRepository _rc;

  bool get isQiblaEnabled => _rc.getBool(RemoteConfigKeys.featureQiblaEnabled);
  bool get isAdhkarEnabled =>
      _rc.getBool(RemoteConfigKeys.featureAdhkarEnabled);
  bool get isMushafEnabled =>
      _rc.getBool(RemoteConfigKeys.featureMushafEnabled);
}
