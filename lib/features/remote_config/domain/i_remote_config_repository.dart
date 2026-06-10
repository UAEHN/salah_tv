import 'package:dartz/dartz.dart';

import '../../../core/error/failures.dart';

/// Unified read access to Firebase Remote Config values plus a reactive
/// change stream and a manual refresh hook.
///
/// Reads are cheap and synchronous — they hit the in-memory snapshot that
/// Firebase activated at boot (see `_primeRemoteConfig` in
/// `startup_firebase.dart`) or during a later background refresh.
///
/// Consumers should depend on this interface (not the Firebase SDK directly)
/// so the values become swappable in tests and so new feature flags can be
/// added by editing a single key registry instead of wiring a new
/// datasource per feature.
abstract class IRemoteConfigRepository {
  /// Returns the configured string for [key], or the fallback registered in
  /// [RemoteConfigKeys] when the value is missing or empty.
  String getString(String key);

  /// Returns the configured int for [key], or its registered fallback.
  int getInt(String key);

  /// Returns the configured double for [key], or its registered fallback.
  double getDouble(String key);

  /// Returns the configured bool for [key], or its registered fallback.
  bool getBool(String key);

  /// Parses [key] as a JSON object. Returns an empty map when the raw value
  /// is empty or not a JSON object — never throws.
  Map<String, dynamic> getJsonMap(String key);

  /// Parses [key] as a JSON array. Returns an empty list when the raw value
  /// is empty or not a JSON array — never throws.
  List<dynamic> getJsonList(String key);

  /// Emits whenever a fetch+activate brings new values into the in-memory
  /// snapshot. UI layers can `select` on a key and rebuild reactively.
  Stream<void> get changes;

  /// Force an immediate fetch+activate. Returns `true` when new values were
  /// activated, `false` when the cached snapshot was already fresh. Honours
  /// Firebase's `minimumFetchInterval` throttling.
  Future<Either<Failure, bool>> refresh();
}
