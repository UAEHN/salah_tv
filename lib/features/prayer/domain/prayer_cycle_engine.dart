import 'dart:async';

import 'entities/daily_prayer_times.dart';
import 'i_prayer_audio_port.dart';
import 'i_prayer_notification_port.dart';
import 'i_prayer_times_repository.dart';
import '../../settings/domain/entities/app_settings.dart';
import 'engine/prayer_cycle_state.dart';
import 'engine/prayer_cycle_base.dart';
import 'engine/recovery_mixin.dart';
import 'engine/quran_mixin.dart';
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
        RecoveryMixin,
        QuranMixin,
        IqamaMixin,
        AdhanCycleMixin,
        TickMixin,
        SettingsMixin {
  @override
  final PrayerCycleState s = PrayerCycleState();

  @override
  final IPrayerAudioPort audio;

  @override
  final IPrayerTimesRepository repo;

  @override
  AppSettings settings;

  @override
  final IPrayerNotificationPort? notifications;

  @override
  final void Function() notify;

  StreamSubscription<void>? _completionSub;

  PrayerCycleEngine(
    this.repo,
    this.audio,
    AppSettings initialSettings,
    this.notify, {
    this.notifications,
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
  }

  // ── Public getters (delegated to PrayerCycleState) ───────────────────────
  DateTime get now => s.now;
  DailyPrayerTimes? get todayPrayers => s.todayPrayers;
  Duration get countdown => s.countdown;
  String get nextPrayerName => s.nextPrayerName;
  String get nextPrayerKey => s.nextPrayerKey;
  bool get isAdhanPlaying => s.isAdhanPlaying;
  String get currentAdhanPrayerName => s.currentAdhanPrayerName;
  String get activeCyclePrayerKey => s.activeCyclePrayerKey;
  bool get isIqamaCountdown => s.isIqamaCountdown;
  Duration get iqamaCountdown => s.iqamaCountdown;
  String get iqamaPrayerName => s.iqamaPrayerName;
  bool get isIqamaPlaying => s.isIqamaPlaying;
  bool get isDuaPlaying => s.isDuaPlaying;

  /// True when the user's Quran is "on" AND actually producing audio.
  bool get isQuranPlaying => s.isQuranPlaying && !s.isQuranPausedForAdhan;

  /// True when the user has Quran enabled (playing or paused by adhan).
  bool get quranUserEnabled => s.isQuranPlaying;

  bool get isCycleActive => s.isCycleActive;
  bool get isPrePrayerAlert => s.isPrePrayerAlert;
  bool get isMultiCity => repo.isMultiCity;
  List<String> get availableCities => repo.availableCities;

  // ── Lifecycle ─────────────────────────────────────────────────────────────
  void start() {
    s.now = DateTime.now(); // sync before recovery check
    repo.setActiveCity(settings.selectedCity);
    loadToday();
    s.timer?.cancel();
    s.timer = Timer.periodic(const Duration(seconds: 1), tick);
    s.needsIqamaRecovery = true;
    if (s.todayPrayers != null) {
      recoverIqamaState(); // catch up if prayer was missed during absence
      s.needsIqamaRecovery = false;
    }
    notify();
  }

  /// Called by PrayerBloc when the app is sent to the background.
  /// Pauses Quran so it doesn't bleed into the next foreground session.
  void onPaused() {
    if (s.isQuranPlaying && !s.isQuranPausedForAdhan) {
      audio.pauseQuranPlayer(); // sets _quranPausedAt timestamp for Issue 7
    }
  }

  /// Called by PrayerBloc when the app returns to foreground.
  void onResumed() {
    s.now = DateTime.now();
    // Issue 6 + 11: reload if the date changed — catches new day and
    // timezone changes that shift DateTime.now() to a different calendar day.
    if (s.now.day != s.lastLoadedDay) {
      s.adhansToday.clear();
      loadToday();
    }
    // If adhan or dua started while the app was in the background, the audio
    // may have played partially or not at all (Android suspends the isolate).
    // Clear these phases so recoverIqamaState() can recompute the correct
    // state (iqama countdown or idle) based on actual elapsed time.
    if (s.isAdhanPlaying || s.isDuaPlaying) {
      s.adhanFallbackTimer?.cancel();
      s.duaFallbackTimer?.cancel();
      s.isAdhanPlaying = false;
      s.isDuaPlaying = false;
      unawaited(audio.stop());
    }
    recoverIqamaState();
    if (s.isQuranPlaying && !s.isQuranPausedForAdhan) {
      audio.resumeOrRestartQuranPlayer(settings.quranReciterServerUrl);
    }
    notify();
  }

  void dispose() {
    _completionSub?.cancel(); // Issue 2: cancel to prevent subscription leak
    s.timer?.cancel();
    s.adhanFallbackTimer?.cancel();
    s.duaFallbackTimer?.cancel();
    s.iqamaFallbackTimer?.cancel();
  }
}
