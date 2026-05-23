import 'package:flutter/material.dart';
import 'package:ghasaq/l10n/app_localizations.dart';
import 'package:quran/quran.dart' as quran;

import '../../../../../core/mobile_theme.dart';
import '../../../../../core/surahs_data.dart';
import '../../../domain/entities/reading_theme.dart';
import 'mushaf_arabic_digits.dart';

/// Per-page header. Direct port of Skoon's `QuranPageHeader` style — a
/// thin Row at the top of every page with back / actions / page-info.
/// Sitting INSIDE the page item means a swipe never rebuilds a global
/// AppBar: each page carries its own header, so the screen Scaffold
/// has nothing that depends on the current page state.
class MobileMushafPageHeader extends StatelessWidget {
  final int pageNumber;
  final ReadingPalette palette;
  final VoidCallback onBack;
  final VoidCallback onOpenSurahIndex;
  final VoidCallback onOpenPageJump;
  final VoidCallback onSaveBookmark;
  final VoidCallback onSettings;
  final VoidCallback onShowIntro;

  const MobileMushafPageHeader({
    super.key,
    required this.pageNumber,
    required this.palette,
    required this.onBack,
    required this.onOpenSurahIndex,
    required this.onOpenPageJump,
    required this.onSaveBookmark,
    required this.onSettings,
    required this.onShowIntro,
  });

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final juz = quran.getJuzNumber(_firstSurah(), 1);
    final surahName = surahNameForContext(context, _firstSurah());
    return Container(
      color: palette.pageBg,
      padding: const EdgeInsets.fromLTRB(4, 4, 4, 0),
      child: Column(
        children: [
          Row(
            children: [
              IconButton(
                icon: Icon(Icons.arrow_back_rounded, color: palette.appBarFg),
                tooltip: l.mushafBack,
                onPressed: onBack,
              ),
              const Spacer(),
              IconButton(
                icon: Icon(Icons.list_rounded, color: palette.appBarFg),
                tooltip: l.mushafSurahIndex,
                onPressed: onOpenSurahIndex,
              ),
              IconButton(
                icon: Icon(Icons.find_in_page_rounded, color: palette.appBarFg),
                tooltip: l.mushafJumpToPage,
                onPressed: onOpenPageJump,
              ),
              IconButton(
                icon:
                    Icon(Icons.bookmark_add_rounded, color: palette.appBarFg),
                tooltip: l.mushafSaveHere,
                onPressed: onSaveBookmark,
              ),
              IconButton(
                icon: Icon(Icons.tune_rounded, color: palette.appBarFg),
                tooltip: l.mushafReadingSettings,
                onPressed: onSettings,
              ),
              IconButton(
                icon: Icon(Icons.help_outline_rounded, color: palette.appBarFg),
                tooltip: l.mushafIntroHelp,
                onPressed: onShowIntro,
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 2),
            child: Text(
              '${l.mushafPageWord} ${digitsForLocale(context, pageNumber)}  •  ${l.mushafJuzWord} ${digitsForLocale(context, juz)}  •  $surahName',
              textAlign: TextAlign.center,
              style: MobileTextStyles.labelSm(context).copyWith(
                fontSize: 13,
                color: palette.appBarFg.withValues(alpha: 0.9),
                fontWeight: FontWeight.w600,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  int _firstSurah() {
    final data = quran.getPageData(pageNumber);
    if (data.isEmpty) return 1;
    return data.first['surah'] as int;
  }
}
