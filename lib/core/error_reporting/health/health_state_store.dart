import 'package:shared_preferences/shared_preferences.dart';

/// The persisted sequence anchor: which prayer last fired, on which day, in
/// which session. Survives restarts so the sequence checker can tell a fresh
/// launch (session changed) from a genuine in-session skip.
class SequenceAnchor {
  const SequenceAnchor({
    required this.prayerKey,
    required this.dateKey,
    required this.sessionId,
  });

  final String prayerKey;
  final String dateKey;
  final String sessionId;
}

/// SharedPreferences-backed persistence for the functional-health layer.
/// Fully fail-soft — a broken store degrades to "no anchor" (re-anchor
/// silently), never an exception.
class HealthStateStore {
  static const _keyPrayer = 'health.seq.prayer';
  static const _keyDate = 'health.seq.date';
  static const _keySession = 'health.seq.session';

  Future<SequenceAnchor?> loadAnchor() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final prayer = prefs.getString(_keyPrayer);
      final date = prefs.getString(_keyDate);
      final session = prefs.getString(_keySession);
      if (prayer == null || date == null || session == null) return null;
      return SequenceAnchor(
        prayerKey: prayer,
        dateKey: date,
        sessionId: session,
      );
    } catch (_) {
      return null;
    }
  }

  Future<void> saveAnchor(SequenceAnchor anchor) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_keyPrayer, anchor.prayerKey);
      await prefs.setString(_keyDate, anchor.dateKey);
      await prefs.setString(_keySession, anchor.sessionId);
    } catch (_) {}
  }

  Future<void> clearAnchor() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_keyPrayer);
      await prefs.remove(_keyDate);
      await prefs.remove(_keySession);
    } catch (_) {}
  }
}
