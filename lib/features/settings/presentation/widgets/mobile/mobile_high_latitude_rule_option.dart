import 'package:flutter/material.dart';
import 'package:ghasaq/l10n/app_localizations.dart';

import '../../../../../core/mobile_theme.dart';
import '../../../../prayer/data/high_latitude_rule_map.dart';

/// Row used inside [MobileHighLatitudeRuleDialog] — same visual language as
/// [MobileSelectOptionTile] but with a two-line title/subtitle layout
/// because each rule needs a one-line explanation to be picked safely.
class MobileHighLatitudeRuleOption extends StatelessWidget {
  final String ruleKey;
  final bool isSelected;
  final VoidCallback onTap;

  const MobileHighLatitudeRuleOption({
    super.key,
    required this.ruleKey,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        decoration: BoxDecoration(
          color: isSelected
              ? MobileColors.cardColor(context).withValues(alpha: 0.55)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected
                ? MobileColors.activePrimaryContainer(
                    context,
                  ).withValues(alpha: 0.5)
                : MobileColors.border(context),
          ),
        ),
        child: Row(
          textDirection: TextDirection.rtl,
          children: [
            Icon(
              Icons.wb_twilight_rounded,
              color: isSelected
                  ? MobileColors.onSurface(context)
                  : MobileColors.onSurfaceMuted(context),
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(child: _buildLabels(context, l)),
            _buildRadio(context),
          ],
        ),
      ),
    );
  }

  Widget _buildLabels(BuildContext context, AppLocalizations l) => Column(
    crossAxisAlignment: CrossAxisAlignment.end,
    children: [
      Text(
        _label(l),
        style: MobileTextStyles.bodyMd(context).copyWith(
          color: isSelected
              ? MobileColors.onSurface(context)
              : MobileColors.onSurfaceMuted(context),
          fontSize: 15,
          fontWeight: FontWeight.w600,
        ),
        textDirection: TextDirection.rtl,
      ),
      const SizedBox(height: 4),
      Text(
        _subtitle(l),
        style: MobileTextStyles.bodyMd(context).copyWith(
          color: MobileColors.onSurfaceMuted(context),
          fontSize: 11,
          height: 1.4,
        ),
        textDirection: TextDirection.rtl,
      ),
    ],
  );

  Widget _buildRadio(BuildContext context) => Container(
    width: 22,
    height: 22,
    decoration: BoxDecoration(
      shape: BoxShape.circle,
      border: Border.all(
        color: isSelected
            ? MobileColors.activePrimaryContainer(context)
            : MobileColors.onSurfaceMuted(context),
        width: 2,
      ),
    ),
    padding: const EdgeInsets.all(4),
    child: isSelected
        ? Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: MobileColors.activePrimaryContainer(context),
            ),
          )
        : null,
  );

  String _label(AppLocalizations l) {
    return switch (ruleKey) {
      HighLatitudeRuleKey.auto => l.highLatRuleAuto,
      HighLatitudeRuleKey.middleOfTheNight => l.highLatRuleMiddleOfNight,
      HighLatitudeRuleKey.seventhOfTheNight => l.highLatRuleSeventhOfNight,
      HighLatitudeRuleKey.twilightAngle => l.highLatRuleTwilightAngle,
      _ => ruleKey,
    };
  }

  String _subtitle(AppLocalizations l) {
    return switch (ruleKey) {
      HighLatitudeRuleKey.auto => l.highLatRuleAutoSubtitle,
      HighLatitudeRuleKey.middleOfTheNight =>
        l.highLatRuleMiddleOfNightSubtitle,
      HighLatitudeRuleKey.seventhOfTheNight =>
        l.highLatRuleSeventhOfNightSubtitle,
      HighLatitudeRuleKey.twilightAngle => l.highLatRuleTwilightAngleSubtitle,
      _ => '',
    };
  }
}
