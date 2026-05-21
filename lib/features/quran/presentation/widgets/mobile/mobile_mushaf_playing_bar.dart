import 'package:flutter/material.dart';
import 'package:ghasaq/l10n/app_localizations.dart';
import '../../../../../core/mobile_theme.dart';
import '../../../../../core/surahs_data.dart';
import '../../../domain/entities/reading_theme.dart';
import '../../bloc/mushaf_reader_state.dart';
import 'mushaf_arabic_digits.dart';

/// Bottom strip that appears while an ayah is loading / playing / paused.
/// Tap the leading button to toggle pause / resume, stop button to fully
/// halt playback.
class MobileMushafPlayingBar extends StatelessWidget {
  final MushafReaderState state;
  final VoidCallback onTogglePauseResume;
  final VoidCallback onStop;

  const MobileMushafPlayingBar({
    super.key,
    required this.state,
    required this.onTogglePauseResume,
    required this.onStop,
  });

  @override
  Widget build(BuildContext context) {
    if (!state.isAudioActive) return const SizedBox.shrink();
    final surah = state.playingSurah;
    final ayah = state.playingAyah;
    if (surah == null || ayah == null) return const SizedBox.shrink();
    final name = surahNameForContext(context, surah);
    final palette = ReadingPalette.of(state.readingTheme);
    final status = state.audioStatus;
    final l = AppLocalizations.of(context);

    return SafeArea(
      top: false,
      child: Container(
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: palette.pageBg,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: palette.marker.withValues(alpha: 0.55)),
        ),
        child: Row(
          children: [
            _LeadingIcon(status: status, palette: palette),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                _labelFor(l: l, status: status, surah: name, ayah: ayah),
                style: MobileTextStyles.bodyMd(context).copyWith(
                  color: palette.text.withValues(alpha: 0.9),
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (state.continuousPlayback)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Icon(
                  Icons.repeat_on_rounded,
                  size: 18,
                  color: palette.marker,
                ),
              ),
            IconButton(
              icon: Icon(
                status == MushafAudioStatus.paused
                    ? Icons.play_arrow_rounded
                    : Icons.pause_rounded,
                color: palette.text,
              ),
              tooltip: status == MushafAudioStatus.paused
                  ? l.mushafResumeAudio
                  : l.mushafPauseAudio,
              onPressed: status == MushafAudioStatus.loading
                  ? null
                  : onTogglePauseResume,
            ),
            IconButton(
              icon: Icon(Icons.stop_rounded, color: palette.text),
              tooltip: l.mushafStopAudio,
              onPressed: onStop,
            ),
          ],
        ),
      ),
    );
  }

  String _labelFor({
    required AppLocalizations l,
    required MushafAudioStatus status,
    required String surah,
    required int ayah,
  }) {
    final ayahLabel = toArabicIndic(ayah);
    final suffix = '$surah • ${l.mushafAyahWord} $ayahLabel';
    return switch (status) {
      MushafAudioStatus.loading => '${l.mushafLoadingPrefix}: $suffix',
      MushafAudioStatus.paused => '${l.mushafPausedPrefix}: $suffix',
      _ => '${l.mushafPlayingPrefix}: $suffix',
    };
  }
}

class _LeadingIcon extends StatelessWidget {
  final MushafAudioStatus status;
  final ReadingPalette palette;
  const _LeadingIcon({required this.status, required this.palette});

  @override
  Widget build(BuildContext context) {
    if (status == MushafAudioStatus.loading) {
      return SizedBox(
        width: 22,
        height: 22,
        child: CircularProgressIndicator(strokeWidth: 2, color: palette.marker),
      );
    }
    return Icon(
      status == MushafAudioStatus.paused
          ? Icons.pause_circle_outline_rounded
          : Icons.graphic_eq_rounded,
      color: palette.marker,
    );
  }
}
