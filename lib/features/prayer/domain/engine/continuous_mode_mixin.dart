import 'dart:math';

import '../../../quran/domain/entities/quran_playback_mode.dart';
import 'prayer_cycle_base.dart';

/// Computes start surah and next-surah resolver for [QuranPlaybackMode.continuous]
/// based on [settings.continuousStartMode]. Kept separate from [QuranMixin] to
/// honor the 150-line file limit while preserving Clean Architecture: pure logic
/// over [s], [settings], [audio] — no UI or repository touches.
mixin ContinuousModeMixin on PrayerCycleBase {
  static final Random _rng = Random();

  void startContinuousMode(String serverUrl) {
    final startSurah = _resolveStart();
    audio.setQuranNextSurahResolver(
      settings.continuousStartMode == ContinuousStartMode.random
          ? _randomResolver
          : null,
    );
    audio.playQuranSurah(serverUrl, startSurah);
  }

  int _resolveStart() {
    switch (settings.continuousStartMode) {
      case ContinuousStartMode.resume:
        final last = settings.lastPlayedSurah;
        return (last >= 1 && last <= 114) ? last : 1;
      case ContinuousStartMode.fromStart:
        return 1; // every session begins at Al-Fatiha
      case ContinuousStartMode.random:
        return _rng.nextInt(114) + 1;
    }
  }

  int? _randomResolver(int finishedSurah) {
    int next;
    do {
      next = _rng.nextInt(114) + 1;
    } while (next == finishedSurah);
    return next;
  }
}
