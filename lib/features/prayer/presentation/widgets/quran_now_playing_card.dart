import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';

import '../../../../core/app_colors.dart';
import '../../../../core/surahs_data.dart';
import '../../../settings/presentation/settings_provider.dart';
import '../bloc/prayer_bloc.dart';
import 'quran_card_pieces.dart';

/// Single rectangle that shows the current surah and reciter. Sized to its
/// content via [IntrinsicWidth] so a long reciter name doesn't stretch the row.
/// Returns shrink when no surah is playing or the prayer cycle is active.
class QuranNowPlayingCard extends StatelessWidget {
  final AccentPalette palette;
  const QuranNowPlayingCard({required this.palette, super.key});

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>().settings;
    final tc = ThemeColors.of(settings.isDarkMode);
    final flags = context.select<PrayerBloc, (int?, bool, bool)>(
      (b) => (
        b.state.currentSurahNumber,
        b.state.isQuranPlaying,
        b.state.isCycleActive,
      ),
    );
    final surahNum = flags.$1;
    if (!flags.$2 || flags.$3 || surahNum == null)
      return const SizedBox.shrink();
    final surah = surahByNumber(surahNum);
    if (surah == null) return const SizedBox.shrink();

    return IntrinsicWidth(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: settings.isDarkMode
              ? Colors.white.withValues(alpha: 0.06)
              : Colors.black.withValues(alpha: 0.04),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: tc.borderGlass, width: 1),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            LiveDot(color: palette.primary),
            const SizedBox(width: 10),
            Text(
              surah.nameAr,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: tc.textPrimary,
                letterSpacing: 0.3,
              ),
            ),
            if (settings.quranReciterName.isNotEmpty) ...[
              const SizedBox(width: 8),
              Container(
                width: 4,
                height: 4,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: tc.textMuted.withValues(alpha: 0.6),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                settings.quranReciterName,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: tc.textSecondary,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
