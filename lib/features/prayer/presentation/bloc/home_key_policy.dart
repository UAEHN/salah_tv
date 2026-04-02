enum HomeRemoteKey {
  mediaPlayPause,
  mediaPlay,
  mediaPause,
  arrowDown,
  select,
  enter,
  contextMenu,
  other,
}

enum HomeKeyIntent {
  ignored,
  toggleQuran,
  focusQuran,
  stopAdhan,
  stopDua,
  stopIqama,
  openSettings,
}

class HomeKeyInput {
  final HomeRemoteKey key;
  final bool isAdhanPlaying;
  final bool isDuaPlaying;
  final bool isIqamaPlaying;
  final bool isIqamaCountdown;
  final bool isQuranEnabled;
  final bool hasQuranReciter;

  const HomeKeyInput({
    required this.key,
    required this.isAdhanPlaying,
    required this.isDuaPlaying,
    required this.isIqamaPlaying,
    required this.isIqamaCountdown,
    required this.isQuranEnabled,
    required this.hasQuranReciter,
  });

  bool get isCycleMediaLocked =>
      isAdhanPlaying || isDuaPlaying || isIqamaPlaying;
}

HomeKeyIntent decideHomeKeyIntent(HomeKeyInput input) {
  final isMediaKey =
      input.key == HomeRemoteKey.mediaPlayPause ||
      input.key == HomeRemoteKey.mediaPlay ||
      input.key == HomeRemoteKey.mediaPause;

  if (isMediaKey) {
    return input.isCycleMediaLocked
        ? HomeKeyIntent.ignored
        : HomeKeyIntent.toggleQuran;
  }

  if (input.key == HomeRemoteKey.arrowDown &&
      input.isQuranEnabled &&
      input.hasQuranReciter &&
      !input.isIqamaCountdown &&
      !input.isCycleMediaLocked) {
    return HomeKeyIntent.focusQuran;
  }

  final isSelectKey =
      input.key == HomeRemoteKey.select ||
      input.key == HomeRemoteKey.enter ||
      input.key == HomeRemoteKey.contextMenu;

  if (!isSelectKey) return HomeKeyIntent.ignored;

  if (input.isAdhanPlaying) return HomeKeyIntent.stopAdhan;
  if (input.isDuaPlaying) return HomeKeyIntent.stopDua;
  if (input.isIqamaPlaying) return HomeKeyIntent.stopIqama;
  return HomeKeyIntent.openSettings;
}
