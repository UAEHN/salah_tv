import 'package:flutter/material.dart';
import 'package:ghasaq/l10n/app_localizations.dart';

import '../../../../../core/mobile_theme.dart';
import '../../../../../core/surahs_data.dart';
import '../../../domain/entities/surah.dart';
import 'mushaf_arabic_digits.dart';
import 'surah_name_glyph.dart';

/// One row in the surah index, Mushaf-style.
/// Layout (RTL): [№]  ·  Makki/Madani · verses · page  ·  [ﮒ ornate name]
/// The ornate trailing glyph is the only surah name shown — the Latin
/// transliteration is dropped to keep the row clean and Mushaf-styled.
class MobileMushafSurahTile extends StatelessWidget {
  final int number;
  final VoidCallback onTap;

  const MobileMushafSurahTile({
    super.key,
    required this.number,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final surah = surahByNumber(number);
    if (surah == null) return const SizedBox.shrink();
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
          child: Row(
            children: [
              _NumberBadge(number: number),
              const SizedBox(width: 14),
              Expanded(child: _MetaColumn(surah: surah)),
              const SizedBox(width: 12),
              _CalligraphicName(number: number),
            ],
          ),
        ),
      ),
    );
  }
}

class _MetaColumn extends StatelessWidget {
  final Surah surah;
  const _MetaColumn({required this.surah});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final revelation = surah.revelation == RevelationType.makki
        ? l.surahRevelationMakki
        : l.surahRevelationMadani;
    final n = digitsForLocale(context, surah.ayahCount);
    final p = digitsForLocale(context, surah.firstPage);
    final subtitle =
        '$revelation  ·  ${l.surahAyahCountLabel} $n  ·  ${l.mushafPageWord} $p';
    return Text(
      subtitle,
      style: TextStyle(
        fontSize: 13,
        height: 1.3,
        color: MobileColors.onSurfaceMuted(context),
      ),
      // 2 lines + no ellipsis so long subtitles (e.g. صفحة ٦٠٠) wrap
      // instead of being truncated with "..."
      maxLines: 2,
      softWrap: true,
    );
  }
}

class _NumberBadge extends StatelessWidget {
  final int number;
  const _NumberBadge({required this.number});

  @override
  Widget build(BuildContext context) {
    final isDark = MobileColors.isDark(context);
    return Container(
      width: 42,
      height: 42,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withValues(alpha: 0.08)
            : Colors.black.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        digitsForLocale(context, number),
        style: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w700,
          color: MobileColors.onSurface(context),
        ),
      ),
    );
  }
}

class _CalligraphicName extends StatelessWidget {
  final int number;
  const _CalligraphicName({required this.number});

  @override
  Widget build(BuildContext context) {
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';
    final fg = MobileColors.onSurface(context);
    if (isArabic) {
      return SizedBox(
        width: 100,
        child: Text(
          surahNameLigatureToken(number),
          textAlign: TextAlign.center,
          style: TextStyle(
            fontFamily: 'SurahNames',
            fontSize: 38,
            height: 1.0,
            color: fg,
            fontFeatures: const [FontFeature.enable('liga')],
          ),
        ),
      );
    }
    final surah = surahByNumber(number);
    final name = surah?.nameEn ?? '';
    return SizedBox(
      width: 100,
      child: Text(
        name,
        textAlign: TextAlign.center,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          fontFamily: 'Cairo',
          fontWeight: FontWeight.w700,
          fontSize: 16,
          height: 1.15,
          color: fg,
        ),
      ),
    );
  }
}
