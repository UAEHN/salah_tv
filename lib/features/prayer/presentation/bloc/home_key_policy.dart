enum HomeRemoteKey {
  mediaPlayPause,
  mediaPlay,
  mediaPause,
  arrowDown,
  arrowUp,
  arrowLeft,
  arrowRight,
  select,
  enter,
  contextMenu,
  other,
}

enum HomeKeyIntent {
  ignored,
  toggleQuran,
  focusQuran,
  focusTakbeerat,
  stopAdhan,
  stopDua,
  stopIqama,
  skipAfterPrayerAdhkar,
  skipSessionAdhkar,
  openSettings,
}

class HomeKeyInput {
  final HomeRemoteKey key;
  final bool isAdhanPlaying;
  final bool isDuaPlaying;
  final bool isIqamaPlaying;
  final bool isIqamaCountdown;

  /// True while the after-prayer / morning-evening adhkar takeover is on screen,
  /// so the select key skips it instead of opening settings.
  final bool isAfterPrayerAdhkar;
  final bool isSessionAdhkar;
  final bool isQuranEnabled;
  final bool hasQuranReciter;

  /// True when the Eid Takbeerat home card is visible AND a reciter URL
  /// is available — i.e. the toggle is actionable right now.
  final bool canToggleTakbeerat;

  const HomeKeyInput({
    required this.key,
    required this.isAdhanPlaying,
    required this.isDuaPlaying,
    required this.isIqamaPlaying,
    required this.isIqamaCountdown,
    required this.isAfterPrayerAdhkar,
    required this.isSessionAdhkar,
    required this.isQuranEnabled,
    required this.hasQuranReciter,
    required this.canToggleTakbeerat,
  });

  bool get isCycleMediaLocked =>
      isAdhanPlaying || isDuaPlaying || isIqamaPlaying;
}

HomeKeyIntent decideHomeKeyIntent(HomeKeyInput input) {
  final isMediaKey =
      input.key == HomeRemoteKey.mediaPlayPause ||
      input.key == HomeRemoteKey.mediaPlay ||
      input.key == HomeRemoteKey.mediaPause;

  final isSelectKey =
      input.key == HomeRemoteKey.select ||
      input.key == HomeRemoteKey.enter ||
      input.key == HomeRemoteKey.contextMenu;

  // Adhkar takeover on screen: select / media keys skip it; every other key is
  // swallowed so a stray press never toggles Quran or opens settings behind it.
  if (input.isAfterPrayerAdhkar || input.isSessionAdhkar) {
    if (isSelectKey || isMediaKey) {
      return input.isAfterPrayerAdhkar
          ? HomeKeyIntent.skipAfterPrayerAdhkar
          : HomeKeyIntent.skipSessionAdhkar;
    }
    return HomeKeyIntent.ignored;
  }

  if (isMediaKey) {
    return input.isCycleMediaLocked
        ? HomeKeyIntent.ignored
        : HomeKeyIntent.toggleQuran;
  }

  // Arrow Down / Right enter the audio toggles. Quran takes precedence;
  // Takbeerat picks up the key when Quran is off so the pill remains
  // reachable via D-pad. Right is added because in the RTL UI users
  // intuitively try the horizontal direction too. Left is reserved for
  // escaping out of the buttons (handled by the button widgets themselves).
  final isFocusEntryKey =
      input.key == HomeRemoteKey.arrowDown ||
      input.key == HomeRemoteKey.arrowRight;
  if (isFocusEntryKey && !input.isCycleMediaLocked && !input.isIqamaCountdown) {
    if (input.isQuranEnabled && input.hasQuranReciter) {
      return HomeKeyIntent.focusQuran;
    }
    if (input.canToggleTakbeerat) {
      return HomeKeyIntent.focusTakbeerat;
    }
  }

  if (!isSelectKey) return HomeKeyIntent.ignored;

  if (input.isAdhanPlaying) return HomeKeyIntent.stopAdhan;
  if (input.isDuaPlaying) return HomeKeyIntent.stopDua;
  if (input.isIqamaPlaying) return HomeKeyIntent.stopIqama;
  return HomeKeyIntent.openSettings;
}
