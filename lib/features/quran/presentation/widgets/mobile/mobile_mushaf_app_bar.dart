import 'package:flutter/material.dart';
import 'package:ghasaq/l10n/app_localizations.dart';
import '../../../../../core/mobile_theme.dart';
import '../../../../../core/surahs_data.dart';
import '../../../domain/entities/mushaf_page.dart';
import '../../../domain/entities/reading_theme.dart';
import 'mushaf_arabic_digits.dart';

/// Two-tier top bar of the reader:
///   row 1 — back + actions (save bookmark, surah index, settings).
///   row 2 — full-width slim strip showing "صفحة X • الجزء Y • السورة Z".
///
/// Splitting the page label into its own strip means it never gets
/// truncated when the AppBar's actions fill horizontally. The continuous
/// playback toggle moved to the settings sheet so the action row stays
/// short on narrow phones.
class MobileMushafAppBar extends StatelessWidget implements PreferredSizeWidget {
  final MushafPage? page;
  final ReadingTheme readingTheme;
  final VoidCallback onSaveBookmark;
  final VoidCallback onOpenSurahIndex;
  final VoidCallback onOpenPageJump;
  final VoidCallback onOpenSettings;
  final VoidCallback onShowIntro;
  final VoidCallback onBack;

  const MobileMushafAppBar({
    super.key,
    required this.page,
    required this.readingTheme,
    required this.onSaveBookmark,
    required this.onOpenSurahIndex,
    required this.onOpenPageJump,
    required this.onOpenSettings,
    required this.onShowIntro,
    required this.onBack,
  });

  @override
  Size get preferredSize => const Size.fromHeight(56 + 34);

  @override
  Widget build(BuildContext context) {
    final palette = ReadingPalette.of(readingTheme);
    final l = AppLocalizations.of(context);
    return AppBar(
      backgroundColor: Colors.transparent,
      foregroundColor: palette.appBarFg,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_rounded),
        onPressed: onBack,
        tooltip: l.mushafBack,
      ),
      title: const SizedBox.shrink(),
      actions: [
        IconButton(
          icon: const Icon(Icons.list_rounded),
          tooltip: l.mushafSurahIndex,
          onPressed: onOpenSurahIndex,
        ),
        IconButton(
          icon: const Icon(Icons.find_in_page_rounded),
          tooltip: l.mushafJumpToPage,
          onPressed: onOpenPageJump,
        ),
        IconButton(
          icon: const Icon(Icons.bookmark_add_rounded),
          tooltip: l.mushafSaveHere,
          onPressed: onSaveBookmark,
        ),
        IconButton(
          icon: const Icon(Icons.tune_rounded),
          tooltip: l.mushafReadingSettings,
          onPressed: onOpenSettings,
        ),
        IconButton(
          icon: const Icon(Icons.help_outline_rounded),
          tooltip: l.mushafIntroHelp,
          onPressed: onShowIntro,
        ),
      ],
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(34),
        child: _PageLabelStrip(page: page, palette: palette),
      ),
    );
  }
}

class _PageLabelStrip extends StatelessWidget {
  final MushafPage? page;
  final ReadingPalette palette;
  const _PageLabelStrip({required this.page, required this.palette});

  @override
  Widget build(BuildContext context) {
    final p = page;
    final l = AppLocalizations.of(context);
    final surahName = p != null && p.ayahs.isNotEmpty
        ? surahNameForContext(context, p.ayahs.first.surahNumber)
        : '';
    final label = p == null
        ? '...'
        : '${l.mushafPageWord} ${digitsForLocale(context, p.pageNumber)}  •  ${l.mushafJuzWord} ${digitsForLocale(context, p.juz)}  •  $surahName';

    return Container(
      width: double.infinity,
      alignment: Alignment.center,
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        label,
        textAlign: TextAlign.center,
        style: MobileTextStyles.labelSm(context).copyWith(
          fontSize: 13,
          color: palette.appBarFg.withValues(alpha: 0.9),
          fontWeight: FontWeight.w600,
        ),
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}
