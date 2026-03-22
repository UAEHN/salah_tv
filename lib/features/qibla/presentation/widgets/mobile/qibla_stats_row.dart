import 'package:flutter/material.dart';
import '../../../../../core/mobile_theme.dart';

class QiblaStatsRow extends StatelessWidget {
  final String distance;
  final String deviation;

  const QiblaStatsRow({
    super.key,
    required this.distance,
    required this.deviation,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      textDirection: TextDirection.rtl,
      children: [
        // Distance Card (Right side when RTL)
        Expanded(
          child: _buildStatCard(
            context: context,
            title: 'المسافة للكعبة',
            value: distance,
            unit: 'كم',
            unitColor: MobileColors.primaryContainer,
          ),
        ),
        const SizedBox(width: 16),
        // Deviation Card (Left side when RTL)
        Expanded(
          child: _buildStatCard(
            context: context,
            title: 'الانحراف',
            value: deviation,
            unit: 'درجة',
            unitColor: MobileColors
                .secondary, // Or use a distinct orange/red like the design
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required BuildContext context,
    required String title,
    required String value,
    required String unit,
    required Color unitColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
      decoration: MobileDecorations.pillCard(context).copyWith(
        borderRadius: BorderRadius.circular(
          32,
        ), // More rounded than prayer cards
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            title,
            style: MobileTextStyles.labelSm(
              context,
            ).copyWith(color: MobileColors.onSurfaceMuted(context)),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisSize: MainAxisSize.min,
            textDirection: TextDirection.rtl,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                value,
                style: TextStyle(
                  fontFamily: 'Rubik',
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  color: MobileColors.onSurface(context),
                  height: 1.0,
                ),
              ),
              const SizedBox(width: 4),
              Padding(
                padding: const EdgeInsets.only(bottom: 2.0),
                child: Text(
                  unit,
                  style: MobileTextStyles.labelSm(
                    context,
                  ).copyWith(color: unitColor, fontWeight: FontWeight.w800),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
