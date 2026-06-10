/// Port for analytics event logging.
/// Implementation lives in `data/firebase_analytics_service.dart`.
abstract interface class IAnalyticsService {
  /// One-time setup; sets user properties like platform type.
  Future<void> initialize({required bool isTV});

  /// Attaches the stable install id as a `device_id` user property so the
  /// dashboard can trace a single device's cycle events and correlate them
  /// with its Firestore heartbeat. Called once after install-id resolves.
  Future<void> setDeviceId(String deviceId);

  /// Returns a `NavigatorObserver` for automatic screen tracking.
  /// Typed as `dynamic` to keep the domain layer free of Flutter imports.
  dynamic get navigatorObserver;

  // ── Screen ──────────────────────────────────────────────────────
  void logScreenView(String screenName);

  // ── Prayer cycle (existing) ─────────────────────────────────────
  void logAdhanStarted(String prayerKey);
  void logIqamaStarted(String prayerKey);
  void logQuranStreamToggled({required bool isPlaying});

  // ── Settings ────────────────────────────────────────────────────
  void logSettingsChanged(String settingKey, String value);
  void logCityChanged(String country, String city);

  // ── Feature usage ───────────────────────────────────────────────
  void logTasbihCompleted(String presetName, int target);
  void logFeedbackSubmitted(String feedbackType);
  void logOnboardingCompleted(String country, String city);

  // ── Customization (mobile only) ─────────────────────────────────
  void logThemeChanged(String themeKey);
  void logFontChanged(String fontFamily);

  // ── Prayer cycle health (Phase 1B) ──────────────────────────────
  void logAdhanAudioFailed({
    required String prayerKey,
    required String errorType,
  });
  void logDuaAudioFailed({
    required String prayerKey,
    required String errorType,
  });
  void logIqamaAudioFailed({
    required String prayerKey,
    required String errorType,
  });
  void logAdhanFallbackTriggered({
    required String prayerKey,
    required int afterSeconds,
  });
  void logIqamaFallbackTriggered({
    required String prayerKey,
    required int afterSeconds,
    required bool mosqueMode,
  });
  void logAdhanCompleted({
    required String prayerKey,
    required int durationSeconds,
    required String source,
  });
  void logIqamaCompleted({
    required String prayerKey,
    required int durationSeconds,
    required bool wasNatural,
  });
  void logCycleReset({required String reason});
  void logMissedPrayerDetected({
    required String prayerKey,
    required int deltaMinutes,
  });
  void logIqamaRecovered({
    required String prayerKey,
    required int remainingSeconds,
  });
  void logTimeJumpDetected({required int driftSeconds});

  // ── Data & network (Phase 1B) ───────────────────────────────────
  void logPrayerSourceFallback({required String city, required String reason});
  void logNetworkFailure({
    required String repo,
    required int statusCode,
    required String errorType,
  });
  void logDbOperationSlow({
    required String table,
    required String op,
    required int durationMs,
  });

  // ── Quran playback (Phase 1B) ───────────────────────────────────
  void logQuranPlaybackStarted({
    required int surah,
    required String reciter,
    required String mode,
  });
  void logQuranPlaybackCompleted({
    required int surah,
    required int durationSeconds,
    required bool wasCompleted,
  });

  // ── Phase 1C.1: "Did the adhan even try to fire?" diagnostics ────
  /// Periodic proof-of-life from the 1Hz tick — emitted at most once a
  /// minute. Lets the dashboard detect a stuck/dead tick without polling.
  void logTickHeartbeat({
    required String nextPrayerKey,
    required int countdownSeconds,
    required bool isCycleActive,
    required bool hasPrayerData,
  });

  /// Fired once per prayer when its adjusted time has passed by more than
  /// 60 seconds without the trigger landing in `s.adhansToday`. This is
  /// the single most useful "the adhan didn't play" signal — it confirms
  /// the cycle engine missed its window entirely.
  void logPrayerOverdueNoTrigger({
    required String prayerKey,
    required int overdueSeconds,
    required String adhanMode,
    required bool isMosqueMode,
  });

  /// Fired when [checkAdhanTrigger] hits an exact prayer time but skips
  /// the cycle (adhanMode=off, already fired today, etc.). Helps distinguish
  /// "we saw the time but chose not to play" from "we missed the time".
  void logAdhanSkipped({required String prayerKey, required String reason});

  /// Fired when the adhan started playing but the device output was muted or
  /// at zero volume — the cycle "succeeded" yet nobody could hear it. Closes
  /// the blind spot where `playAdhan` returning true looks like a healthy
  /// adhan in telemetry while the user reports silence.
  void logAdhanInaudible({
    required String prayerKey,
    required int volume,
    required int maxVolume,
    required bool muted,
  });

  /// Fired when `s.todayPrayers == null` persists for more than 30 seconds
  /// — the cycle engine has no schedule to operate on so no adhan can fire.
  /// Diagnoses cache miss / city-load failure / DB corruption.
  void logPrayerDataMissing({
    required int sinceSeconds,
    required String city,
    required String country,
  });

  // ── Phase 1C.2: full cycle phase tracking ────────────────────────
  void logDuaStarted({required String prayerKey, required bool isSilent});
  void logDuaCompleted({
    required String prayerKey,
    required int durationSeconds,
  });
  void logDuaSkipped({required String prayerKey, required String reason});
  void logIqamaCountdownStarted({
    required String prayerKey,
    required int delayMinutes,
    required int remainingSeconds,
  });
  void logIqamaCountdownSkipped({
    required String prayerKey,
    required String reason,
  });
  void logQuranPausedForCycle({required String trigger});
  void logQuranResumedAfterCycle();
  void logAppLifecycle({
    required String state,
    required bool isCycleActive,
    required String activePhase,
  });

  // ── Phase 1C.3: anomalies ────────────────────────────────────────
  void logCycleStuck({
    required String phase,
    required int stuckSeconds,
    required int expectedMaxSeconds,
  });
  void logSettingsChangeDuringCycle({
    required String activePhase,
    required String changedField,
  });
}
