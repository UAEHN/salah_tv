import '../domain/error_severity.dart';
import '../domain/i_error_reporting_service.dart';
import 'health_state_store.dart';

/// The fixed daily prayer order the cycle must follow. `sunrise` is excluded —
/// it never fires an adhan (isCountable == false).
const List<String> kPrayerOrder = ['fajr', 'dhuhr', 'asr', 'maghrib', 'isha'];

/// Detects the real bug class this app has had: a countdown ends and the app
/// jumps to the WRONG next prayer (e.g. Asr → Fajr instead of Maghrib).
///
/// Rule: a violation is flagged ONLY when the previous and current fire happen
/// in the SAME session and SAME day with no reset/jump/recovery between (see
/// [reanchor]). After a restart the session id differs, so the first fire just
/// re-anchors — `markMissedPrayers()` legitimately suppresses missed adhans,
/// so isha-after-a-stored-asr on a fresh launch is correct, not a skip.
class SequenceIntegrityChecker {
  SequenceIntegrityChecker({
    required IErrorReportingService reporter,
    required HealthStateStore store,
    required String sessionId,
    required DateTime Function() clock,
  }) : _reporter = reporter,
       _store = store,
       _sessionId = sessionId,
       _clock = clock;

  final IErrorReportingService _reporter;
  final HealthStateStore _store;
  final String _sessionId;
  final DateTime Function() _clock;

  SequenceAnchor? _anchor;

  Future<void> initialize() async {
    _anchor = await _store.loadAnchor();
  }

  /// Called on every adhan FIRED. Compares against the previous same-session
  /// fire; flags a Fatal skip when the successor is wrong, then re-anchors.
  Future<void> onPrayerFired(String prayerKey) async {
    if (!kPrayerOrder.contains(prayerKey)) return;
    final dateKey = _dateKey();
    final anchor = _anchor;
    final isSameRun =
        anchor != null &&
        anchor.sessionId == _sessionId &&
        anchor.dateKey == dateKey;
    if (isSameRun && anchor.prayerKey != prayerKey) {
      final expected = _successorOf(anchor.prayerKey);
      if (prayerKey != expected) {
        _reporter.reportSilentFailure(
          name: 'prayer_sequence_skipped',
          flow: 'sequence',
          prayerKey: prayerKey,
          failedStep: 'sequence_order',
          stepsCompleted: const [],
          waitedMs: 0,
          severity: ErrorSeverity.fatal,
          expected: expected,
          actual: prayerKey,
          message:
              'Prayer sequence skipped: went from ${anchor.prayerKey} to '
              '$prayerKey, expected $expected.',
        );
      }
    }
    await _setAnchor(prayerKey, dateKey);
  }

  /// A reset/time-jump/recovery/day-change happened — drop the anchor so the
  /// next fire re-anchors silently instead of false-flagging.
  Future<void> reanchor() async {
    _anchor = null;
    await _store.clearAnchor();
  }

  Future<void> _setAnchor(String prayerKey, String dateKey) async {
    _anchor = SequenceAnchor(
      prayerKey: prayerKey,
      dateKey: dateKey,
      sessionId: _sessionId,
    );
    await _store.saveAnchor(_anchor!);
  }

  static String _successorOf(String prayerKey) {
    final index = kPrayerOrder.indexOf(prayerKey);
    if (index < 0) return kPrayerOrder.first;
    return kPrayerOrder[(index + 1) % kPrayerOrder.length];
  }

  String _dateKey() {
    final now = _clock();
    final month = now.month.toString().padLeft(2, '0');
    final day = now.day.toString().padLeft(2, '0');
    return '${now.year}-$month-$day';
  }
}
