import 'package:flutter/material.dart';
import 'package:ghasaq/l10n/app_localizations.dart';

import '../../../../../core/mobile_theme.dart';
import '../../../domain/entities/daily_verse.dart';
import '../../logic/surah_label_resolver.dart';

/// Bottom sheet shown on long-press of the verse tile.
/// Renders the full Arabic text without bento truncation, plus the surah
/// reference and a close affordance.
Future<void> showVerseDetailsSheet(
  BuildContext context,
  DailyVerse verse,
) {
  return showModalBottomSheet<void>(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (_) => _VerseSheet(verse: verse),
  );
}

class _VerseSheet extends StatelessWidget {
  final DailyVerse verse;

  const _VerseSheet({required this.verse});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final accent = MobileColors.activePrimary(context);
    final surah = resolveSurahLabel(
      l,
      verse.surahLabelKey,
      surahNumber: verse.surahNumber,
    );

    return DraggableScrollableSheet(
      initialChildSize: 0.5,
      minChildSize: 0.3,
      maxChildSize: 0.85,
      expand: false,
      builder: (_, controller) => Container(
        decoration: BoxDecoration(
          color: MobileColors.cardColor(context),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        ),
        padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
        child: ListView(
          controller: controller,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: MobileColors.onSurfaceMuted(
                    context,
                  ).withValues(alpha: 0.25),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              l.todayVerseSectionLabel.toUpperCase(),
              style: MobileTextStyles.labelSm(context).copyWith(
                fontSize: 11,
                letterSpacing: 1.6,
                color: accent,
                fontWeight: FontWeight.w800,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            Directionality(
              textDirection: TextDirection.rtl,
              child: Text(
                verse.textAr,
                style: TextStyle(
                  fontFamily:
                      Theme.of(context).textTheme.bodyMedium?.fontFamily,
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: MobileColors.onSurface(context),
                  height: 2.1,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 24),
            Center(
              child: Text(
                '$surah${l.todayMetaDot}${verse.ayahNumber}',
                style: MobileTextStyles.labelSm(context).copyWith(
                  color: accent,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.6,
                  fontSize: 13,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
