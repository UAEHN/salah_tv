import 'dart:convert';

import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/foundation.dart';

import '../../../../core/app_config.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/takbeerat_config.dart';
import '../../domain/entities/takbeerat_reciter.dart';

/// Reads the Eid Takbeerat keys out of Firebase Remote Config.
///
/// Assumes RC has already been activated by [initializeFirebase]; this only
/// reads the cached values so it never blocks. Throws [ServerException] on
/// any unexpected failure — repository wraps it into a [Failure].
class TakbeeratRemoteConfigDataSource {
  TakbeeratRemoteConfigDataSource({FirebaseRemoteConfig? rc})
      : _rc = rc ?? FirebaseRemoteConfig.instance;

  final FirebaseRemoteConfig _rc;

  TakbeeratConfig read() {
    try {
      return TakbeeratConfig(
        isFeatureEnabled: _rc.getBool(AppConfig.rcKeyTakbeeratEnabled),
        hasForceHide: _rc.getBool(AppConfig.rcKeyTakbeeratForceHide),
        hasForceShow: _rc.getBool(AppConfig.rcKeyTakbeeratForceShow),
        fitrStartOffsetDays: _rc.getInt(AppConfig.rcKeyTakbeeratFitrStartOffset),
        fitrEndOffsetDays: _rc.getInt(AppConfig.rcKeyTakbeeratFitrEndOffset),
        adhaStartOffsetDays: _rc.getInt(AppConfig.rcKeyTakbeeratAdhaStartOffset),
        adhaEndOffsetDays: _rc.getInt(AppConfig.rcKeyTakbeeratAdhaEndOffset),
        reciters: _parseReciters(
          _rc.getString(AppConfig.rcKeyTakbeeratRecitersJson),
        ),
      );
    } catch (e) {
      throw ServerException('Takbeerat RC read failed: $e');
    }
  }

  /// Parses the JSON-encoded reciter catalogue. Malformed entries are
  /// silently skipped so one bad row in the console can't kill the feature.
  List<TakbeeratReciter> _parseReciters(String raw) {
    final trimmed = raw.trim();
    if (trimmed.isEmpty) return const [];
    try {
      final decoded = jsonDecode(trimmed);
      if (decoded is! List) return const [];
      final out = <TakbeeratReciter>[];
      for (final item in decoded) {
        if (item is! Map) continue;
        final id = (item['id'] as Object?)?.toString().trim() ?? '';
        final name = (item['name'] as Object?)?.toString().trim() ?? '';
        final url = (item['url'] as Object?)?.toString().trim() ?? '';
        if (id.isEmpty || name.isEmpty || url.isEmpty) continue;
        out.add(TakbeeratReciter(id: id, name: name, url: url));
      }
      return List.unmodifiable(out);
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[TakbeeratRC] reciter JSON parse failed: $e');
      }
      return const [];
    }
  }
}
