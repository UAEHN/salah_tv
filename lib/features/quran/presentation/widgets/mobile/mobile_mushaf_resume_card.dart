import 'package:flutter/material.dart';
import 'package:ghasaq/l10n/app_localizations.dart';
import '../../../../../core/mobile_theme.dart';
import '../../../../../core/surahs_data.dart';
import '../../../domain/entities/quran_bookmark.dart';
import 'mushaf_arabic_digits.dart';

/// Single "continue reading" card on the Mushaf landing screen.
/// Surfaces the user's saved bookmark and opens the reader on tap.
class MobileMushafResumeCard extends StatelessWidget {
  final QuranBookmark bookmark;
  final VoidCallback onTap;

  const MobileMushafResumeCard({
    super.key,
    required this.bookmark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    final isDark = MobileColors.isDark(context);
    final l = AppLocalizations.of(context);
    final surahName = surahNameForContext(context, bookmark.surahNumber);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(22),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.centerRight,
              end: Alignment.centerLeft,
              colors: [
                primary.withValues(alpha: isDark ? 0.22 : 0.16),
                primary.withValues(alpha: isDark ? 0.10 : 0.06),
              ],
            ),
            borderRadius: BorderRadius.circular(22),
            border: Border.all(
              color: primary.withValues(alpha: 0.42),
              width: 1.3,
            ),
          ),
          child: Row(
            children: [
              _Medallion(primary: primary, isDark: isDark),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l.mushafContinueReading,
                      style: MobileTextStyles.headlineMd(context),
                      textAlign: TextAlign.start,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${l.mushafSurahPrefix} $surahName • ${l.mushafAyahWord} ${toArabicIndic(bookmark.ayahNumber)}',
                      style: MobileTextStyles.bodyMd(context),
                      textAlign: TextAlign.start,
                    ),
                  ],
                ),
              ),
              _PageBadge(page: bookmark.page, primary: primary),
            ],
          ),
        ),
      ),
    );
  }
}

class _Medallion extends StatelessWidget {
  final Color primary;
  final bool isDark;
  const _Medallion({required this.primary, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 46,
      height: 46,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: primary.withValues(alpha: isDark ? 0.20 : 0.14),
        border: Border.all(color: primary.withValues(alpha: 0.35)),
      ),
      child: Icon(Icons.bookmark_rounded, color: primary, size: 22),
    );
  }
}

class _PageBadge extends StatelessWidget {
  final int page;
  final Color primary;
  const _PageBadge({required this.page, required this.primary});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          AppLocalizations.of(context).mushafPageWord,
          style: MobileTextStyles.labelSm(context).copyWith(fontSize: 10),
        ),
        const SizedBox(height: 2),
        Text(
          toArabicIndic(page),
          style: TextStyle(
            fontFamily: 'AmiriQuran',
            fontSize: 22,
            fontWeight: FontWeight.w700,
            color: primary,
            height: 1.0,
          ),
        ),
      ],
    );
  }
}
