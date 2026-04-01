import 'package:flutter/material.dart';
import '../../../../../core/mobile_theme.dart';
import '../../../domain/entities/text_dhikr.dart';

/// Full-screen dhikr text content (no card frame).
class MobileDhikrReaderContent extends StatelessWidget {
  final TextDhikr dhikr;
  final bool isEnglish;

  const MobileDhikrReaderContent({
    super.key,
    required this.dhikr,
    required this.isEnglish,
  });

  @override
  Widget build(BuildContext context) {
    final color = MobileColors.onSurface(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          dhikr.text,
          style: TextStyle(
            fontFamily: 'Cairo',
            fontSize: 26,
            fontWeight: FontWeight.w600,
            color: color,
            height: 2.1,
          ),
          textAlign: TextAlign.center,
          textDirection: TextDirection.rtl,
        ),
        if (isEnglish && dhikr.transliteration.isNotEmpty) ...[
          const SizedBox(height: 16),
          Divider(color: MobileColors.primary.withValues(alpha: 0.15)),
          const SizedBox(height: 12),
          Text(
            dhikr.transliteration,
            style: TextStyle(
              fontFamily: 'Rubik',
              fontSize: 16,
              fontStyle: FontStyle.italic,
              color: color.withValues(alpha: 0.75),
              height: 1.7,
            ),
            textAlign: TextAlign.center,
          ),
        ],
        if (dhikr.virtue.isNotEmpty) ...[
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: MobileColors.primary.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  dhikr.virtue,
                  style: MobileTextStyles.labelSm(context).copyWith(
                    color: MobileColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.center,
                  textDirection: TextDirection.rtl,
                ),
                if (isEnglish && dhikr.virtueEn.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Text(
                    dhikr.virtueEn,
                    style: MobileTextStyles.labelSm(context).copyWith(
                      fontFamily: 'Rubik',
                      fontStyle: FontStyle.italic,
                      fontSize: 12,
                      color: MobileColors.primary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ],
            ),
          ),
        ],
        const SizedBox(height: 12),
        Text(
          dhikr.source,
          style: MobileTextStyles.labelSm(context),
          textAlign: TextAlign.center,
          textDirection: TextDirection.rtl,
        ),
        if (isEnglish && dhikr.sourceEn.isNotEmpty) ...[
          const SizedBox(height: 2),
          Text(
            dhikr.sourceEn,
            style: MobileTextStyles.labelSm(context).copyWith(
              fontFamily: 'Rubik',
              fontSize: 11,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ],
    );
  }
}
