import 'package:flutter/material.dart';
import 'package:ghasaq/l10n/app_localizations.dart';

import '../../../../../core/mobile_theme.dart';
import '../../../../../core/quran_juz_data.dart';
import 'mushaf_arabic_digits.dart';

/// One row in the juz index list (the toggle counterpart of
/// [MobileMushafSurahTile]).
/// Layout (RTL): [№]  ·  page label  ·  [ ornate opening phrase ]
class MobileMushafJuzTile extends StatelessWidget {
  final JuzInfo juz;
  final VoidCallback onTap;

  const MobileMushafJuzTile({
    super.key,
    required this.juz,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
          child: Row(
            children: [
              _NumberBadge(number: juz.number),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'الجزء ${digitsForLocale(context, juz.number)}',
                      style: MobileTextStyles.bodyMd(
                        context,
                      ).copyWith(fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${l.mushafPageWord} ${digitsForLocale(context, juz.firstPage)}',
                      style: TextStyle(
                        fontSize: 12,
                        color: MobileColors.onSurfaceMuted(context),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              SizedBox(
                width: 120,
                child: Text(
                  juz.openingPhrase,
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontFamily: 'AmiriQuran',
                    fontSize: 18,
                    height: 1.0,
                    color: MobileColors.onSurface(context),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
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
