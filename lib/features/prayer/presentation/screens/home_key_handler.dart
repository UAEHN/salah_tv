import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../settings/domain/entities/app_settings.dart';
import '../bloc/home_key_policy.dart';
import '../bloc/prayer_bloc.dart';
import '../bloc/prayer_event.dart';

/// TV remote key handler extracted from [HomeScreen] to keep it under 150 lines.
KeyEventResult handleHomeKey(
  KeyEvent event,
  BuildContext context,
  AppSettings settings, {
  required bool isAdhanPlaying,
  required bool isDuaPlaying,
  required bool isIqamaPlaying,
  required bool isIqamaCountdown,
  required FocusNode quranFocusNode,
}) {
  if (event is! KeyDownEvent) return KeyEventResult.ignored;
  final intent = decideHomeKeyIntent(
    HomeKeyInput(
      key: _mapLogicalKey(event.logicalKey),
      isAdhanPlaying: isAdhanPlaying,
      isDuaPlaying: isDuaPlaying,
      isIqamaPlaying: isIqamaPlaying,
      isIqamaCountdown: isIqamaCountdown,
      isQuranEnabled: settings.isQuranEnabled,
      hasQuranReciter: settings.hasQuranReciter,
    ),
  );

  switch (intent) {
    case HomeKeyIntent.toggleQuran:
      context.read<PrayerBloc>().add(
        PrayerQuranToggled(settings.quranReciterServerUrl),
      );
      return KeyEventResult.handled;
    case HomeKeyIntent.focusQuran:
      quranFocusNode.requestFocus();
      return KeyEventResult.handled;
    case HomeKeyIntent.stopAdhan:
      context.read<PrayerBloc>().add(const PrayerAdhanStopped());
      return KeyEventResult.handled;
    case HomeKeyIntent.stopDua:
      context.read<PrayerBloc>().add(const PrayerDuaStopped());
      return KeyEventResult.handled;
    case HomeKeyIntent.stopIqama:
      context.read<PrayerBloc>().add(const PrayerIqamaStopped());
      return KeyEventResult.handled;
    case HomeKeyIntent.openSettings:
      Navigator.pushNamed(context, '/settings');
      return KeyEventResult.handled;
    case HomeKeyIntent.ignored:
      return KeyEventResult.ignored;
  }
}

HomeRemoteKey _mapLogicalKey(LogicalKeyboardKey key) {
  if (key == LogicalKeyboardKey.mediaPlayPause) {
    return HomeRemoteKey.mediaPlayPause;
  }
  if (key == LogicalKeyboardKey.mediaPlay) return HomeRemoteKey.mediaPlay;
  if (key == LogicalKeyboardKey.mediaPause) return HomeRemoteKey.mediaPause;
  if (key == LogicalKeyboardKey.arrowDown) return HomeRemoteKey.arrowDown;
  if (key == LogicalKeyboardKey.select) return HomeRemoteKey.select;
  if (key == LogicalKeyboardKey.enter) return HomeRemoteKey.enter;
  if (key == LogicalKeyboardKey.contextMenu) return HomeRemoteKey.contextMenu;
  return HomeRemoteKey.other;
}
