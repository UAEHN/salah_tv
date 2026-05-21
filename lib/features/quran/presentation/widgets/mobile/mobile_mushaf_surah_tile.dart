import 'package:flutter/material.dart';
import '../../../../../core/mobile_theme.dart';
import '../../../../../core/surahs_data.dart';
import 'mushaf_arabic_digits.dart';

/// One row in the surah index.
///
/// Layout (visual order, RTL locale):
///   [ diamond № ]  surah name  ............................  ‹
/// The diamond medallion is the FIRST child of the Row so RTL renders it
/// at the leading (right) edge. The surah name is right-aligned via
/// `TextAlign.start` so it sits flush against the medallion instead of
/// drifting toward the chevron in the middle of the row.
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
    final primary = Theme.of(context).colorScheme.primary;
    final isDark = MobileColors.isDark(context);
    final localeCode = Localizations.localeOf(context).languageCode;
    final name = surahNameForContext(context, number);
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 6),
          child: Row(
            children: [
              _NumberMedallion(number: number, primary: primary, isDark: isDark),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  name,
                  textAlign: TextAlign.start,
                  style: TextStyle(
                    fontFamily: localeCode == 'ar' ? 'AmiriQuran' : null,
                    fontSize: localeCode == 'ar' ? 24 : 18,
                    fontWeight: FontWeight.w600,
                    height: 1.2,
                    color: MobileColors.onSurface(context),
                  ),
                ),
              ),
              Icon(
                Icons.chevron_left_rounded,
                color: MobileColors.onSurfaceFaint(context),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NumberMedallion extends StatelessWidget {
  final int number;
  final Color primary;
  final bool isDark;
  const _NumberMedallion({
    required this.number,
    required this.primary,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    // Rotated square (diamond) with the surah number inside — a nod to
    // the ornate surah-number medallions used in printed Mushafs.
    return SizedBox(
      width: 44,
      height: 44,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Transform.rotate(
            angle: 0.785398, // 45° in radians
            child: Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: primary.withValues(alpha: isDark ? 0.18 : 0.12),
                border: Border.all(
                  color: primary.withValues(alpha: 0.55),
                  width: 1.2,
                ),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
          Text(
            digitsForLocale(context, number),
            style: TextStyle(
              color: primary,
              fontWeight: FontWeight.w800,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}
