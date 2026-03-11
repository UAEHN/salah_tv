import 'dart:async';
import 'package:intl/intl.dart';
import '../../../models/daily_prayer_times.dart';
import '../../../models/app_settings.dart';
import 'i_prayer_times_repository.dart';
import '../../audio/domain/i_audio_repository.dart';

/// Pure-Dart Humble Object that owns all prayer-cycle state and logic.
/// The Flutter-specific [WidgetsBindingObserver] concern stays in
/// [PrayerProvider]; this class is fully testable without Flutter.
class PrayerCycleEngine {
  final IPrayerTimesRepository _csvService;
  final IAudioRepository _audioService;
  final void Function() _onStateChanged;
  AppSettings _settings;

  Timer? _timer;
  DailyPrayerTimes? _todayPrayers;
  DateTime _now = DateTime.now();
  Duration _countdown = Duration.zero;
  String _nextPrayerName = '';
  String _nextPrayerKey = '';
  final Set<String> _adhansToday = {};
  int _lastLoadedDay = -1; // Issue 6: date-change detection

  bool _isAdhanPlaying = false;
  String _currentAdhanPrayerName = '';
  String _activeCyclePrayerKey =
      ''; // set when adhan fires, cleared after iqama ends
  int _currentIqamaDelayMin = 0; // Issue 9: snapshot at adhan fire time
  DateTime?
  _adhanTriggerTime; // exact moment adhan fired — used to anchor iqama countdown
  Timer? _adhanFallbackTimer;

  bool _isIqamaCountdown = false;
  Duration _iqamaCountdown = Duration.zero;
  String _iqamaPrayerName = '';

  bool _isIqamaPlaying = false;
  Timer? _iqamaFallbackTimer;

  bool _isDuaPlaying = false;
  Timer? _duaFallbackTimer;

  // ── Quran background audio state ────────────────────────────────────────
  /// Whether the user has Quran "on" (wants it to play).
  bool _isQuranPlaying = false;

  /// Internally paused because adhan/dua/iqama is active. Will auto-resume.
  bool _isQuranPausedForAdhan = false;

  // ── Pre-alert bell state ────────────────────────────────────────────────
  /// Tracks which prayers have already had the bell played (keyed like _adhansToday).
  final Set<String> _preAlertBellPlayed = {};

  // ── Pre-adhan announcement state ─────────────────────────────────────────
  /// Tracks which prayers have already had the announcement played.
  final Set<String> _preAnnouncementPlayed = {};

  // ── Makkah stream audio state ────────────────────────────────────────────
  /// True when the Makkah stream is playing with audio (so Quran stays paused).
  bool _isMakkahStreamAudioActive = false;

  // Issue 2: store subscription so it can be cancelled in dispose()
  StreamSubscription<void>? _completionSub;

  PrayerCycleEngine(
    this._csvService,
    this._audioService,
    AppSettings settings,
    this._onStateChanged,
  ) : _settings = settings {
    // Issue 2: stored subscription; Issue 4: entry guards in each stop method
    // prevent re-entrant / double-fire from onComplete
    _completionSub = _audioService.onComplete.listen((_) async {
      if (_isAdhanPlaying) {
        await stopAdhan();
      } else if (_isDuaPlaying) {
        await stopDua();
      } else if (_isIqamaPlaying) {
        await stopIqama();
      }
    });
  }

  DateTime get now => _now;
  DailyPrayerTimes? get todayPrayers => _todayPrayers;
  Duration get countdown => _countdown;
  String get nextPrayerName => _nextPrayerName;
  String get nextPrayerKey => _nextPrayerKey;
  bool get isAdhanPlaying => _isAdhanPlaying;
  String get currentAdhanPrayerName => _currentAdhanPrayerName;
  String get activeCyclePrayerKey => _activeCyclePrayerKey;
  bool get isIqamaCountdown => _isIqamaCountdown;
  Duration get iqamaCountdown => _iqamaCountdown;
  String get iqamaPrayerName => _iqamaPrayerName;
  bool get isIqamaPlaying => _isIqamaPlaying;
  bool get isDuaPlaying => _isDuaPlaying;

  /// True when the user's Quran is "on" AND actually producing audio.
  bool get isQuranPlaying => _isQuranPlaying && !_isQuranPausedForAdhan;

  /// True when the user has Quran enabled (playing or paused by adhan).
  bool get quranUserEnabled => _isQuranPlaying;

  /// True when any phase of the prayer cycle is active.
  bool get isCycleActive =>
      _isAdhanPlaying || _isDuaPlaying || _isIqamaCountdown || _isIqamaPlaying;

  /// True when the countdown is within 60 seconds of the next prayer and no cycle is active.
  bool get isPrePrayerAlert {
    if (isCycleActive) return false;
    return _countdown.inSeconds > 0 && _countdown.inSeconds <= 60;
  }

  bool get isMakkahStreamAudioActive => _isMakkahStreamAudioActive;

  /// Called by the Makkah stream widget when stream audio starts/stops.
  /// Mirrors the Quran pause/resume pattern used during the adhan cycle.
  void setMakkahStreamAudioActive(bool value) {
    if (_isMakkahStreamAudioActive == value) return;
    _isMakkahStreamAudioActive = value;
    if (value) {
      // Stream audio turning on — pause Quran if it is currently playing
      if (_isQuranPlaying && !_isQuranPausedForAdhan) {
        _audioService.pauseQuranPlayer();
      }
    } else {
      // Stream audio turning off — restart Quran from current surah.
      // Always restart (not resume) because ExoPlayer may have caused the
      // audioplayer to lose its paused state via Android audio focus changes.
      if (_isQuranPlaying && !_isQuranPausedForAdhan) {
        _audioService.restartQuranCurrentSurah(_settings.quranReciterServerUrl);
      }
    }
    // No _onStateChanged() here — no widget watches _isMakkahStreamAudioActive.
    // Calling it caused a redundant notifyListeners() rebuild cascade that
    // starved the 1-second tick timer on slow TV hardware.
  }

  /// Called automatically via ChangeNotifierProxyProvider when settings change.
  void updateSettings(AppSettings settings) {
    final oldUrl = _settings.quranReciterServerUrl;
    final oldCity = _settings.selectedCity;
    final oldCountry = _settings.selectedCountry;
    _settings = settings;

    // If city or country changed, reset adhan state and reload prayer times
    if (settings.selectedCity != oldCity ||
        settings.selectedCountry != oldCountry) {
      _resetAdhanCycleForCityChange();
      _csvService.setActiveCity(settings.selectedCity);
      _loadToday();
      _recoverIqamaState();
    } else {
      _updateNextPrayer();
    }

    // If reciter changed while Quran is actively playing, switch immediately
    if (_isQuranPlaying &&
        !_isQuranPausedForAdhan &&
        settings.quranReciterServerUrl.isNotEmpty &&
        settings.quranReciterServerUrl != oldUrl) {
      _audioService.playQuranFromServer(settings.quranReciterServerUrl);
    }

    _onStateChanged();
  }

  void start() {
    _now = DateTime.now(); // sync before recovery check
    _csvService.setActiveCity(_settings.selectedCity);
    _loadToday();
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), _tick);
    _recoverIqamaState(); // catch up if prayer was missed during absence
    _onStateChanged();
  }

  /// Called by PrayerProvider when the app returns to foreground.
  void onResumed() {
    _now = DateTime.now();
    // Issue 6 + 11: reload if the date changed — catches new day and
    // timezone changes that shift DateTime.now() to a different calendar day.
    if (_now.day != _lastLoadedDay) {
      _adhansToday.clear();
      _loadToday();
    }
    _recoverIqamaState();
    _onStateChanged();
  }

  /// Checks if we are in the iqama-countdown window for a prayer whose
  /// adhan trigger was missed (app was killed or suspended at prayer time).
  /// If so, starts the countdown with the remaining seconds.
  void _recoverIqamaState() {
    if (_todayPrayers == null) return;
    // Do not interfere if a cycle is already in progress
    if (_isAdhanPlaying ||
        _isDuaPlaying ||
        _isIqamaCountdown ||
        _isIqamaPlaying)
      return;

    final missed = _markMissedPrayers();
    if (missed == null) return;

    final iqamaDelayMin = _settings.iqamaDelays[missed.key] ?? 0;
    if (iqamaDelayMin <= 0) return;

    // Iqama target = adjusted prayer time + iqama delay
    final iqamaAt = _adjustedTime(missed).add(Duration(minutes: iqamaDelayMin));
    final remaining = iqamaAt.difference(_now);

    if (remaining.inSeconds > 0) {
      // Still inside the iqama countdown window — show it
      _isIqamaCountdown = true;
      _iqamaCountdown = remaining;
      _iqamaPrayerName = missed.name;
      _currentAdhanPrayerName = missed.name;
      _activeCyclePrayerKey = missed.key; // lock card highlight on recovery
    }
    // If remaining <= 0 the iqama window has already closed — nothing to show
  }

  /// Issue 8: mark ALL missed prayers in _adhansToday so _checkAdhanTrigger
  /// never re-fires any of them. Returns the latest missed prayer, or null.
  PrayerEntry? _markMissedPrayers() {
    final prayers = _todayPrayers!.prayersOnly;
    PrayerEntry? missed;
    for (final p in prayers) {
      final key = '${p.key}_${_now.day}';
      if (_adhansToday.contains(key)) continue;
      final timeSince = _now.difference(_adjustedTime(p));
      if (timeSince.inSeconds > 2) {
        _adhansToday.add(key); // mark every missed prayer immediately
        missed = p; // keep overwriting — ends up as the latest one
      }
    }
    return missed;
  }

  void _resetAdhanCycleForCityChange() {
    _adhansToday.clear();
    _adhanFallbackTimer?.cancel();
    _duaFallbackTimer?.cancel();
    _iqamaFallbackTimer?.cancel();
    if (_isAdhanPlaying || _isDuaPlaying || _isIqamaPlaying) {
      _audioService.stop();
    }
    _isAdhanPlaying = false;
    _currentAdhanPrayerName = '';
    _activeCyclePrayerKey = '';
    _currentIqamaDelayMin = 0;
    _adhanTriggerTime = null;
    _isIqamaCountdown = false;
    _iqamaCountdown = Duration.zero;
    _iqamaPrayerName = '';
    _isIqamaPlaying = false;
    _isDuaPlaying = false;
    _resumeQuranAfterAdhan();
  }

  void reload() {
    _adhansToday.clear();
    _isIqamaCountdown = false;
    _loadToday();
    _onStateChanged();
  }

  void _loadToday() {
    _todayPrayers = _csvService.getToday();
    _lastLoadedDay = _now.day; // Issue 6: record the day we loaded for
    _updateNextPrayer();
  }

  void _tick(Timer t) {
    final prev = _now;
    _now = DateTime.now();

    // Detect system time change: if the clock jumped by more than 5 seconds
    // (forward or backward), treat it as a manual time adjustment and reload.
    final drift = _now.difference(prev).inSeconds;
    if (drift.abs() > 5) {
      _adhansToday.clear();
      _loadToday();
      _recoverIqamaState();
      _onStateChanged();
      return;
    }

    // Issue 6: date-change detection — replaces the fragile == 00:00:00 check
    // that could be skipped when Timer.periodic drifts on slow hardware.
    if (_now.day != _lastLoadedDay) {
      _adhansToday.clear();
      _preAlertBellPlayed.clear();
      _preAnnouncementPlayed.clear();
      _loadToday();
    }

    _updateNextPrayer();
    _checkPreAnnouncement();
    _checkPreAlertBell();
    _checkAdhanTrigger();
    _tickIqama();
    _onStateChanged();
  }

  void _tickIqama() {
    if (!_isIqamaCountdown) return;
    if (_iqamaCountdown.inSeconds > 0) {
      _iqamaCountdown -= const Duration(seconds: 1);
    } else {
      _isIqamaCountdown = false;
      unawaited(_triggerIqama());
    }
  }

  // Issue 3: async so we can detect playIqama() failure and skip to Quran
  // resume immediately rather than waiting for the 4-minute fallback timer.
  Future<void> _triggerIqama() async {
    _isIqamaPlaying = true;
    _iqamaFallbackTimer?.cancel();
    _iqamaFallbackTimer = Timer(const Duration(minutes: 4), () {
      if (_isIqamaPlaying) stopIqama();
    });
    _onStateChanged();
    final success = await _audioService.playIqama();
    if (!success && _isIqamaPlaying) {
      // Audio failed to start — clean up immediately
      _iqamaFallbackTimer?.cancel();
      await stopIqama();
    }
  }

  // Issue 1: async + await stop() before resuming Quran.
  // Issue 4: entry guard prevents double-call from concurrent onComplete events.
  Future<void> stopIqama() async {
    if (!_isIqamaPlaying) return;
    _isIqamaPlaying = false;
    _activeCyclePrayerKey = ''; // cycle fully done — release card highlight
    _iqamaFallbackTimer?.cancel();
    await _audioService.stop();
    // Resume Quran after iqama ends
    _resumeQuranAfterAdhan();
    _onStateChanged();
  }

  /// Returns the effective (offset-adjusted) time for a prayer.
  DateTime _adjustedTime(PrayerEntry p) {
    final offsetMin = _settings.adhanOffsets[p.key] ?? 0;
    return p.time.add(Duration(minutes: offsetMin));
  }

  void _updateNextPrayer() {
    if (_todayPrayers == null) return;
    final prayers = _todayPrayers!.prayersOnly;
    PrayerEntry? next;
    Duration shortest = const Duration(days: 1);

    for (final p in prayers) {
      final diff = _adjustedTime(p).difference(_now);
      if (diff.isNegative) continue;
      if (diff < shortest) {
        shortest = diff;
        next = p;
      }
    }

    if (next != null) {
      _nextPrayerName = next.name;
      _nextPrayerKey = next.key;
      _countdown = shortest;
    } else {
      // All prayers done today — countdown to tomorrow's Fajr
      _nextPrayerName = 'الفجر';
      _nextPrayerKey = 'fajr';
      final tomorrow = DateTime(_now.year, _now.month, _now.day + 1);
      final tomorrowKey = DateFormat('dd/MM/yyyy').format(tomorrow);
      final tomorrowPrayers = _csvService.getTomorrowByKey(tomorrowKey);
      if (tomorrowPrayers != null) {
        final fajrOffset = _settings.adhanOffsets['fajr'] ?? 0;
        final adjustedFajr = tomorrowPrayers.fajr.add(
          Duration(minutes: fajrOffset),
        );
        final diff = adjustedFajr.difference(_now);
        _countdown = diff.isNegative ? Duration.zero : diff;
      } else {
        _countdown = Duration.zero;
      }
    }
  }

  /// Play the prayer-name announcement 5 seconds before adhan fires.
  void _checkPreAnnouncement() {
    if (isCycleActive) return;
    final key = '${_nextPrayerKey}_${_now.day}';
    if (_preAnnouncementPlayed.contains(key)) return;
    if (_countdown.inSeconds > 0 && _countdown.inSeconds <= 5) {
      _preAnnouncementPlayed.add(key);
      unawaited(_audioService.playPrayerAnnouncement(_nextPrayerKey));
    }
  }

  /// Play a soft bell once when the countdown enters the 1-minute pre-alert window.
  void _checkPreAlertBell() {
    if (!isPrePrayerAlert) return;
    final key = '${_nextPrayerKey}_${_now.day}';
    if (_preAlertBellPlayed.contains(key)) return;
    _preAlertBellPlayed.add(key);
    _audioService.playPreAlertBell();
  }

  void _checkAdhanTrigger() {
    if (_todayPrayers == null) return;
    final prayers = _todayPrayers!.prayersOnly;
    for (final p in prayers) {
      final key = '${p.key}_${_now.day}';
      if (_adhansToday.contains(key)) continue;
      final diff = _now.difference(_adjustedTime(p));
      if (diff.inSeconds >= 0 && diff.inSeconds <= 2) {
        _adhansToday.add(key);
        unawaited(_triggerAdhan(p.name, p.key));
      }
    }
  }

  // Issue 3: async so we can detect playAdhan() failure and clean up
  // state immediately rather than waiting 4 minutes for the fallback timer.
  Future<void> _triggerAdhan(String prayerName, String prayerKey) async {
    _isAdhanPlaying = true;
    _currentAdhanPrayerName = prayerName;
    _activeCyclePrayerKey = prayerKey; // lock card highlight for this prayer
    _currentIqamaDelayMin =
        _settings.iqamaDelays[prayerKey] ?? 0; // Issue 9: snapshot
    _adhanTriggerTime = _now; // anchor for iqama countdown calculation
    _isIqamaCountdown = false;

    // Immediately disable Makkah stream audio so it doesn't overlap adhan.
    _isMakkahStreamAudioActive = false;

    // Pause Quran for adhan/dua/iqama cycle
    _pauseQuranForAdhan();

    // Auto-close after 4 minutes max as a fallback
    _adhanFallbackTimer?.cancel();
    _adhanFallbackTimer = Timer(const Duration(minutes: 4), () {
      if (_isAdhanPlaying) stopAdhan();
    });

    _onStateChanged();

    final success = await _audioService.playAdhan(
      soundKey: _settings.adhanSound,
    );
    if (!success && _isAdhanPlaying) {
      // Audio failed to start — cancel fallback and clean up immediately
      _adhanFallbackTimer?.cancel();
      _isAdhanPlaying = false;
      _resumeQuranAfterAdhan();
      _onStateChanged();
    }
  }

  // Issue 10: guard against starting a test while a real cycle is active,
  // and guard against overlapping with the real prayer adhan.
  void testAdhan() {
    if (_isAdhanPlaying ||
        _isDuaPlaying ||
        _isIqamaCountdown ||
        _isIqamaPlaying)
      return;
    unawaited(_triggerAdhan(_nextPrayerName, _nextPrayerKey));
  }

  // Issue 10: same guard for test iqama.
  void testIqama() {
    if (_isAdhanPlaying ||
        _isDuaPlaying ||
        _isIqamaCountdown ||
        _isIqamaPlaying)
      return;
    _iqamaPrayerName = _nextPrayerName;
    unawaited(_triggerIqama());
  }

  // Issue 1: async + await stop() before triggering dua so the stop platform
  // call fully resolves before playDua() opens the same AudioPlayer.
  // Issue 4: entry guard prevents double-invocation from concurrent events.
  Future<void> stopAdhan() async {
    if (!_isAdhanPlaying) return;
    _isAdhanPlaying = false;
    _adhanFallbackTimer?.cancel();
    await _audioService.stop();
    // Show dua screen after adhan — fire-and-forget, _triggerDua notifies UI
    unawaited(_triggerDua());
    _onStateChanged();
  }

  // Issue 3: async so we can detect playDua() failure and advance directly
  // to the iqama countdown rather than leaving _isDuaPlaying=true silently.
  Future<void> _triggerDua() async {
    _isDuaPlaying = true;
    _duaFallbackTimer?.cancel();
    _duaFallbackTimer = Timer(const Duration(minutes: 5), () {
      if (_isDuaPlaying) stopDua();
    });
    _onStateChanged();
    final success = await _audioService.playDua();
    if (!success && _isDuaPlaying) {
      // Audio failed — skip dua and proceed to iqama countdown
      _duaFallbackTimer?.cancel();
      await stopDua();
    }
  }

  // Issue 1: async + await stop() before starting iqama countdown.
  // Issue 4: entry guard prevents double-invocation.
  // Issue 9: use _currentIqamaDelayMin (snapshot) instead of live settings.
  Future<void> stopDua() async {
    if (!_isDuaPlaying) return;
    _isDuaPlaying = false;
    _duaFallbackTimer?.cancel();
    await _audioService.stop();

    // Start iqama countdown after dua — anchored to adhan trigger time
    // so adhan + dua duration is deducted automatically.
    final delay = _currentIqamaDelayMin; // Issue 9: snapshotted at adhan fire
    if (delay > 0) {
      _iqamaPrayerName = _currentAdhanPrayerName;

      // Calculate how much of the iqama delay has already elapsed
      // since the adhan started (adhan duration + dua duration).
      Duration remaining = Duration(minutes: delay);
      if (_adhanTriggerTime != null) {
        final elapsed = _now.difference(_adhanTriggerTime!);
        remaining = Duration(minutes: delay) - elapsed;
      }

      if (remaining.inSeconds > 0) {
        _isIqamaCountdown = true;
        _iqamaCountdown = remaining;
      } else {
        // Iqama window already passed — trigger immediately
        unawaited(_triggerIqama());
      }
    }
    _onStateChanged();
  }

  // ── Quran control ────────────────────────────────────────────────────────

  /// Toggle Quran streaming on/off.
  /// [serverUrl] is the CDN URL from mp3quran.net API (e.g. 'https://server8.mp3quran.net/maher/')
  void toggleQuran(String? serverUrl) {
    if (_isQuranPlaying) {
      _isQuranPlaying = false;
      _isQuranPausedForAdhan = false;
      _audioService.stopQuranPlayer();
    } else {
      if (serverUrl == null || serverUrl.isEmpty) return;
      _isQuranPlaying = true;
      _isQuranPausedForAdhan = false;
      _audioService.playQuranFromServer(serverUrl); // async, fire-and-forget
    }
    _onStateChanged();
  }

  /// Pause Quran when adhan starts (internal, auto-resumes after iqama).
  void _pauseQuranForAdhan() {
    if (_isQuranPlaying && !_isQuranPausedForAdhan) {
      _isQuranPausedForAdhan = true;
      _audioService.pauseQuranPlayer();
    }
  }

  /// Resume Quran after iqama ends (internal).
  /// Issue 7: uses resumeOrRestartQuranPlayer so a timed-out HTTP stream is
  /// restarted from the current surah rather than silently producing no audio.
  void _resumeQuranAfterAdhan() {
    if (_isQuranPausedForAdhan) {
      _isQuranPausedForAdhan = false;
      // Don't resume Quran if Makkah stream audio is still active
      if (_isMakkahStreamAudioActive) return;
      final serverUrl = _settings.quranReciterServerUrl;
      _audioService.resumeOrRestartQuranPlayer(serverUrl);
    }
  }

  void dispose() {
    _completionSub?.cancel(); // Issue 2: cancel to prevent subscription leak
    _timer?.cancel();
    _adhanFallbackTimer?.cancel();
    _duaFallbackTimer?.cancel();
    _iqamaFallbackTimer?.cancel();
  }
}
