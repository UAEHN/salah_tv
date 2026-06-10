import '../prayer_time_calculator.dart' as calc;
import 'engine_telemetry_extension.dart';
import 'prayer_cycle_base.dart';

/// How long after a prayer's adjusted time before we flag it as overdue.
const Duration _kOverdueThreshold = Duration(seconds: 60);

/// How long [todayPrayers] may stay null before we flag prayer_data_missing.
const Duration _kDataMissingThreshold = Duration(seconds: 30);

/// Throttle for tick_heartbeat and repeat prayer_data_missing reports.
const Duration _kHeartbeatInterval = Duration(minutes: 1);
const Duration _kDataMissingReportInterval = Duration(minutes: 5);

/// Phase 1C.3: any cycle phase still running past this threshold is
/// flagged as stuck. Chosen well above the largest legitimate window so
/// this fires only on a genuinely wedged state.
const Duration _kStuckThreshold = Duration(minutes: 30);
const int _kStuckExpectedMaxSec = 600;

/// Phase 1C diagnostic checks run once per tick. Kept in an extension so
/// the main tick_mixin stays under the §4 150-line cap while still
/// emitting structured cycle-health signals for the dashboard.
extension TickDiagnostics on PrayerCycleBase {
  void runTickDiagnostics() {
    _heartbeat();
    _trackPrayerDataMissing();
    _detectOverdue();
    _detectStuckCycle();
  }

  void _heartbeat() {
    final last = s.lastHeartbeatAt;
    if (last != null && s.now.difference(last) < _kHeartbeatInterval) return;
    s.lastHeartbeatAt = s.now;
    telTickHeartbeat(
      nextPrayerKey: s.nextPrayerKey,
      countdownSeconds: s.countdown.inSeconds,
      isCycleActive: s.isCycleActive,
      hasPrayerData: s.todayPrayers != null,
    );
  }

  void _trackPrayerDataMissing() {
    if (s.todayPrayers == null) {
      s.prayerDataMissingSince ??= s.now;
      final gap = s.now.difference(s.prayerDataMissingSince!);
      if (gap < _kDataMissingThreshold) return;
      final lastReport = s.prayerDataMissingReportedAt;
      if (lastReport != null &&
          s.now.difference(lastReport) < _kDataMissingReportInterval) {
        return;
      }
      s.prayerDataMissingReportedAt = s.now;
      telPrayerDataMissing(
        gap.inSeconds,
        settings.selectedCity,
        settings.selectedCountry,
      );
    } else {
      s.prayerDataMissingSince = null;
      s.prayerDataMissingReportedAt = null;
    }
  }

  void _detectOverdue() {
    if (s.todayPrayers == null) return;
    final prayers = s.todayPrayers!.prayersOnly;
    for (final p in prayers) {
      final key = '${p.key}_${s.now.day}';
      if (s.adhansToday.contains(key)) continue;
      if (s.overdueReported.contains(key)) continue;
      final adjusted = calc.adjustedPrayerTime(p, settings.adhanOffsets);
      final lateBy = s.now.difference(adjusted);
      if (lateBy < _kOverdueThreshold) continue;
      s.overdueReported.add(key);
      telPrayerOverdue(
        p.key,
        lateBy.inSeconds,
        settings.adhanMode.name,
        settings.isMosqueMode,
      );
    }
  }

  void _detectStuckCycle() {
    final anchor = s.isAdhanPlaying
        ? s.adhanTriggerTime
        : (s.isIqamaPlaying ? s.iqamaTriggerTime : null);
    if (anchor == null) return;
    final stuckFor = s.now.difference(anchor);
    if (stuckFor < _kStuckThreshold) return;
    final phase = s.isAdhanPlaying ? 'adhan' : 'iqama';
    final dedupKey = '${phase}_${anchor.millisecondsSinceEpoch}';
    if (s.stuckReported.contains(dedupKey)) return;
    s.stuckReported.add(dedupKey);
    telCycleStuck(phase, stuckFor.inSeconds, _kStuckExpectedMaxSec);
  }
}
