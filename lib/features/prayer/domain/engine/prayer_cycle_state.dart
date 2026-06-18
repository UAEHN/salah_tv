import 'dart:async';

import '../entities/daily_prayer_times.dart';

/// Mutable state bag for [PrayerCycleEngine].
/// All engine state fields live here, accessible to every mixin via [s].
class PrayerCycleState {
  // ── Tick timer ──────────────────────────────────────────────────────────
  Timer? timer;

  // ── Current time & prayer data ──────────────────────────────────────────
  DateTime now = DateTime.now();
  DailyPrayerTimes? todayPrayers;
  Duration countdown = Duration.zero;
  String nextPrayerKey = '';
  final Set<String> adhansToday = {};
  int lastLoadedDay = -1; // Issue 6: date-change detection
  bool needsIqamaRecovery = false;

  // ── Adhan state ──────────────────────────────────────────────────────────
  bool isAdhanPlaying = false;
  String currentAdhanPrayerKey = '';
  String activeCyclePrayerKey =
      ''; // set when adhan fires, cleared after iqama ends
  int currentIqamaDelayMin = 0; // Issue 9: snapshot at adhan fire time
  DateTime?
  adhanTriggerTime; // exact moment adhan fired — anchors iqama countdown
  Timer? adhanFallbackTimer;

  // ── Dua state ────────────────────────────────────────────────────────────
  bool isDuaPlaying = false;
  Timer? duaFallbackTimer;

  /// Phase 1C.2: anchors dua_completed.duration_seconds. Set when dua
  /// playback begins, consumed and cleared by stopDua.
  DateTime? duaTriggerTime;

  // ── Iqama countdown & playback ───────────────────────────────────────────
  bool isIqamaCountdown = false;
  Duration iqamaCountdown = Duration.zero;
  String iqamaPrayerKey = '';
  bool isIqamaPlaying = false;
  Timer? iqamaFallbackTimer;

  // Telemetry-only fields (Phase 1B). [iqamaTriggerTime] anchors the
  // iqama_completed.duration_seconds metric. [iqamaWasNaturalCompletion]
  // distinguishes audio-onComplete (true) from fallback-timer / play-failure
  // (false). Reset by stopIqama after emitting the event.
  DateTime? iqamaTriggerTime;
  bool iqamaWasNaturalCompletion = true;

  // ── Mosque-mode post-iqama prayer window ─────────────────────────────────
  // Set when iqama ends in mosque mode; while [now] is before this timestamp
  // the home screen shows the silence-phone takeover. Cleared by tick when
  // expired.
  DateTime? prayerInProgressEndsAt;

  // ── After-prayer adhkar takeover ─────────────────────────────────────────
  // Scheduled at iqama end when [isAdhkarEnabled]: the home screen shows a
  // rotating «أذكار بعد الصلاة» takeover from [afterPrayerAdhkarStartsAt] until
  // [afterPrayerAdhkarEndsAt], then Quran resumes. Transient (in-memory) like
  // the window above, and cleared together on cycle reset.
  DateTime? afterPrayerAdhkarStartsAt;
  DateTime? afterPrayerAdhkarEndsAt;
  bool isAfterPrayerAdhkarPlaying = false;

  // ── Morning/evening session adhkar takeover ──────────────────────────────
  // Scheduled ~20 min after the prayer (iqama end + a fixed delay), only after
  // Fajr (→ morning) or Asr (→ evening). INDEPENDENT of the «دعاء بعد الصلاة»
  // takeover, so disabling that never affects it. Shown in mosque mode too, but
  // the screen mutes its audio there. The home screen shows a full-screen adhkar
  // takeover from [sessionAdhkarStartsAt] for one display window
  // ([sessionAdhkarEndsAt]), then Quran resumes. Transient (in-memory) like the
  // after-prayer fields above; cleared together on cycle reset.
  DateTime? sessionAdhkarStartsAt;
  DateTime? sessionAdhkarEndsAt;
  bool isSessionAdhkarPlaying = false;
  String sessionAdhkarCategory = ''; // 'morning' | 'evening' | ''

  // ── Quran background audio ───────────────────────────────────────────────
  /// Whether the user has Quran "on" (wants it to play).
  bool isQuranPlaying = false;

  /// Internally paused because adhan/dua/iqama is active. Will auto-resume.
  bool isQuranPausedForAdhan = false;

  /// Manually paused by the user. Preserves [currentSurahNumber],
  /// [playlistCursor], [playlistCyclesCompleted] and [surahPlayCount] so the
  /// next toggle resumes from the same surah/position instead of restarting.
  bool isQuranPausedByUser = false;

  /// Currently audible surah (1..114), null when no Quran is playing.
  /// Mirrored from [IPrayerAudioPort.currentQuranSurah]; updated on surah
  /// completions and explicit play actions.
  int? currentSurahNumber;

  /// Cursor into [playlistOrder] when in playlist mode (0-based).
  int playlistCursor = 0;

  /// Materialized playback order — copy of settings.surahPlaylist (Mushaf
  /// order) or a shuffled permutation when [settings.playlistShuffle] is on.
  List<int> playlistOrder = const [];

  /// How many full cycles of the playlist have completed since playback started.
  int playlistCyclesCompleted = 0;

  /// How many times the selected surah has played (single-surah mode).
  int surahPlayCount = 0;

  // ── Eid Takbeerat background audio ───────────────────────────────────────
  /// User has Takbeerat "on". Mirrors [isQuranPlaying]'s intent flag.
  bool isTakbeeratPlaying = false;

  /// Auto-paused because adhan/dua/iqama is active. Auto-resumes after iqama.
  bool isTakbeeratPausedForCycle = false;

  /// Source URL of the currently-loaded track. Empty when nothing is loaded.
  String takbeeratUrl = '';

  // ── Pre-alert dedup sets ─────────────────────────────────────────────────
  final Set<String> preAlertBellPlayed = {};
  final Set<String> preAnnouncementPlayed = {};

  // ── Phase 1C.1 diagnostic state ──────────────────────────────────────────
  /// Dedup set so prayer_overdue_no_trigger fires at most once per prayer.
  /// Cleared together with [adhansToday] on day change / city change.
  final Set<String> overdueReported = {};

  /// Dedup set so adhan_skipped fires at most once per (prayer, reason).
  /// Cleared together with [adhansToday] on day change / city change.
  final Set<String> skippedReported = {};

  /// Last time tick_heartbeat was emitted. Throttles the event to ~1/min.
  DateTime? lastHeartbeatAt;

  /// First tick at which [todayPrayers] was observed null in the current
  /// gap. Null while data is present. Drives prayer_data_missing reporting.
  DateTime? prayerDataMissingSince;
  DateTime? prayerDataMissingReportedAt;

  /// Phase 1C.3: dedup set keyed by `<phase>_<startMs>` so cycle_stuck
  /// fires at most once per individual stuck phase.
  final Set<String> stuckReported = {};

  // ── Derived state ────────────────────────────────────────────────────────
  bool get isCycleActive =>
      isAdhanPlaying || isDuaPlaying || isIqamaCountdown || isIqamaPlaying;

  bool get isPrePrayerAlert {
    if (isCycleActive) return false;
    return countdown.inSeconds > 0 && countdown.inSeconds <= 60;
  }

  bool get isInPostIqamaPrayer {
    final until = prayerInProgressEndsAt;
    return until != null && now.isBefore(until);
  }
}
