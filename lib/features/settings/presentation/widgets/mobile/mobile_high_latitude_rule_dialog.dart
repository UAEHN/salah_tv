import 'package:flutter/material.dart';
import 'package:ghasaq/l10n/app_localizations.dart';

import '../../../../../core/mobile_theme.dart';
import '../../../../prayer/data/high_latitude_rule_map.dart';
import 'mobile_high_latitude_rule_option.dart';

/// Bottom-sheet picker for [HighLatitudeRuleKey].
///
/// Lets users in Europe (and other > ~48°N regions) pick the Fajr/Isha
/// adjustment convention used by their local mosque instead of being
/// forced onto the hard-coded `middleOfTheNight` fallback.
class MobileHighLatitudeRuleDialog extends StatelessWidget {
  final String currentRule;
  final ValueChanged<String> onSave;

  const MobileHighLatitudeRuleDialog({
    super.key,
    required this.currentRule,
    required this.onSave,
  });

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
            for (final key in HighLatitudeRuleKey.all)
              MobileHighLatitudeRuleOption(
                ruleKey: key,
                isSelected: currentRule == key,
                onTap: () {
                  onSave(key);
                  Navigator.pop(context);
                },
              ),
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
    l.settingsHighLatitudeLabel,
    style: MobileTextStyles.titleMd(
      context,
    ).copyWith(color: MobileColors.onSurface(context), fontSize: 18),
  );

  Widget _buildNote(BuildContext context, AppLocalizations l) => Text(
    l.settingsHighLatitudeNote,
    style: MobileTextStyles.bodyMd(
      context,
    ).copyWith(color: MobileColors.onSurfaceMuted(context), fontSize: 12),
    textDirection: TextDirection.rtl,
    textAlign: TextAlign.center,
  );
}
