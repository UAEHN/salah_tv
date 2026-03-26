import 'package:flutter/material.dart';
import '../../../../../core/mobile_theme.dart';
import '../../../domain/entities/adhkar_category.dart';

/// Maps category icon string IDs to Material icons.
const _kCategoryIcons = <String, IconData>{
  'wb_sunny': Icons.wb_sunny_rounded,
  'nights_stay': Icons.nights_stay_rounded,
  'mosque': Icons.mosque_rounded,
  'bedtime': Icons.bedtime_rounded,
  'alarm': Icons.alarm_rounded,
  'auto_stories': Icons.auto_stories_rounded,
};

class MobileAdhkarCategoryCard extends StatelessWidget {
  final AdhkarCategory category;
  final VoidCallback onTap;

  const MobileAdhkarCategoryCard({
    super.key,
    required this.category,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final icon = _kCategoryIcons[category.icon] ?? Icons.auto_stories_rounded;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: MobileDecorations.pillCard(context),
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [MobileColors.primary, MobileColors.primaryContainer],
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(icon, color: Colors.white, size: 26),
            ),
            const SizedBox(height: 14),
            Text(
              category.nameAr,
              style: MobileTextStyles.bodyMd(context).copyWith(
                fontWeight: FontWeight.w700,
                color: MobileColors.onSurface(context),
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 6),
            Text(
              '${category.totalCount} أذكار',
              style: MobileTextStyles.labelSm(context),
            ),
          ],
        ),
      ),
    );
  }
}
