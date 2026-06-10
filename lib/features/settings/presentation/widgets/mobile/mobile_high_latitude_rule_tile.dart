import 'package:flutter/material.dart';
import 'package:ghasaq/l10n/app_localizations.dart';

import '../../../../prayer/data/high_latitude_rule_map.dart';
import 'mobile_settings_tile.dart';

/// Settings row that opens the [MobileHighLatitudeRuleDialog] and shows
/// the currently selected rule as a subtitle.
class MobileHighLatitudeRuleTile extends StatelessWidget {
  final String currentRule;
  final VoidCallback onTap;

  const MobileHighLatitudeRuleTile({
    super.key,
    required this.currentRule,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return MobileSettingsTile(
      icon: Icons.wb_twilight_rounded,
      title: l.settingsHighLatitudeLabel,
      subtitle: _label(l, currentRule),
      onTap: onTap,
    );
  }

  String _label(AppLocalizations l, String key) {
    return switch (key) {
      HighLatitudeRuleKey.auto => l.highLatRuleAuto,
      HighLatitudeRuleKey.middleOfTheNight => l.highLatRuleMiddleOfNight,
      HighLatitudeRuleKey.seventhOfTheNight => l.highLatRuleSeventhOfNight,
      HighLatitudeRuleKey.twilightAngle => l.highLatRuleTwilightAngle,
      _ => l.highLatRuleAuto,
    };
  }
}
