import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ghasaq/l10n/app_localizations.dart';

import '../../../../../core/mobile_theme.dart';
import '../../../../../core/surahs_data.dart';
import '../../../../../core/widgets/mobile/mobile_shell.dart';
import '../../../../quran/domain/entities/quran_bookmark.dart';
import '../../../../quran/presentation/bloc/mushaf_reader_cubit.dart';
import '../../../../quran/presentation/widgets/mobile/mushaf_arabic_digits.dart';
import 'bento_tile.dart';

/// «متابعة القراءة» shortcut shown on the Today screen.
///
/// Reads the bookmark from the hoisted `MushafReaderCubit` (see CLAUDE.md
/// §8 accepted cross-feature widget-tree access) and pushes the reader
/// via [MobileShell.openMushafReader]. Renders nothing when no bookmark
/// is saved yet so the Today canvas stays uncluttered for new users.
class BentoMushafContinueTile extends StatelessWidget {
  const BentoMushafContinueTile({super.key});

  @override
  Widget build(BuildContext context) {
    final bookmark = context.select<MushafReaderCubit, QuranBookmark?>(
      (c) => c.state.bookmark,
    );
    if (bookmark == null) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: _ContinueCard(bookmark: bookmark),
    );
  }
}

class _ContinueCard extends StatelessWidget {
  final QuranBookmark bookmark;
  const _ContinueCard({required this.bookmark});

  @override
  Widget build(BuildContext context) {
    final accent = MobileColors.activePrimary(context);
    final surface = BentoSurface.of(context);
    final l = AppLocalizations.of(context);
    final surahName = surahNameForContext(context, bookmark.surahNumber);
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => MobileShell.openMushafReader(context),
      child: BentoTile(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        radius: 22,
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: accent.withValues(alpha: 0.16),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.menu_book_rounded, color: accent, size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l.mushafContinueReading,
                    style: MobileTextStyles.headlineMd(context).copyWith(
                      color: surface.foreground,
                      fontWeight: FontWeight.w800,
                    ),
                    textAlign: TextAlign.start,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${l.mushafSurahPrefix} $surahName • ${l.mushafAyahWord} ${toArabicIndic(bookmark.ayahNumber)}',
                    style: MobileTextStyles.bodyMd(context).copyWith(
                      color: surface.foregroundMuted,
                    ),
                    textAlign: TextAlign.start,
                  ),
                ],
              ),
            ),
            _PageBadge(page: bookmark.page, accent: accent),
          ],
        ),
      ),
    );
  }
}

class _PageBadge extends StatelessWidget {
  final int page;
  final Color accent;
  const _PageBadge({required this.page, required this.accent});

  @override
  Widget build(BuildContext context) {
    final surface = BentoSurface.of(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          AppLocalizations.of(context).mushafPageWord,
          style: MobileTextStyles.labelSm(context).copyWith(
            fontSize: 10,
            color: surface.foregroundMuted,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          toArabicIndic(page),
          style: TextStyle(
            fontFamily: 'AmiriQuran',
            fontSize: 22,
            fontWeight: FontWeight.w700,
            color: accent,
            height: 1.0,
          ),
        ),
      ],
    );
  }
}
