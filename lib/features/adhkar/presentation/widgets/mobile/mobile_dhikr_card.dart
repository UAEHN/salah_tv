import 'package:flutter/material.dart';
import '../../../../../core/mobile_theme.dart';
import '../../../domain/entities/text_dhikr.dart';

/// Displays the dhikr text, source, and virtue in a styled card.
class MobileDhikrCard extends StatelessWidget {
  final TextDhikr dhikr;

  const MobileDhikrCard({super.key, required this.dhikr});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(24),
      decoration: MobileDecorations.pillCard(context),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Flexible(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Text(
                dhikr.text,
                style: TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: MobileColors.onSurface(context),
                  height: 2.0,
                ),
                textAlign: TextAlign.center,
                textDirection: TextDirection.rtl,
              ),
            ),
          ),
          if (dhikr.virtue.isNotEmpty) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: MobileColors.primary.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                dhikr.virtue,
                style: MobileTextStyles.labelSm(context).copyWith(
                  color: MobileColors.primary,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
          const SizedBox(height: 12),
          Text(
            dhikr.source,
            style: MobileTextStyles.labelSm(context),
          ),
        ],
      ),
    );
  }
}
