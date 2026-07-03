import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'diagnostic_event.dart';
import 'diagnostic_level.dart';

class AppDiagnostics {
  AppDiagnostics({
    FirebaseFirestore? firestore,
    FirebaseCrashlytics? crashlytics,
  }) : _firestore = firestore ?? FirebaseFirestore.instance,
       _crashlytics = crashlytics ?? FirebaseCrashlytics.instance;

  static const _prefsKey = 'diagnostics.events.v1';
  static const _maxEvents = 300;

  final FirebaseFirestore _firestore;
  final FirebaseCrashlytics _crashlytics;
  String? _deviceId;
  String? _installationId;
  String? _userId;
  late final String _sessionId = _newSessionId();
  String _platform = 'unknown';
  String _appVersion = 'unknown';

  Future<void> initialize({required String platform}) async {
    _platform = platform;
    try {
      final info = await PackageInfo.fromPlatform();
      _appVersion = '${info.version}+${info.buildNumber}';
      await _crashlytics.setCustomKey('app_version', _appVersion);
      await _crashlytics.setCustomKey('platform_type', platform);
      await _crashlytics.setCustomKey('diagnostic_session_id', _sessionId);
    } catch (_) {}
  }

  Future<void> setDeviceId(String deviceId) async {
    _deviceId = deviceId;
    _installationId = deviceId;
    try {
      await _crashlytics.setCustomKey('device_id', deviceId);
      await _crashlytics.setCustomKey('installation_id', deviceId);
    } catch (_) {}
  }

  Future<void> setUserId(String userId) async {
    _userId = userId;
    try {
      await _crashlytics.setUserIdentifier(userId);
      await _crashlytics.setCustomKey('user_id', userId);
    } catch (_) {}
  }

  Future<void> setContext(Map<String, Object?> values) async {
    for (final entry in values.entries) {
      final value = entry.value;
      if (value == null) continue;
      try {
        await _crashlytics.setCustomKey(entry.key, value);
      } catch (_) {}
    }
  }

  Future<void> record(
    DiagnosticLevel level,
    String name, {
    Map<String, Object?> fields = const {},
    Object? error,
    StackTrace? stack,
    bool forceUpload = false,
  }) async {
    final event = DiagnosticEvent(
      level: level,
      name: name,
      at: DateTime.now(),
      deviceId: _deviceId,
      installationId: _installationId,
      sessionId: _sessionId,
      userId: _userId,
      fields: {
        'platform': _platform,
        'app_version': _appVersion,
        'session_id': _sessionId,
        if (_installationId != null) 'installation_id': _installationId,
        if (_userId != null) 'user_id': _userId,
        ...fields,
        if (error != null) 'error': error.toString(),
      },
    );
    await _appendLocal(event);
    if (error != null &&
        (level == DiagnosticLevel.error || level == DiagnosticLevel.fatal)) {
      unawaited(_recordCrashlytics(level, name, error, stack, event.fields));
    }
    if (forceUpload || level.shouldUpload) {
      unawaited(_upload(event));
    }
  }

  Future<List<Map<String, Object?>>> recent({int limit = 30}) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getStringList(_prefsKey) ?? const [];
      return raw.reversed
          .take(limit)
          .map((e) => jsonDecode(e) as Map<String, Object?>)
          .toList(growable: false);
    } catch (_) {
      return const [];
    }
  }

  Future<void> _appendLocal(DiagnosticEvent event) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getStringList(_prefsKey) ?? <String>[];
      raw.add(jsonEncode(event.toJson()));
      if (raw.length > _maxEvents) {
        raw.removeRange(0, raw.length - _maxEvents);
      }
      await prefs.setStringList(_prefsKey, raw);
    } catch (_) {}
  }

  Future<void> _upload(DiagnosticEvent event) async {
    final id = _deviceId;
    if (id == null) return;
    try {
      final payload = {
        ...event.toJson(),
        'created_at': FieldValue.serverTimestamp(),
      };
      final doc = _firestore.collection('device_diagnostics').doc(id);
      await doc.set({
        'device_id': id,
        'installation_id': _installationId ?? id,
        'session_id': _sessionId,
        if (_userId != null) 'user_id': _userId,
        'platform': _platform,
        'app_version': _appVersion,
        'last_event': event.name,
        'last_level': event.level.wireName,
        'last_seen': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
      await doc.collection('events').add(payload);
    } catch (_) {}
  }

  Future<void> _recordCrashlytics(
    DiagnosticLevel level,
    String name,
    Object error,
    StackTrace? stack,
    Map<String, Object?> fields,
  ) async {
    try {
      await _crashlytics.setCustomKey('diagnostic_event', name);
      await _crashlytics.setCustomKey('diagnostic_level', level.wireName);
      await _crashlytics.recordError(
        error,
        stack,
        reason: name,
        fatal: level == DiagnosticLevel.fatal,
        information: fields.entries.map((e) => '${e.key}=${e.value}'),
      );
    } catch (_) {}
  }

  String _newSessionId() {
    final random = Random.secure();
    final bytes = List<int>.generate(12, (_) => random.nextInt(256));
    return base64UrlEncode(bytes).replaceAll('=', '');
  }
}
