import '../../../../core/diagnostics/diagnostic_level.dart';
import '../prayer_time_calculator.dart' as calc;
import 'engine_telemetry_extension.dart';
import 'prayer_cycle_base.dart';
import 'prayer_diagnostics_extension.dart';

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
    if (last != null) {
      final elapsed = s.now.difference(last);
      // Skip only a normal forward tick still inside the throttle window.
      // A BACKWARD clock jump (elapsed < 0 — user or NTP set the clock back)
      // must NOT wedge the heartbeat: leaving it throttled starves the
      // countdown-stall detector and fires a false countdown_stall (~150s later)
      // even though the app is running fine. So on any non-forward or
      // out-of-window gap we fall through and emit + re-anchor immediately.
      if (elapsed >= Duration.zero && elapsed < _kHeartbeatInterval) return;
    }
    s.lastHeartbeatAt = s.now;
    telTickHeartbeat(
      nextPrayerKey: s.nextPrayerKey,
      countdownSeconds: s.countdown.inSeconds,
      isCycleActive: s.isCycleActive,
      hasPrayerData: s.todayPrayers != null,
      // Freeze-cause context — carried into the countdown_stall report so a stall
      // on a weak box says WHAT the tick was loaded with (background audio /
      // active phase), not just that it froze.
      quranPlaying: s.isQuranPlaying,
      takbeeratPlaying: s.isTakbeeratPlaying,
      cyclePhase: activeCyclePhase(s),
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
      final cause = _overdueCause(lateBy);
      telPrayerOverdue(
        p.key,
        lateBy.inSeconds,
        settings.adhanMode.name,
        settings.isMosqueMode,
        cause,
      );
      // Fast per-device trail: BigQuery is ~24h behind, so also drop a
      // forced-upload diagnostic naming the EXACT blocking cause. Turns
      // "an adhan didn't fire somewhere" into "this device missed <prayer>
      // because <cause>", actionable without waiting for the export.
      // Split the signal by app visibility. An overdue while the app is ON
      // SCREEN is the worst case — the user was watching, prayer time came, and
      // nothing fired (no suspended-device excuse) — so it gets its own FATAL
      // group that alerts loudly, apart from background misses that are often a
      // dozing box waking late.
      final isForeground = s.isAppInForeground;
      diag(
        isForeground ? DiagnosticLevel.fatal : DiagnosticLevel.error,
        isForeground ? 'adhan_missed_in_foreground' : 'adhan_fire_missed',
        fields: {
          'missed_prayer': p.key,
          'overdue_sec': lateBy.inSeconds,
          'cause': cause,
          'holder_prayer': s.activeCyclePrayerKey,
          'is_foreground': isForeground,
        },
        forceUpload: true,
      );
      // Mirror into the unified "adhan didn't sound today" signal so this
      // ticking-foreground miss shows up in the same one-filter list as the
      // recovery-skip and silent-rescue cases (see diagAdhanNotSounded).
      diagAdhanNotSounded(
        prayerKey: p.key,
        cause: 'never_fired_$cause',
        iqamaWillFire: false,
        lateSeconds: lateBy.inSeconds,
        critical: isForeground,
      );
    }
  }

  /// Pinpoints WHY a prayer went overdue without its adhan firing, evaluating
  /// the live guards at report time so the trail says where it broke:
  ///  - `cycle_active_<phase>` a previous cycle is still holding the machine
  ///    (the wedge that silently blocks every following prayer's adhan);
  ///  - `tick_fault` the 1 Hz tick threw before reaching the trigger;
  ///  - `window_overshot` the tick stalled clean past the 5-min rescue window;
  ///  - `unknown` none of the above — a genuine logic gap worth investigating.
  String _overdueCause(Duration lateBy) {
    if (s.isCycleActive) return 'cycle_active_${activeCyclePhase(s)}';
    if (s.lastTickError != null) return 'tick_fault';
    if (lateBy.inSeconds > calc.kAdhanRescueCatchUpSeconds) {
      return 'window_overshot';
    }
    return 'unknown';
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
