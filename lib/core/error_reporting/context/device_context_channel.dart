import 'dart:io';

import 'package:flutter/services.dart';

/// Reads TV device context (model, OS, resolution, RAM, memory pressure,
/// remote input type) from the native `DeviceContextReader` via the existing
/// `ghasaq/platform` channel. Fully fail-soft: on any channel failure the
/// last good snapshot (or a minimal dart:io fallback) is returned, so error
/// reporting never blocks on the platform side.
class DeviceContextChannel {
  static const MethodChannel _channel = MethodChannel('ghasaq/platform');
  static const Duration _timeout = Duration(seconds: 2);

  Map<String, Object?>? _lastGood;

  Future<Map<String, Object?>> read() async {
    try {
      final raw = await _channel
          .invokeMapMethod<String, Object?>('getDeviceContext')
          .timeout(_timeout);
      if (raw == null || raw.isEmpty) return _lastGood ?? _fallback();
      _lastGood = Map<String, Object?>.from(raw);
      return _lastGood ?? _fallback();
    } catch (_) {
      return _lastGood ?? _fallback();
    }
  }

  Map<String, Object?> _fallback() {
    String osVersion = 'unknown';
    try {
      osVersion = Platform.operatingSystemVersion;
    } catch (_) {}
    return {'model': 'unknown', 'os_version': osVersion};
  }
}
