import 'dart:async';
import 'dart:convert';

import 'package:dartz/dartz.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';

import '../../../core/app_config.dart';
import '../../../core/error/failures.dart';
import '../domain/entities/remote_config_keys.dart';
import '../domain/i_remote_config_repository.dart';

/// Firebase-backed implementation of [IRemoteConfigRepository].
///
/// Reads are synchronous and hit the in-memory snapshot Firebase activated
/// at boot. A periodic [_refreshInterval] timer triggers background
/// fetch+activate calls so 24/7 TV installs pick up console changes
/// without an app restart. Failures during background refresh are
/// swallowed — the snapshot from the previous successful fetch (or the
/// defaults) stays in use.
class FirebaseRemoteConfigRepository implements IRemoteConfigRepository {
  FirebaseRemoteConfigRepository({
    FirebaseRemoteConfig? rc,
    Duration refreshInterval = const Duration(hours: 1),
  }) : _rc = rc ?? FirebaseRemoteConfig.instance,
       _refreshInterval = refreshInterval;

  final FirebaseRemoteConfig _rc;
  final Duration _refreshInterval;
  // Broadcast: many widgets may listen, none of them should miss values.
  final StreamController<void> _changes = StreamController<void>.broadcast();
  // Disposed in [dispose] — kept alive for the app lifetime in production.
  Timer? _refreshTimer;
  bool _initialised = false;

  /// Registers Phase-1 defaults on top of the boot defaults and starts the
  /// background refresh timer. Safe to call multiple times — subsequent
  /// calls are no-ops.
  Future<void> initialize() async {
    if (_initialised) return;
    _initialised = true;
    if (RemoteConfigKeys.defaults.isNotEmpty) {
      // `setDefaults` is additive on the platform side — boot-time defaults
      // registered by `_primeRemoteConfig` remain untouched.
      try {
        await _rc.setDefaults(RemoteConfigKeys.defaults);
      } catch (_) {
        // Defaults are best-effort; keys without defaults still resolve via
        // their typed fallback (0/false/'') from the Firebase SDK.
      }
    }
    _refreshTimer = Timer.periodic(_refreshInterval, (_) => _backgroundFetch());
  }

  Future<void> _backgroundFetch() async {
    try {
      final activated = await _rc.fetchAndActivate().timeout(
        AppConfig.rcFetchTimeout,
      );
      if (activated && !_changes.isClosed) {
        _changes.add(null);
      }
    } catch (_) {
      // Fail-soft: a flaky TV-box network must never crash the timer loop.
    }
  }

  @override
  String getString(String key) => _rc.getString(key);

  @override
  int getInt(String key) => _rc.getInt(key);

  @override
  double getDouble(String key) => _rc.getDouble(key);

  @override
  bool getBool(String key) => _rc.getBool(key);

  @override
  Map<String, dynamic> getJsonMap(String key) {
    final raw = _rc.getString(key);
    if (raw.isEmpty) return const <String, dynamic>{};
    try {
      final decoded = jsonDecode(raw);
      if (decoded is Map<String, dynamic>) return decoded;
    } catch (_) {
      // Malformed JSON in console — treat as empty rather than crash UI.
    }
    return const <String, dynamic>{};
  }

  @override
  List<dynamic> getJsonList(String key) {
    final raw = _rc.getString(key);
    if (raw.isEmpty) return const <dynamic>[];
    try {
      final decoded = jsonDecode(raw);
      if (decoded is List) return decoded;
    } catch (_) {
      // Malformed JSON in console — treat as empty rather than crash UI.
    }
    return const <dynamic>[];
  }

  @override
  Stream<void> get changes => _changes.stream;

  @override
  Future<Either<Failure, bool>> refresh() async {
    try {
      final activated = await _rc.fetchAndActivate().timeout(
        AppConfig.rcFetchTimeout,
      );
      if (activated && !_changes.isClosed) {
        _changes.add(null);
      }
      return Right(activated);
    } catch (e) {
      return Left(ServerFailure('Remote Config refresh failed: $e'));
    }
  }

  /// Tear-down hook — getIt singletons live for the app lifetime so this is
  /// usually unused, but kept available for tests and future scenarios
  /// where the repo is rebuilt (e.g. user switches Firebase project).
  Future<void> dispose() async {
    _refreshTimer?.cancel();
    _refreshTimer = null;
    await _changes.close();
  }
}
