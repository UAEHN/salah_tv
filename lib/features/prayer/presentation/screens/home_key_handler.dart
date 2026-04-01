import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../settings/domain/entities/app_settings.dart';
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
  final key = event.logicalKey;

  if (key == LogicalKeyboardKey.mediaPlayPause ||
      key == LogicalKeyboardKey.mediaPlay ||
      key == LogicalKeyboardKey.mediaPause) {
    if (!isAdhanPlaying && !isDuaPlaying && !isIqamaPlaying) {
      context.read<PrayerBloc>().add(
        PrayerQuranToggled(settings.quranReciterServerUrl),
      );
    }
    return KeyEventResult.handled;
  }

  if (key == LogicalKeyboardKey.arrowDown &&
      settings.isQuranEnabled &&
      settings.hasQuranReciter &&
      !isIqamaCountdown &&
      !isAdhanPlaying &&
      !isDuaPlaying &&
      !isIqamaPlaying) {
    quranFocusNode.requestFocus();
    return KeyEventResult.handled;
  }

  if (key == LogicalKeyboardKey.select ||
      key == LogicalKeyboardKey.enter ||
      key == LogicalKeyboardKey.contextMenu) {
    if (isAdhanPlaying) {
      context.read<PrayerBloc>().add(const PrayerAdhanStopped());
    } else if (isDuaPlaying) {
      context.read<PrayerBloc>().add(const PrayerDuaStopped());
    } else if (isIqamaPlaying) {
      context.read<PrayerBloc>().add(const PrayerIqamaStopped());
    } else {
      Navigator.pushNamed(context, '/settings');
    }
    return KeyEventResult.handled;
  }

  return KeyEventResult.ignored;
}
