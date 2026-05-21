import '../../domain/entities/mushaf_page.dart';
import '../../domain/entities/mushaf_preferences.dart';
import '../../domain/entities/quran_bookmark.dart';
import '../../domain/entities/reading_theme.dart';

enum MushafLoadStatus { idle, loading, ready, error }

enum MushafAudioStatus { idle, loading, playing, paused, error }

/// Single immutable snapshot driving the Mushaf reader UI.
class MushafReaderState {
  final MushafLoadStatus loadStatus;
  final String? loadError;

  /// 1-based page the user is currently on.
  final int currentPage;
  final MushafPage? currentPageData;

  final MushafAudioStatus audioStatus;
  final int? playingSurah;
  final int? playingAyah;

  /// Single bookmark slot — updated by both the manual save button and
  /// the automatic save on leaving the reader. The newer save wins.
  final QuranBookmark? bookmark;

  /// User-tunable reading preferences (theme + font size + continuous
  /// playback). Loaded from SharedPreferences on init.
  final MushafPreferences prefs;

  /// Whether the user has dismissed the welcome/feature-tour sheet at
  /// least once. Drives the one-time auto-show on first entry.
  final bool hasSeenIntro;

  const MushafReaderState({
    this.loadStatus = MushafLoadStatus.idle,
    this.loadError,
    this.currentPage = 1,
    this.currentPageData,
    this.audioStatus = MushafAudioStatus.idle,
    this.playingSurah,
    this.playingAyah,
    this.bookmark,
    this.prefs = const MushafPreferences(),
    this.hasSeenIntro = true,
  });

  bool get isAudioActive =>
      audioStatus == MushafAudioStatus.loading ||
      audioStatus == MushafAudioStatus.playing ||
      audioStatus == MushafAudioStatus.paused;

  bool isAyahPlaying(int surah, int ayah) =>
      audioStatus == MushafAudioStatus.playing &&
      playingSurah == surah &&
      playingAyah == ayah;

  bool isAyahPaused(int surah, int ayah) =>
      audioStatus == MushafAudioStatus.paused &&
      playingSurah == surah &&
      playingAyah == ayah;

  ReadingTheme get readingTheme => prefs.readingTheme;
  double get fontSize => prefs.fontSize;
  bool get continuousPlayback => prefs.continuousPlayback;

  MushafReaderState copyWith({
    MushafLoadStatus? loadStatus,
    String? loadError,
    int? currentPage,
    MushafPage? currentPageData,
    MushafAudioStatus? audioStatus,
    int? playingSurah,
    int? playingAyah,
    QuranBookmark? bookmark,
    MushafPreferences? prefs,
    bool? hasSeenIntro,
    bool clearPlaying = false,
  }) {
    return MushafReaderState(
      loadStatus: loadStatus ?? this.loadStatus,
      loadError: loadError ?? this.loadError,
      currentPage: currentPage ?? this.currentPage,
      currentPageData: currentPageData ?? this.currentPageData,
      audioStatus: audioStatus ?? this.audioStatus,
      playingSurah: clearPlaying ? null : (playingSurah ?? this.playingSurah),
      playingAyah: clearPlaying ? null : (playingAyah ?? this.playingAyah),
      bookmark: bookmark ?? this.bookmark,
      prefs: prefs ?? this.prefs,
      hasSeenIntro: hasSeenIntro ?? this.hasSeenIntro,
    );
  }
}
