import 'package:audioplayers/audioplayers.dart';

class AudioService {
  static final AudioService _instance = AudioService._internal();
  factory AudioService() => _instance;

  AudioService._internal() {
    // When a surah finishes, advance to the next (1→2→…→114→1)
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

  Stream<void> get onComplete => _player.onPlayerComplete;

  Future<void> playAdhan() async {
    try {
      await _player.stop();
      _isPlaying = true;
      await _player.play(AssetSource('audio/adhan.mp3'));
    } catch (_) {
      _isPlaying = false;
    }
  }

  Future<void> playDua() async {
    try {
      await _player.stop();
      _isPlaying = true;
      await _player.play(AssetSource('audio/dua.mp3'));
    } catch (_) {
      _isPlaying = false;
    }
  }

  Future<void> playIqama() async {
    try {
      await _player.stop();
      _isPlaying = true;
      await _player.play(AssetSource('audio/iqama.mp3'));
    } catch (_) {
      _isPlaying = false;
    }
  }

  Future<void> stop() async {
    try {
      await _player.stop();
      _isPlaying = false;
    } catch (_) {}
  }

  // ── Quran background player (streams from mp3quran.net CDN) ─────────────
  final AudioPlayer _quranPlayer = AudioPlayer();
  String _quranServerUrl = '';
  int _quranSurahIndex = 0; // 0-based index (surah 1 = index 0)

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
    try {
      await _quranPlayer.pause();
    } catch (_) {}
  }

  /// Resume Quran (called automatically after iqama ends).
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
    _player.dispose();
    _quranPlayer.dispose();
  }
}
