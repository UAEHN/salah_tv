import 'package:flutter/material.dart';
import 'package:ghasaq/l10n/app_localizations.dart';
import 'package:provider/provider.dart';

import '../../../../../core/mobile_theme.dart';
import '../../../../settings/presentation/settings_provider.dart';
import '../../../domain/entities/adhkar_category.dart';

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
    final l = AppLocalizations.of(context);
    final locale = context.select<SettingsProvider, String>(
      (p) => p.settings.locale,
    );
    final icon = _kCategoryIcons[category.icon] ?? Icons.auto_stories_rounded;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: MobileDecorations.pillCard(context),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [MobileColors.primary, MobileColors.primaryContainer],
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(icon, color: Colors.white, size: 24),
            ),
            const SizedBox(height: 10),
            Text(
              category.displayName(locale),
              style: MobileTextStyles.bodyMd(context).copyWith(
                fontWeight: FontWeight.w700,
                color: MobileColors.onSurface(context),
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Text(
              l.adhkarCountLabel(category.totalCount),
              style: MobileTextStyles.labelSm(context),
            ),
          ],
        ),
      ),
    );
  }
}
