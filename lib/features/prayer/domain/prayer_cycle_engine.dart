import 'dart:async';

import '../../../core/diagnostics/app_diagnostics.dart';
import '../../../core/diagnostics/diagnostic_level.dart';
import '../../analytics/domain/i_analytics_service.dart';
import '../../settings/domain/entities/prayer_sound_mode.dart';
import 'entities/daily_prayer_times.dart';
import 'i_prayer_audio_port.dart';
import 'i_takbeerat_audio_port.dart';
import '../../notifications/domain/i_prayer_notification_port.dart';
import 'i_prayer_times_repository.dart';
import 'i_session_adhkar_log_port.dart';
import '../../settings/domain/entities/app_settings.dart';
import 'prayer_time_zone.dart';
import 'engine/engine_telemetry_extension.dart';
import 'engine/prayer_cycle_state.dart';
import 'engine/prayer_cycle_base.dart';
import 'engine/prayer_diagnostics_extension.dart';
import 'engine/recovery_mixin.dart';
import 'engine/continuous_mode_mixin.dart';
import 'engine/quran_modes_mixin.dart';
import 'engine/quran_mixin.dart';
import 'engine/takbeerat_mixin.dart';
import 'engine/iqama_mixin.dart';
import 'engine/adhan_cycle_mixin.dart';
import 'engine/tick_mixin.dart';
import 'engine/settings_mixin.dart';

/// Thin coordinator that wires the prayer-cycle mixin components.
/// All logic and Issue 2–11 guards live in the mixins under engine/.
/// This file owns only the 1-second timer lifecycle and the audio-completion
/// subscription (Issue 2).
class PrayerCycleEngine extends PrayerCycleBase
    with
        ContinuousModeMixin,
        QuranModesMixin,
        QuranMixin,
        TakbeeratMixin,
        RecoveryMixin,
        IqamaMixin,
        AdhanCycleMixin,
        TickMixin,
        SettingsMixin {
  @override
  final PrayerCycleState s = PrayerCycleState();

  @override
  final IPrayerAudioPort audio;

  @override
  final ITakbeeratAudioPort takbeeratAudio;

  @override
  final IPrayerTimesRepository repo;

  @override
  AppSettings settings;

  @override
  final IPrayerNotificationPort? notifications;

  @override
  final ISessionAdhkarLogPort? sessionAdhkarLog;

  @override
  final IAnalyticsService? analytics;

  @override
  final AppDiagnostics? diagnostics;

  @override
  final void Function() notify;

  /// Test-only clock override. Null in production → the real device/zone clock.
  /// Lets time-jump / recovery behaviour be driven deterministically in tests.
  final DateTime Function()? clockOverride;

  StreamSubscription<void>? _completionSub;
  StreamSubscription<int>? _quranCompletionSub;
  StreamSubscription<void>? _quranErrorSub;
  StreamSubscription<bool>? _quranLoadingSub;

  PrayerCycleEngine(
    this.repo,
    this.audio,
    this.takbeeratAudio,
    AppSettings initialSettings,
    this.notify, {
    this.notifications,
    this.sessionAdhkarLog,
    this.analytics,
    this.diagnostics,
    this.clockOverride,
  }) : settings = initialSettings {
    // Issue 2: stored subscription; Issue 4: entry guards in each stop method
    // prevent re-entrant / double-fire from onComplete
    _completionSub = audio.onComplete.listen((_) async {
      if (s.isAdhanPlaying) {
        await stopAdhan();
      } else if (s.isDuaPlaying) {
        await stopDua();
      } else if (s.isIqamaPlaying) {
        await stopIqama();
      }
    });
    _quranCompletionSub = audio.onQuranSurahCompleted.listen(onSurahCompleted);
    _quranErrorSub = audio.onQuranError.listen((_) => markQuranError());
    _quranLoadingSub = audio.onQuranLoading.listen(setQuranLoading);
  }

  /// True while the transient Quran network-error banner should be shown.
  bool get hasQuranError => s.quranErrorAt != null;

  /// True while the active Quran is loading/buffering (slow network) and the
  /// user actually has it playing (not paused for adhan or by the user).
  bool get isQuranLoading => s.isQuranLoading && isQuranPlaying;

  /// Most recent [tick]/[loadToday] fault summary (`Type: msg` + first stack
  /// frame), or null if none. Surfaced on screen in test builds for diagnosis.
  String? get lastTickError => s.lastTickError;

  String? get lastPrayerAlertError => s.lastPrayerAlertError;

  // ── Public getters (delegated to PrayerCycleState) ───────────────────────
  DateTime get now => s.now;
  DailyPrayerTimes? get todayPrayers => s.todayPrayers;
  Duration get countdown => s.countdown;
  String get nextPrayerKey => s.nextPrayerKey;
  bool get isAdhanPlaying => s.isAdhanPlaying;
  String get currentAdhanPrayerKey => s.currentAdhanPrayerKey;
  String get activeCyclePrayerKey => s.activeCyclePrayerKey;
  bool get isIqamaCountdown => s.isIqamaCountdown;
  Duration get iqamaCountdown => s.iqamaCountdown;
  String get iqamaPrayerKey => s.iqamaPrayerKey;
  bool get isIqamaPlaying => s.isIqamaPlaying;
  bool get isDuaPlaying => s.isDuaPlaying;

  /// True when the user's Quran is "on" AND actually producing audio.
  bool get isQuranPlaying =>
      s.isQuranPlaying && !s.isQuranPausedForAdhan && !s.isQuranPausedByUser;

  /// True when the user has Quran enabled (playing, paused by adhan, or
  /// manually paused — the user has a queued surah waiting to resume).
  bool get quranUserEnabled => s.isQuranPlaying;

  /// True when the user manually paused Quran. UI uses this to render the
  /// "resume" affordance and keep the saved-position badge.
  bool get isQuranPausedByUser => s.isQuranPausedByUser;

  /// 1..114 — null when no Quran is playing.
  int? get currentSurahNumber => s.currentSurahNumber;

  /// True when the user has Takbeerat "on" and it isn't auto-paused for the cycle.
  bool get isTakbeeratPlaying =>
      s.isTakbeeratPlaying && !s.isTakbeeratPausedForCycle;

  /// True when the user has Takbeerat enabled regardless of cycle pause state.
  bool get takbeeratUserEnabled => s.isTakbeeratPlaying;

  bool get isCycleActive => s.isCycleActive;
  bool get isPrePrayerAlert => s.isPrePrayerAlert;
  bool get isInPostIqamaPrayer => s.isInPostIqamaPrayer;
  bool get isAfterPrayerAdhkarPlaying => s.isAfterPrayerAdhkarPlaying;

  /// True while the morning/evening session adhkar takeover is on screen.
  bool get isSessionAdhkarPlaying => s.isSessionAdhkarPlaying;

  /// Category of the active session takeover ('morning' | 'evening' | '').
  String get sessionAdhkarCategory => s.sessionAdhkarCategory;

  /// True while any post-prayer adhkar takeover is pending OR on screen — the
  /// after-prayer dua and the morning/evening session, including the gap between
  /// them. The idle screensaver stays off for the whole sequence so it never
  /// interrupts the adhkar.
  bool get isAdhkarSequenceActive =>
      s.afterPrayerAdhkarStartsAt != null ||
      s.isAfterPrayerAdhkarPlaying ||
      s.sessionAdhkarStartsAt != null ||
      s.isSessionAdhkarPlaying;

  bool get isMultiCity => repo.isMultiCity;
  List<String> get availableCities => repo.availableCities;

  @override
  DateTime currentTime() =>
      clockOverride?.call() ??
      PrayerTimeZone.now(
        timeZoneId: settings.isCalculatedLocation
            ? settings.selectedTimeZoneId
            : null,
        utcOffsetHours: settings.isCalculatedLocation
            ? settings.utcOffsetHours
            : null,
      );

  // ── Lifecycle ─────────────────────────────────────────────────────────────
  void start() {
    s.now = currentTime(); // sync before recovery check
    repo.setActiveCity(settings.selectedCity);
    loadToday();
    // Restore today's "already shown" log so the catch-up below survives a full
    // restart. Async, but completes well inside the catch-up's 1-min delay.
    unawaited(hydrateSessionAdhkarShown());
    s.timer?.cancel();
    s.timer = Timer.periodic(const Duration(seconds: 1), tick);
    s.needsIqamaRecovery = true;
    if (s.todayPrayers != null) {
      recoverIqamaState(); // catch up if prayer was missed during absence
      recoverSessionAdhkar(); // show morning/evening adhkar missed while closed
      s.needsIqamaRecovery = false;
    }
    notify();
  }

  /// Called by PrayerBloc when the app is sent to the background.
  /// Pauses Quran so it doesn't bleed into the next foreground session.
  void onPaused() {
    s.isAppInForeground = false;
    telAppLifecycle('paused', s.isCycleActive, activeCyclePhase(s));
    if (s.isQuranPlaying &&
        !s.isQuranPausedForAdhan &&
        !s.isQuranPausedByUser) {
      audio.pauseQuranPlayer(); // sets _quranPausedAt timestamp for Issue 7
    }
    // Mirror Quran: a user-enabled Takbeerat track must not keep sounding in the
    // background either. The cycle-pause flag is left untouched so this raw
    // background pause is symmetric with the resume in onResumed.
    if (s.isTakbeeratPlaying && !s.isTakbeeratPausedForCycle) {
      unawaited(takbeeratAudio.pause());
    }
  }

  /// Called by PrayerBloc when the app returns to foreground.
  void onResumed() {
    s.now = currentTime();
    s.isAppInForeground = true;
    telAppLifecycle('resumed', s.isCycleActive, activeCyclePhase(s));
    // Issue 6 + 11: reload if the date changed — catches new day and
    // timezone changes that shift DateTime.now() to a different calendar day.
    if (s.now.day != s.lastLoadedDay) {
      s.adhansToday.clear();
      s.sessionAdhkarShownToday.clear();
      loadToday();
    }
    // Re-hydrate today's "already shown" log (handles a restart that resumed
    // straight into an adhkar window without a fresh start()).
    unawaited(hydrateSessionAdhkarShown());
    // If adhan or dua started while the app was in the background, the audio
    // may have played partially or not at all (Android suspends the isolate).
    // Clear these phases so recoverIqamaState() can recompute the correct
    // state (iqama countdown or idle) based on actual elapsed time.
    final clearedActiveCycle = s.isAdhanPlaying || s.isDuaPlaying;
    final clearedPrayerKey = s.currentAdhanPrayerKey;
    if (clearedActiveCycle) {
      s.adhanFallbackTimer?.cancel();
      s.duaFallbackTimer?.cancel();
      s.isAdhanPlaying = false;
      s.isDuaPlaying = false;
      unawaited(audio.stop());
      // The adhan/dua froze in the background; recoverIqamaState can't rebuild
      // its iqama (the prayer is already in adhansToday) and would DROP it —
      // the iqama vanishes mid-countdown while its time hasn't come. Advance the
      // cycle straight to the iqama countdown from the adhan anchor instead.
      advanceToIqamaAfterInterruptedAdhan();
    } else {
      recoverIqamaState();
    }
    recoverSessionAdhkar(); // show morning/evening adhkar missed while closed
    // Guarantee no silent drop: if resuming tore down a mid-flight adhan/dua but
    // recovery did NOT bring the iqama up (and iqama isn't disabled), the cycle
    // just jumped to the next prayer without its iqama. Flag it FATAL so this
    // "nothing happened, moved on" case never escapes while on screen. Telemetry
    // only — the cycle already advanced; this only surfaces it. onResumed fires
    // solely after a real background episode, so on an always-foreground TV this
    // stays silent unless something genuinely dropped the iqama.
    final iqamaDisabled =
        settings.iqamaMode == PrayerSoundMode.off && !settings.isMosqueMode;
    if (clearedActiveCycle &&
        !iqamaDisabled &&
        !s.isIqamaCountdown &&
        !s.isIqamaPlaying) {
      diag(
        DiagnosticLevel.fatal,
        'iqama_dropped_in_foreground',
        fields: {'dropped_prayer': clearedPrayerKey},
        forceUpload: true,
      );
    }
    if (s.isQuranPlaying &&
        !s.isQuranPausedForAdhan &&
        !s.isQuranPausedByUser) {
      audio.resumeOrRestartQuranPlayer(settings.quranReciterServerUrl);
    }
    // Mirror Quran: resume the background Takbeerat paused by onPaused, unless
    // the cycle owns the pause (it will resume it after iqama).
    if (s.isTakbeeratPlaying && !s.isTakbeeratPausedForCycle) {
      unawaited(takbeeratAudio.resume());
    }
    notify();
  }

  void dispose() {
    _completionSub?.cancel(); // Issue 2: cancel to prevent subscription leak
    _quranCompletionSub?.cancel();
    _quranErrorSub?.cancel();
    _quranLoadingSub?.cancel();
    s.timer?.cancel();
    s.adhanFallbackTimer?.cancel();
    s.duaFallbackTimer?.cancel();
    s.iqamaFallbackTimer?.cancel();
  }
}
