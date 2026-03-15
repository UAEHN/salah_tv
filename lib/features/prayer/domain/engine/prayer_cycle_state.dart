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
  String nextPrayerName = '';
  String nextPrayerKey = '';
  final Set<String> adhansToday = {};
  int lastLoadedDay = -1; // Issue 6: date-change detection
  bool needsIqamaRecovery = false;

  // ── Adhan state ──────────────────────────────────────────────────────────
  bool isAdhanPlaying = false;
  String currentAdhanPrayerName = '';
  String activeCyclePrayerKey = ''; // set when adhan fires, cleared after iqama ends
  int currentIqamaDelayMin = 0; // Issue 9: snapshot at adhan fire time
  DateTime? adhanTriggerTime; // exact moment adhan fired — anchors iqama countdown
  Timer? adhanFallbackTimer;

  // ── Dua state ────────────────────────────────────────────────────────────
  bool isDuaPlaying = false;
  Timer? duaFallbackTimer;

  // ── Iqama countdown & playback ───────────────────────────────────────────
  bool isIqamaCountdown = false;
  Duration iqamaCountdown = Duration.zero;
  String iqamaPrayerName = '';
  bool isIqamaPlaying = false;
  Timer? iqamaFallbackTimer;

  // ── Quran background audio ───────────────────────────────────────────────
  /// Whether the user has Quran "on" (wants it to play).
  bool isQuranPlaying = false;

  /// Internally paused because adhan/dua/iqama is active. Will auto-resume.
  bool isQuranPausedForAdhan = false;

  // ── Pre-alert dedup sets ─────────────────────────────────────────────────
  final Set<String> preAlertBellPlayed = {};
  final Set<String> preAnnouncementPlayed = {};

  // ── Makkah stream audio ──────────────────────────────────────────────────
  bool isMakkahStreamAudioActive = false;

  // ── Derived state ────────────────────────────────────────────────────────
  bool get isCycleActive =>
      isAdhanPlaying || isDuaPlaying || isIqamaCountdown || isIqamaPlaying;

  bool get isPrePrayerAlert {
    if (isCycleActive) return false;
    return countdown.inSeconds > 0 && countdown.inSeconds <= 60;
  }
}
