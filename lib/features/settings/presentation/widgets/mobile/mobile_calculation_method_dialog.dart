import 'package:flutter/material.dart';
import 'package:ghasaq/l10n/app_localizations.dart';

import '../../../../../core/calculation_method_info.dart';
import '../../../../../core/mobile_theme.dart';
import 'mobile_select_option_tile.dart';

class MobileCalculationMethodDialog extends StatelessWidget {
  final String currentMethod;
  final ValueChanged<String> onSave;

  const MobileCalculationMethodDialog({
    super.key,
    required this.currentMethod,
    required this.onSave,
  });

  static const _methods = [
    'muslim_world_league',
    'egyptian',
    'karachi',
    'umm_al_qura',
    'dubai',
    'qatar',
    'kuwait',
    'morocco',
    'singapore',
    'tehran',
    'turkiye',
    'north_america',
    'moonsighting_committee',
  ];

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final cardColor = MobileColors.cardColor(context);

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        border: Border(top: BorderSide(color: MobileColors.border(context))),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildHandle(context),
            const SizedBox(height: 20),
            _buildHeader(context, l),
            const SizedBox(height: 8),
            _buildNote(context, l),
            const SizedBox(height: 16),
            _buildList(context),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildHandle(BuildContext context) => Container(
        width: 40,
        height: 4,
        decoration: BoxDecoration(
          color: MobileColors.onSurfaceMuted(context).withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(2),
        ),
      );

  Widget _buildHeader(BuildContext context, AppLocalizations l) => Text(
        l.settingsCalculationMethodLabel,
        style: MobileTextStyles.titleMd(context).copyWith(
          color: MobileColors.onSurface(context),
          fontSize: 18,
        ),
      );

  Widget _buildNote(BuildContext context, AppLocalizations l) => Text(
        l.settingsMethodAffectsGpsOnly,
        style: MobileTextStyles.bodyMd(context).copyWith(
          color: MobileColors.onSurfaceMuted(context),
          fontSize: 12,
        ),
        textDirection: TextDirection.rtl,
      );

  Widget _buildList(BuildContext context) => ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.55,
        ),
        child: ListView(
          shrinkWrap: true,
          children: _methods.map((key) {
            return MobileSelectOptionTile(
              title: localizedCalculationMethod(context, key),
              icon: Icons.calculate_rounded,
              isSelected: currentMethod == key,
              onTap: () {
                onSave(key);
                Navigator.pop(context);
              },
            );
          }).toList(),
        ),
      );
}
