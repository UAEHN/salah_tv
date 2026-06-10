import 'dart:async';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../../features/push_notifications/domain/i_install_id_provider.dart';

/// TV-only heartbeat. Posts a small document to Firestore every 5 minutes
/// so the dashboard can show which devices are online, what city they are
/// tuned to, and the running app version. Failures are silent — a flaky
/// network on a TV box must never crash the cycle (§8 CLAUDE.md).
///
/// Lifetime is owned by `getIt`; the [Timer] is cancelled in [dispose].
class HeartbeatService {
  HeartbeatService(
    this._installIdProvider,
    this._firestore, {
    this.platform = 'tv',
  });

  static const _kCollection = 'device_heartbeats';
  static const _kInterval = Duration(minutes: 5);

  final IInstallIdProvider _installIdProvider;
  final FirebaseFirestore _firestore;

  /// Label written into the heartbeat document so the dashboard can tell
  /// TV from mobile/emulator devices apart.
  final String platform;

  /// Optional callback that returns the latest user-facing snapshot —
  /// current city/country/layout — read from [SettingsProvider] /
  /// [PrayerCycleEngine] at heartbeat time so the value tracks live state.
  Map<String, dynamic> Function()? snapshotProvider;

  Timer? _timer;
  String? _installId;
  String _appVersion = '-';
  String _osVersion = '-';
  DateTime? _startedAt;

  Future<void> start() async {
    if (_timer != null) return;
    await _loadStaticDeviceInfo();
    _startedAt = DateTime.now();
    unawaited(_tick()); // fire immediately so the dashboard sees the device
    _timer = Timer.periodic(_kInterval, (_) => unawaited(_tick()));
  }

  Future<void> _loadStaticDeviceInfo() async {
    try {
      final id = await _installIdProvider.getOrCreate();
      _installId = id.fold((_) => null, (v) => v);
    } catch (_) {}
    try {
      final info = await PackageInfo.fromPlatform();
      _appVersion = '${info.version}+${info.buildNumber}';
    } catch (_) {}
    try {
      _osVersion = Platform.operatingSystemVersion;
    } catch (_) {}
  }

  Future<void> _tick() async {
    final id = _installId;
    if (id == null) return; // install-id load failed earlier — silent skip
    try {
      final payload = <String, dynamic>{
        'device_id': id,
        'last_seen': FieldValue.serverTimestamp(),
        'app_version': _appVersion,
        'os_version': _osVersion,
        'platform': platform,
        if (_startedAt != null)
          'uptime_seconds': DateTime.now().difference(_startedAt!).inSeconds,
        ...?snapshotProvider?.call(),
      };
      await _firestore
          .collection(_kCollection)
          .doc(id)
          .set(payload, SetOptions(merge: true));
    } catch (_) {
      // Silent — never let a heartbeat write break the app.
    }
  }

  void dispose() {
    _timer?.cancel();
    _timer = null;
  }
}
