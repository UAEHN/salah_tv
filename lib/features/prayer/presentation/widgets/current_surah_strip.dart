import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/app_colors.dart';
import '../bloc/prayer_bloc.dart';
import 'quran_now_playing_card.dart';

/// Coordinator shown beneath [HomeQuranButton] on the home screen.
/// Hidden when no surah is playing or when the prayer cycle is active.
class CurrentSurahStrip extends StatelessWidget {
  final AccentPalette palette;
  const CurrentSurahStrip({required this.palette, super.key});

  @override
  Widget build(BuildContext context) {
    final flags = context.select<PrayerBloc, (bool, bool)>(
      (b) => (b.state.isQuranPlaying, b.state.isCycleActive),
    );
    if (!flags.$1 || flags.$2) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(top: 10),
      child: QuranNowPlayingCard(palette: palette),
    );
  }
}
