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

  bool _isAdhanPlaying = false;
  String _currentAdhanPrayerName = '';
  String _currentAdhanPrayerKey = '';
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

  PrayerProvider(this._csvService, this._audioService,
      [AppSettings? settings])
      : _settings = settings ?? const AppSettings() {
    _audioService.onComplete.listen((_) {
      if (_isAdhanPlaying) {
        stopAdhan();
      } else if (_isDuaPlaying) {
        stopDua();
      } else if (_isIqamaPlaying) {
        stopIqama();
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
    _settings = settings;
    _updateNextPrayer();

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

    // Find the most recent prayer whose time has passed but was NOT triggered
    PrayerEntry? missed;
    for (final p in prayers) {
      final key = '${p.key}_${_now.day}';
      if (_adhansToday.contains(key)) continue;
      final timeSince = _now.difference(_adjustedTime(p));
      // Missed the 2-second live window, but still today
      if (timeSince.inSeconds > 2) {
        missed = p; // keep iterating to find the latest one
      }
    }
    if (missed == null) return;

    // Mark as triggered so _checkAdhanTrigger never fires it again
    _adhansToday.add('${missed.key}_${_now.day}');

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
    _updateNextPrayer();
  }

  void _tick(Timer t) {
    _now = DateTime.now();

    // Midnight reset: reload next day's times
    if (_now.hour == 0 && _now.minute == 0 && _now.second == 0) {
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
      _triggerIqama();
    }
  }

  void _triggerIqama() {
    _isIqamaPlaying = true;
    _audioService.playIqama();
    _iqamaFallbackTimer?.cancel();
    _iqamaFallbackTimer = Timer(const Duration(minutes: 4), () {
      if (_isIqamaPlaying) stopIqama();
    });
    notifyListeners();
  }

  void stopIqama() {
    _isIqamaPlaying = false;
    _iqamaFallbackTimer?.cancel();
    _audioService.stop();
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
        _triggerAdhan(p.name, p.key);
      }
    }
  }

  void _triggerAdhan(String prayerName, String prayerKey) {
    _isAdhanPlaying = true;
    _currentAdhanPrayerName = prayerName;
    _currentAdhanPrayerKey = prayerKey;
    _adhanTriggerTime = _now; // anchor for iqama countdown calculation
    _isIqamaCountdown = false;

    // Pause Quran for adhan/dua/iqama cycle
    _pauseQuranForAdhan();

    _audioService.playAdhan();

    // Auto-close after 4 minutes max as a fallback
    _adhanFallbackTimer?.cancel();
    _adhanFallbackTimer = Timer(const Duration(minutes: 4), () {
      if (_isAdhanPlaying) {
        stopAdhan();
      }
    });

    notifyListeners();
  }

  void testAdhan() {
    _triggerAdhan(_nextPrayerName, _nextPrayerKey);
  }

  void testIqama() {
    _iqamaPrayerName = _nextPrayerName;
    _triggerIqama();
  }

  void stopAdhan() {
    _isAdhanPlaying = false;
    _adhanFallbackTimer?.cancel();
    _audioService.stop();
    // Show dua screen after adhan
    _triggerDua();
    notifyListeners();
  }

  void _triggerDua() {
    _isDuaPlaying = true;
    _audioService.playDua();
    _duaFallbackTimer?.cancel();
    _duaFallbackTimer = Timer(const Duration(minutes: 5), () {
      if (_isDuaPlaying) stopDua();
    });
    notifyListeners();
  }

  void stopDua() {
    _isDuaPlaying = false;
    _duaFallbackTimer?.cancel();
    _audioService.stop();

    // Start iqama countdown after dua — anchored to adhan trigger time
    // so adhan + dua duration is deducted automatically.
    final delay = _settings.iqamaDelays[_currentAdhanPrayerKey] ?? 0;
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
        _triggerIqama();
      }
    }
    notifyListeners();
  }

  // ── Quran control ────────────────────────────────────────────────────────

  /// Toggle Quran on/off from the home screen button.
  /// [filePath] is the selected reciter's file path from settings.
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
  void _resumeQuranAfterAdhan() {
    if (_isQuranPausedForAdhan) {
      _isQuranPausedForAdhan = false;
      _audioService.resumeQuranPlayer();
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
    _timer?.cancel();
    _adhanFallbackTimer?.cancel();
    _duaFallbackTimer?.cancel();
    _iqamaFallbackTimer?.cancel();
    super.dispose();
  }
}
