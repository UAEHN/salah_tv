part of 'settings_provider.dart';

extension SettingsProviderQuran on SettingsProvider {
  Future<void> updateIsQuranEnabled(bool value) =>
      _update(_settings.copyWith(isQuranEnabled: value));

  Future<void> updateQuranReciter(String name, String serverUrl) => _update(
    _settings.copyWith(
      quranReciterName: name,
      quranReciterServerUrl: serverUrl,
    ),
  );

  /// Toggles a reciter's favorite state. New favorites are appended; existing
  /// ones are removed. Order is preserved so the picker can render them in
  /// the order the user starred them.
  Future<void> toggleFavoriteReciter(String serverUrl) {
    if (serverUrl.isEmpty) return Future.value();
    final current = _settings.favoriteReciterServerUrls;
    final next = current.contains(serverUrl)
        ? current.where((u) => u != serverUrl).toList(growable: false)
        : [...current, serverUrl];
    return _update(_settings.copyWith(favoriteReciterServerUrls: next));
  }

  Future<void> updateQuranPlaybackMode(QuranPlaybackMode mode) =>
      _update(_settings.copyWith(quranPlaybackMode: mode));

  Future<void> updateSelectedSurah(int? surahNumber) => _update(
    surahNumber == null
        ? _settings.copyWith(clearSelectedSurahNumber: true)
        : _settings.copyWith(selectedSurahNumber: surahNumber),
  );

  Future<void> updateSurahPlaylist(List<int> playlist) {
    final sorted = [...playlist]..sort();
    return _update(_settings.copyWith(surahPlaylist: sorted));
  }

  Future<void> updateSurahRepeatCount(int count) =>
      _update(_settings.copyWith(surahRepeatCount: count));

  Future<void> updatePlaylistCycleCount(int count) =>
      _update(_settings.copyWith(playlistCycleCount: count));

  Future<void> updateContinuousStartMode(ContinuousStartMode mode) =>
      _update(_settings.copyWith(continuousStartMode: mode));

  /// Auto-tracked. Persisted whenever the engine reports a surah change while
  /// in continuous mode, so the next session can resume from here.
  Future<void> updateLastPlayedSurah(int surahNumber) {
    if (surahNumber < 1 || surahNumber > 114) return Future.value();
    if (_settings.lastPlayedSurah == surahNumber) return Future.value();
    return _update(_settings.copyWith(lastPlayedSurah: surahNumber));
  }
}
