import 'dart:async';

import '../entities/daily_prayer_times.dart';

/// Mutable state bag for [PrayerCycleEngine].
/// All 23 engine state fields live here, accessible to every mixin via [s].
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

  // ── Iqama countdown & playback ───────────────────────────────────────────
  bool isIqamaCountdown = false;
  Duration iqamaCountdown = Duration.zero;
  String iqamaPrayerKey = '';
  bool isIqamaPlaying = false;
  Timer? iqamaFallbackTimer;

  // ── Mosque-mode post-iqama prayer window ─────────────────────────────────
  // Set when iqama ends in mosque mode; while [now] is before this timestamp
  // the home screen shows the silence-phone takeover. Cleared by tick when
  // expired.
  DateTime? prayerInProgressEndsAt;

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
