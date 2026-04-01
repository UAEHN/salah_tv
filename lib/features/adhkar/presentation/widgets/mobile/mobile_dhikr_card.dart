import 'package:flutter/material.dart';
import '../../../../../core/mobile_theme.dart';
import '../../../domain/entities/text_dhikr.dart';

/// Displays the dhikr text, source, and virtue in a styled card.
/// When [isEnglish] is true, shows transliteration below the Arabic text
/// and English source/virtue alongside the Arabic ones.
class MobileDhikrCard extends StatelessWidget {
  final TextDhikr dhikr;
  final bool isEnglish;

  const MobileDhikrCard({
    super.key,
    required this.dhikr,
    this.isEnglish = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(24),
      decoration: MobileDecorations.pillCard(context),
      child: Column(
        mainAxisSize: MainAxisSize.max,
        children: [
          Expanded(
            child: Center(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: _TextBody(
                  dhikr: dhikr,
                  isEnglish: isEnglish,
                ),
              ),
            ),
          ),
          if (dhikr.virtue.isNotEmpty) ...[
            const SizedBox(height: 16),
            _VirtueBadge(dhikr: dhikr, isEnglish: isEnglish),
          ],
          const SizedBox(height: 12),
          _SourceLabel(dhikr: dhikr, isEnglish: isEnglish),
        ],
      ),
    );
  }
}

class _TextBody extends StatelessWidget {
  final TextDhikr dhikr;
  final bool isEnglish;

  const _TextBody({required this.dhikr, required this.isEnglish});

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
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: color,
            height: 2.0,
          ),
          textAlign: TextAlign.center,
          textDirection: TextDirection.rtl,
        ),
        if (isEnglish && dhikr.transliteration.isNotEmpty) ...[
          const SizedBox(height: 14),
          Divider(
            color: MobileColors.primary.withValues(alpha: 0.15),
            thickness: 1,
          ),
          const SizedBox(height: 10),
          Text(
            dhikr.transliteration,
            style: TextStyle(
              fontFamily: 'Rubik',
              fontSize: 15,
              fontWeight: FontWeight.w400,
              fontStyle: FontStyle.italic,
              color: color.withValues(alpha: 0.75),
              height: 1.6,
            ),
            textAlign: TextAlign.center,
            textDirection: TextDirection.ltr,
          ),
        ],
      ],
    );
  }
}

class _VirtueBadge extends StatelessWidget {
  final TextDhikr dhikr;
  final bool isEnglish;

  const _VirtueBadge({required this.dhikr, required this.isEnglish});

  @override
  Widget build(BuildContext context) {
    final badgeColor = MobileColors.primary.withValues(alpha: 0.08);
    final style = MobileTextStyles.labelSm(context).copyWith(
      color: MobileColors.primary,
      fontWeight: FontWeight.w600,
    );

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: badgeColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            dhikr.virtue,
            style: style,
            textAlign: TextAlign.center,
            textDirection: TextDirection.rtl,
          ),
          if (isEnglish && dhikr.virtueEn.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(
              dhikr.virtueEn,
              style: style.copyWith(
                fontFamily: 'Rubik',
                fontStyle: FontStyle.italic,
                fontSize: 12,
              ),
              textAlign: TextAlign.center,
              textDirection: TextDirection.ltr,
            ),
          ],
        ],
      ),
    );
  }
}

class _SourceLabel extends StatelessWidget {
  final TextDhikr dhikr;
  final bool isEnglish;

  const _SourceLabel({required this.dhikr, required this.isEnglish});

  @override
  Widget build(BuildContext context) {
    final style = MobileTextStyles.labelSm(context);
    if (!isEnglish || dhikr.sourceEn.isEmpty) {
      return Text(dhikr.source, style: style);
    }
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          dhikr.source,
          style: style,
          textDirection: TextDirection.rtl,
        ),
        const SizedBox(height: 2),
        Text(
          dhikr.sourceEn,
          style: style.copyWith(fontFamily: 'Rubik', fontSize: 11),
          textDirection: TextDirection.ltr,
        ),
      ],
    );
  }
}
