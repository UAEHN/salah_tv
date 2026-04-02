import 'package:flutter/material.dart';
import 'package:ghasaq/l10n/app_localizations.dart';

import '../../../../core/mobile_theme.dart';

class MobileFeedbackTypeSelector extends StatelessWidget {
  final AppLocalizations l;
  final String selectedType;
  final ValueChanged<String> onSelect;

  const MobileFeedbackTypeSelector({
    super.key,
    required this.l,
    required this.selectedType,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    final types = [
      ('bug', l.feedbackTypeBug, Icons.bug_report_rounded),
      ('suggestion', l.feedbackTypeSuggestion, Icons.lightbulb_rounded),
      ('other', l.feedbackTypeOther, Icons.warning_amber_rounded),
    ];

    return Row(
      children: types
          .map(
            (t) => Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: _MobileFeedbackTypeChip(
                  label: t.$2,
                  icon: t.$3,
                  isSelected: selectedType == t.$1,
                  onTap: () => onSelect(t.$1),
                ),
              ),
            ),
          )
          .toList(growable: false),
    );
  }
}

class _MobileFeedbackTypeChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _MobileFeedbackTypeChip({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cardColor = MobileColors.cardColor(context);

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected
              ? MobileColors.primary.withValues(alpha: 0.15)
              : cardColor.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected
                ? MobileColors.primary
                : MobileColors.border(context),
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isSelected
                  ? MobileColors.primary
                  : MobileColors.onSurfaceMuted(context),
              size: 22,
            ),
            const SizedBox(height: 6),
            Text(
              label,
              style: MobileTextStyles.labelSm(context).copyWith(
                color: isSelected
                    ? MobileColors.primary
                    : MobileColors.onSurfaceMuted(context),
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
