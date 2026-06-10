import 'package:flutter/material.dart';
import 'package:ghasaq/l10n/app_localizations.dart';

import '../../../../../core/mobile_theme.dart';
import '../../../domain/entities/daily_verse.dart';
import '../../logic/surah_label_resolver.dart';
import '../sheets/verse_details_sheet.dart';
import 'bento_tile.dart';

/// Full-width verse-of-the-day tile.
///
/// Uses the bento's vertical real estate generously — the eyebrow sits at
/// the top, the verse occupies the centre at a comfortable 22px (centered
/// horizontally and vertically), and the surah reference closes the block
/// with subtle metadata. Long-press still opens the details sheet.
class BentoVerseTile extends StatelessWidget {
  final DailyVerse verse;

  const BentoVerseTile({super.key, required this.verse});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final accent = MobileColors.activePrimary(context);
    final surface = BentoSurface.of(context);
    final surah = resolveSurahLabel(
      l,
      verse.surahLabelKey,
      surahNumber: verse.surahNumber,
    );

    return GestureDetector(
      onLongPress: () => showVerseDetailsSheet(context, verse),
      child: BentoTile(
        padding: const EdgeInsets.fromLTRB(18, 14, 18, 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _Eyebrow(
              label: l.todayVerseSectionLabel,
              accent: accent,
              mutedColor: surface.foregroundMuted,
            ),
            const SizedBox(height: 12),
            Directionality(
              textDirection: TextDirection.rtl,
              child: Text(
                verse.textAr,
                style: TextStyle(
                  fontFamily: 'AmiriQuran',
                  fontSize: 22,
                  fontWeight: FontWeight.w400,
                  color: surface.foreground,
                  height: 2.1,
                ),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 12),
            Center(
              child: Text(
                '$surah${l.todayMetaDot}${verse.ayahNumber}',
                style: MobileTextStyles.labelSm(context).copyWith(
                  fontSize: 13,
                  color: accent,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.4,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Eyebrow extends StatelessWidget {
  final String label;
  final Color accent;
  final Color mutedColor;

  const _Eyebrow({
    required this.label,
    required this.accent,
    required this.mutedColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 4,
          height: 12,
          decoration: BoxDecoration(
            color: accent,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label.toUpperCase(),
          style: MobileTextStyles.labelSm(context).copyWith(
            fontSize: 11,
            color: mutedColor,
            letterSpacing: 1.8,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }
}
