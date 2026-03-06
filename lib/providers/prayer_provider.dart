import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';
import '../models/daily_prayer_times.dart';
import '../models/app_settings.dart';
import '../services/csv_service.dart';
import '../services/audio_service.dart';

class PrayerProvider extends ChangeNotifier with WidgetsBindingObserver {
  final CsvService _csvService;
  final AudioService _audioService;
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
  String _currentAdhanPrayerKey = '';
  int _currentIqamaDelayMin = 0; // Issue 9: snapshot at adhan fire time
  DateTime? _adhanTriggerTime; // exact moment adhan fired — used to anchor iqama countdown
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

  // Issue 2: store subscription so it can be cancelled in dispose()
  StreamSubscription<void>? _completionSub;

  PrayerProvider(this._csvService, this._audioService,
      [AppSettings? settings])
      : _settings = settings ?? const AppSettings() {
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
  bool get isIqamaCountdown => _isIqamaCountdown;
  Duration get iqamaCountdown => _iqamaCountdown;
  String get iqamaPrayerName => _iqamaPrayerName;
  bool get isIqamaPlaying => _isIqamaPlaying;
  bool get isDuaPlaying => _isDuaPlaying;

  /// True when the user's Quran is "on" AND actually producing audio.
  bool get isQuranPlaying => _isQuranPlaying && !_isQuranPausedForAdhan;

  /// True when the user has Quran enabled (playing or paused by adhan).
  bool get quranUserEnabled => _isQuranPlaying;

  /// Called automatically via ChangeNotifierProxyProvider when settings change.
  void updateSettings(AppSettings settings) {
    final oldUrl = _settings.quranReciterServerUrl;
    final oldCity = _settings.selectedCity;
    final oldCountry = _settings.selectedCountry;
    _settings = settings;

    // If city or country changed, switch active city and reload prayer times
    if (settings.selectedCity != oldCity || settings.selectedCountry != oldCountry) {
      _csvService.setActiveCity(settings.selectedCity);
      _loadToday();
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

    notifyListeners();
  }

  void start() {
    WidgetsBinding.instance.addObserver(this);
    _now = DateTime.now(); // sync before recovery check
    _csvService.setActiveCity(_settings.selectedCity);
    _loadToday();
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), _tick);
    _recoverIqamaState(); // catch up if prayer was missed during absence
    notifyListeners();
  }

  /// Called by Flutter when the app returns to foreground.
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _now = DateTime.now();
      // Issue 6 + 11: reload if the date changed — catches new day and
      // timezone changes that shift DateTime.now() to a different calendar day.
      if (_now.day != _lastLoadedDay) {
        _adhansToday.clear();
        _loadToday();
      }
      _recoverIqamaState();
      notifyListeners();
    }
  }

  /// Checks if we are in the iqama-countdown window for a prayer whose
  /// adhan trigger was missed (app was killed or suspended at prayer time).
  /// If so, starts the countdown with the remaining seconds.
  void _recoverIqamaState() {
    if (_todayPrayers == null) return;
    // Do not interfere if a cycle is already in progress
    if (_isAdhanPlaying || _isDuaPlaying || _isIqamaCountdown || _isIqamaPlaying) return;

    final prayers = _todayPrayers!.prayersOnly;

    // Find the most recent prayer whose time has passed but was NOT triggered.
    // Issue 8: mark ALL missed prayers in _adhansToday (not just the latest),
    // so _checkAdhanTrigger never accidentally re-fires any of them.
    PrayerEntry? missed;
    for (final p in prayers) {
      final key = '${p.key}_${_now.day}';
      if (_adhansToday.contains(key)) continue;
      final timeSince = _now.difference(_adjustedTime(p));
      if (timeSince.inSeconds > 2) {
        _adhansToday.add(key); // mark every missed prayer immediately
        missed = p;            // keep overwriting — ends up as the latest one
      }
    }
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
      _currentAdhanPrayerKey = missed.key;
      _currentAdhanPrayerName = missed.name;
    }
    // If remaining <= 0 the iqama window has already closed — nothing to show
  }

  void reload() {
    _adhansToday.clear();
    _isIqamaCountdown = false;
    _loadToday();
    notifyListeners();
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
      notifyListeners();
      return;
    }

    // Issue 6: date-change detection — replaces the fragile == 00:00:00 check
    // that could be skipped when Timer.periodic drifts on slow hardware.
    if (_now.day != _lastLoadedDay) {
      _adhansToday.clear();
      _loadToday();
    }

    _updateNextPrayer();
    _checkAdhanTrigger();
    _tickIqama();
    notifyListeners();
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
    notifyListeners();
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
    _iqamaFallbackTimer?.cancel();
    await _audioService.stop();
    // Resume Quran after iqama ends
    _resumeQuranAfterAdhan();
    notifyListeners();
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
        final adjustedFajr =
            tomorrowPrayers.fajr.add(Duration(minutes: fajrOffset));
        final diff = adjustedFajr.difference(_now);
        _countdown = diff.isNegative ? Duration.zero : diff;
      } else {
        _countdown = Duration.zero;
      }
    }
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
    _currentAdhanPrayerKey = prayerKey;
    _currentIqamaDelayMin = _settings.iqamaDelays[prayerKey] ?? 0; // Issue 9: snapshot
    _adhanTriggerTime = _now; // anchor for iqama countdown calculation
    _isIqamaCountdown = false;

    // Pause Quran for adhan/dua/iqama cycle
    _pauseQuranForAdhan();

    // Auto-close after 4 minutes max as a fallback
    _adhanFallbackTimer?.cancel();
    _adhanFallbackTimer = Timer(const Duration(minutes: 4), () {
      if (_isAdhanPlaying) stopAdhan();
    });

    notifyListeners();

    final success = await _audioService.playAdhan(soundKey: _settings.adhanSound);
    if (!success && _isAdhanPlaying) {
      // Audio failed to start — cancel fallback and clean up immediately
      _adhanFallbackTimer?.cancel();
      _isAdhanPlaying = false;
      _resumeQuranAfterAdhan();
      notifyListeners();
    }
  }

  // Issue 10: guard against starting a test while a real cycle is active,
  // and guard against overlapping with the real prayer adhan.
  void testAdhan() {
    if (_isAdhanPlaying || _isDuaPlaying || _isIqamaCountdown || _isIqamaPlaying) return;
    unawaited(_triggerAdhan(_nextPrayerName, _nextPrayerKey));
  }

  // Issue 10: same guard for test iqama.
  void testIqama() {
    if (_isAdhanPlaying || _isDuaPlaying || _isIqamaCountdown || _isIqamaPlaying) return;
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
    notifyListeners();
  }

  // Issue 3: async so we can detect playDua() failure and advance directly
  // to the iqama countdown rather than leaving _isDuaPlaying=true silently.
  Future<void> _triggerDua() async {
    _isDuaPlaying = true;
    _duaFallbackTimer?.cancel();
    _duaFallbackTimer = Timer(const Duration(minutes: 5), () {
      if (_isDuaPlaying) stopDua();
    });
    notifyListeners();
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
    notifyListeners();
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
    notifyListeners();
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
      final serverUrl = _settings.quranReciterServerUrl;
      _audioService.resumeOrRestartQuranPlayer(serverUrl);
    }
  }

  String formatTime(DateTime dt, AppSettings settings) {
    if (settings.use24HourFormat) {
      return DateFormat('HH:mm').format(dt);
    } else {
      return DateFormat('hh:mm a').format(dt);
    }
  }

  String formatCountdown(Duration d) {
    if (d == Duration.zero) return '--:--';
    final h = d.inHours;
    final m = (d.inMinutes % 60).toString().padLeft(2, '0');
    final s = (d.inSeconds % 60).toString().padLeft(2, '0');
    if (h > 0) {
      return '${h.toString().padLeft(2, '0')}:$m:$s';
    }
    return '$m:$s';
  }

  String formatIqamaCountdown(Duration d) {
    if (d == Duration.zero) return '--:--';
    final m = d.inMinutes.toString().padLeft(2, '0');
    final s = (d.inSeconds % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _completionSub?.cancel(); // Issue 2: cancel to prevent subscription leak
    _timer?.cancel();
    _adhanFallbackTimer?.cancel();
    _duaFallbackTimer?.cancel();
    _iqamaFallbackTimer?.cancel();
    super.dispose();
  }
}
