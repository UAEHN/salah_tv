import 'dart:async';
import 'package:audioplayers/audioplayers.dart';

class AudioService {
  static final AudioService _instance = AudioService._internal();
  factory AudioService() => _instance;

  // Issue 4/5: custom broadcast stream so we can fire it from both natural
  // completion AND external interruption (audio focus loss).
  final StreamController<void> _onCompleteController =
      StreamController<void>.broadcast();

  // Issue 5: set true around any app-initiated _player.stop() so the
  // onPlayerStateChanged listener can distinguish intentional stops from
  // external interruptions (audio focus lost, another app takes over).
  bool _appInitiatedStop = false;

  AudioService._internal() {
    // Natural completion → advance state machine
    _player.onPlayerComplete.listen((_) {
      _isPlaying = false;
      _onCompleteController.add(null);
    });

    // Issue 5: external interruption detection.
    // If the player reaches PlayerState.stopped while _isPlaying is true and
    // the app did NOT initiate the stop, treat it as a completion so the state
    // machine advances immediately instead of freezing for 4 minutes.
    _player.onPlayerStateChanged.listen((state) {
      if (state == PlayerState.stopped &&
          _isPlaying &&
          !_appInitiatedStop) {
        _isPlaying = false;
        _onCompleteController.add(null);
      }
    });

    // When a Quran surah finishes, advance to the next (1→2→…→114→1)
    _quranPlayer.onPlayerComplete.listen((_) {
      if (_quranServerUrl.isNotEmpty) {
        _quranSurahIndex = (_quranSurahIndex + 1) % 114;
        _playCurrentSurah();
      }
    });
  }

  // ── Adhan / Dua / Iqama player ──────────────────────────────────────────
  final AudioPlayer _player = AudioPlayer();
  bool _isPlaying = false;

  bool get isPlaying => _isPlaying;

  Stream<void> get onComplete => _onCompleteController.stream;

  // Issue 3: return bool so the caller can detect a silent audio failure and
  // recover immediately rather than waiting for the 4-minute fallback timer.

  /// Single source of truth for available adhan sounds.
  /// To add a new adhan: add an entry here and register the asset in pubspec.yaml.
  static const adhanSounds = [
    (key: 'default', label: 'أذان 1', asset: 'audio/adhan.mp3'),
    (key: 'raad_al_kurdi', label: 'أذان 2', asset: 'audio/Raad Al-Kurdi.mp3'),
  ];

  Future<bool> playAdhan({String soundKey = 'default'}) async {
    try {
      _appInitiatedStop = true;
      await _player.stop();
      _appInitiatedStop = false;
      _isPlaying = true;
      final asset = adhanSounds
              .firstWhere((s) => s.key == soundKey,
                  orElse: () => adhanSounds.first)
              .asset;
      await _player.play(AssetSource(asset));
      return true;
    } catch (_) {
      _isPlaying = false;
      _appInitiatedStop = false;
      return false;
    }
  }

  Future<bool> playDua() async {
    try {
      _appInitiatedStop = true;
      await _player.stop();
      _appInitiatedStop = false;
      _isPlaying = true;
      await _player.play(AssetSource('audio/dua.mp3'));
      return true;
    } catch (_) {
      _isPlaying = false;
      _appInitiatedStop = false;
      return false;
    }
  }

  Future<bool> playIqama() async {
    try {
      _appInitiatedStop = true;
      await _player.stop();
      _appInitiatedStop = false;
      _isPlaying = true;
      await _player.play(AssetSource('audio/iqama.mp3'));
      return true;
    } catch (_) {
      _isPlaying = false;
      _appInitiatedStop = false;
      return false;
    }
  }

  Future<void> stop() async {
    _appInitiatedStop = true;
    try {
      await _player.stop();
      _isPlaying = false;
    } catch (_) {}
    _appInitiatedStop = false;
  }

  // ── Quran background player (streams from mp3quran.net CDN) ─────────────
  final AudioPlayer _quranPlayer = AudioPlayer();
  String _quranServerUrl = '';
  int _quranSurahIndex = 0; // 0-based index (surah 1 = index 0)
  DateTime? _quranPausedAt; // tracks when Quran was paused (Issue 7)

  int get quranSurahIndex => _quranSurahIndex;

  /// Start streaming Quran from the given CDN server URL.
  /// Begins at surah 1 and advances automatically after each surah completes.
  Future<void> playQuranFromServer(String serverUrl) async {
    _quranServerUrl = serverUrl;
    _quranSurahIndex = 0;
    await _quranPlayer.stop();
    await _playCurrentSurah();
  }

  Future<void> _playCurrentSurah() async {
    if (_quranServerUrl.isEmpty) return;
    try {
      final surahNum = (_quranSurahIndex + 1).toString().padLeft(3, '0');
      final url = '$_quranServerUrl$surahNum.mp3';
      await _quranPlayer.setReleaseMode(ReleaseMode.release);
      await _quranPlayer.play(UrlSource(url));
    } catch (_) {}
  }

  /// Pause Quran (called automatically when adhan fires).
  Future<void> pauseQuranPlayer() async {
    _quranPausedAt = DateTime.now(); // record pause time for Issue 7 check
    try {
      await _quranPlayer.pause();
    } catch (_) {}
  }

  /// Resume or restart Quran after iqama ends (Issue 7).
  /// If paused for more than 60 seconds the HTTP stream will have timed out,
  /// so we restart from the current surah instead of resuming a dead buffer.
  Future<void> resumeOrRestartQuranPlayer(String serverUrl) async {
    final pausedAt = _quranPausedAt;
    _quranPausedAt = null;
    final longPause = pausedAt != null &&
        DateTime.now().difference(pausedAt).inSeconds > 60;
    if (longPause) {
      // Restart stream from current surah position
      _quranServerUrl = serverUrl;
      await _quranPlayer.stop();
      await _playCurrentSurah();
    } else {
      try {
        await _quranPlayer.resume();
      } catch (_) {}
    }
  }

  /// Resume Quran (called automatically after iqama ends).
  /// Prefer [resumeOrRestartQuranPlayer] for the adhan/iqama cycle.
  Future<void> resumeQuranPlayer() async {
    try {
      await _quranPlayer.resume();
    } catch (_) {}
  }

  /// Fully stop Quran (user pressed the stop button).
  Future<void> stopQuranPlayer() async {
    try {
      _quranServerUrl = '';
      _quranSurahIndex = 0;
      await _quranPlayer.stop();
    } catch (_) {}
  }

  void dispose() {
    _onCompleteController.close();
    _player.dispose();
    _quranPlayer.dispose();
  }
}
