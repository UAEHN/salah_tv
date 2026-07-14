import 'package:shared_preferences/shared_preferences.dart';

/// Protects Firestore quota from crash-loops and event storms:
/// - per fingerprint per session: [perFingerprintPerSession]
/// - per session total: [perSession]
/// - per calendar day total: [perDay] (persisted — survives restarts, which
///   is exactly the crash-loop case)
///
/// Session counters are in-memory and bounded by [perSession] total, so the
/// fingerprint map can never grow past the session cap (eviction rule §9).
class ErrorRateLimiter {
  ErrorRateLimiter({
    this.perFingerprintPerSession = 20,
    this.perSession = 100,
    this.perDay = 300,
    DateTime Function()? clock,
  }) : _clock = clock ?? DateTime.now;

  final int perFingerprintPerSession;
  final int perSession;
  final int perDay;
  final DateTime Function() _clock;

  static const _dayKey = 'error_reporting.rl.day';
  static const _dayCountKey = 'error_reporting.rl.day_count';

  final Map<String, int> _fingerprintCounts = {};
  int _sessionCount = 0;

  /// True when the event may be reported; increments all counters when
  /// allowed. Fail-open on storage errors (a broken prefs store must not
  /// silence error reporting entirely — the session caps still apply).
  Future<bool> allow(String fingerprint) async {
    final fingerprintCount = _fingerprintCounts[fingerprint] ?? 0;
    if (fingerprintCount >= perFingerprintPerSession) return false;
    if (_sessionCount >= perSession) return false;
    if (!await _allowForDay()) return false;
    _fingerprintCounts[fingerprint] = fingerprintCount + 1;
    _sessionCount++;
    return true;
  }

  Future<bool> _allowForDay() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final today = _todayKey();
      final storedDay = prefs.getString(_dayKey);
      var count = prefs.getInt(_dayCountKey) ?? 0;
      if (storedDay != today) {
        count = 0;
        await prefs.setString(_dayKey, today);
      }
      if (count >= perDay) return false;
      await prefs.setInt(_dayCountKey, count + 1);
      return true;
    } catch (_) {
      return true;
    }
  }

  String _todayKey() {
    final now = _clock();
    final month = now.month.toString().padLeft(2, '0');
    final day = now.day.toString().padLeft(2, '0');
    return '${now.year}-$month-$day';
  }
}
