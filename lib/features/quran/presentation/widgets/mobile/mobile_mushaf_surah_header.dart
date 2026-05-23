import 'package:flutter/material.dart';

import '../../../../../core/surahs_data.dart';
import '../../../domain/entities/reading_theme.dart';
import 'surah_name_glyph.dart';

/// Decorative surah-frame banner — geometry matches Skoon's `HeaderWidget`
/// exactly: fixed height 50 (× sp), the decorative PNG fills the slot at
/// screen width, with three overlay texts (verse count, surah number in
/// the calligraphic `Arsura` font, surah order). Padding and per-text
/// font sizes mirror the reference (`19.7.w × 10.h`, `25.sp` for the
/// number, `5.sp` for the side labels).
class MobileMushafSurahHeader extends StatelessWidget {
  final int surahNumber;
  final double glyphSize;
  final ReadingPalette palette;

  const MobileMushafSurahHeader({
    super.key,
    required this.surahNumber,
    required this.glyphSize,
    required this.palette,
  });

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    final sp = w / 392.72;
    final ayahCount = (surahNumber >= 1 && surahNumber <= kSurahs.length)
        ? kSurahs[surahNumber - 1].ayahCount
        : 0;
    final colored = palette.text.withValues(alpha: 0.92);
    final microStyle = TextStyle(
      color: colored,
      fontSize: 5 * sp,
      fontFamily: 'UthmanicHafs',
    );
    return SizedBox(
      height: 50 * sp,
      child: Stack(
        children: [
          Center(
            child: Image.asset(
              'assets/images/surah_frame_888.png',
              width: w,
              height: 50 * sp,
              color: null,
            ),
          ),
          Padding(
            padding:
                EdgeInsets.symmetric(horizontal: 19.7 * sp, vertical: 10 * sp),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Text('اياتها\n$ayahCount',
                    textAlign: TextAlign.center, style: microStyle),
                Text(
                  surahNameLigatureToken(surahNumber),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'SurahNames',
                    fontSize: 28 * sp,
                    color: colored,
                    height: 1.0,
                    fontFeatures: const [FontFeature.enable('liga')],
                  ),
                ),
                Text('ترتيبها\n$surahNumber',
                    textAlign: TextAlign.center, style: microStyle),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
