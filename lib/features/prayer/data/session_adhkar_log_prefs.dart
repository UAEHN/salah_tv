import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../domain/i_session_adhkar_log_port.dart';

/// SharedPreferences-backed [ISessionAdhkarLogPort]. Stores one record as
/// `dayKey|comma-separated-categories`. A read whose stored day differs
/// from the requested day returns empty, so yesterday's record never blocks
/// today's adhkar. Defaults to "nothing shown" on any error so the user still
/// gets the adhkar rather than silently missing them.
class SessionAdhkarLogPrefs implements ISessionAdhkarLogPort {
  static const _kKey = 'session_adhkar_shown_v1';

  @override
  Future<Set<String>> shownOn(String dayKey) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_kKey);
      if (raw == null) return <String>{};
      final sep = raw.indexOf('|');
      if (sep < 0) return <String>{};
      if (raw.substring(0, sep) != dayKey) return <String>{};
      return raw
          .substring(sep + 1)
          .split(',')
          .where((c) => c.isNotEmpty)
          .toSet();
    } catch (e) {
      debugPrint('[SessionAdhkarLog] read failed: $e');
      return <String>{};
    }
  }

  @override
  Future<void> markShown(String dayKey, String category) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final existing = await shownOn(dayKey); // already day-scoped
      final updated = {...existing, category};
      await prefs.setString(_kKey, '$dayKey|${updated.join(',')}');
    } catch (e) {
      debugPrint('[SessionAdhkarLog] write failed: $e');
    }
  }
}
