import 'package:flutter/material.dart';
import 'package:ghasaq/l10n/app_localizations.dart';
import 'package:provider/provider.dart';

import '../../../../core/app_colors.dart';
import '../../../../core/calculation_method_info.dart';
import '../../../prayer/data/high_latitude_rule_map.dart';
import '../settings_provider.dart';
import 'location_value_card.dart';
import 'tv_location_picker/tv_simple_choice_dialog.dart';

/// Three TV cards (calculation method, madhab, high-latitude rule) shown
/// inside the Location settings tab when [AppSettings.isCalculatedLocation]
/// is true — i.e. the user picked a world (non-DB) city like Istanbul,
/// London, Berlin, NYC. For DB-backed countries (UAE, Egypt, Saudi…) these
/// settings have no effect because the schedule is pre-rendered, so we
/// hide them to avoid confusion.
class TvCalcSettingsSection extends StatelessWidget {
  const TvCalcSettingsSection({super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final sp = context.watch<SettingsProvider>();
    final s = sp.settings;
    if (!s.isCalculatedLocation) return const SizedBox.shrink();
    final palette = getThemePalette(s.themeColorKey);
    final tc = ThemeColors.of(s.isDarkMode);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        LocationValueCard(
          icon: Icons.functions_rounded,
          label: l.settingsCalculationMethodLabel,
          value: localizedCalculationMethod(context, s.calculationMethod),
          tc: tc,
          accent: palette.primary,
          onPressed: () => _openMethodDialog(context, sp),
        ),
        const SizedBox(height: 16),
        LocationValueCard(
          icon: Icons.menu_book_rounded,
          label: l.settingsMadhabLabel,
          value: s.madhab == 'hanafi' ? l.madhabHanafi : l.madhabShafiFamily,
          tc: tc,
          accent: palette.primary,
          onPressed: () => _openMadhabDialog(context, sp),
        ),
        const SizedBox(height: 16),
        LocationValueCard(
          icon: Icons.wb_twilight_rounded,
          label: l.settingsHighLatitudeLabel,
          value: _highLatLabel(l, s.highLatitudeRule),
          tc: tc,
          accent: palette.primary,
          onPressed: () => _openHighLatDialog(context, sp),
        ),
      ],
    );
  }

  void _openMethodDialog(BuildContext context, SettingsProvider sp) {
    final l = AppLocalizations.of(context);
    showDialog<void>(
      context: context,
      builder: (_) => TvSimpleChoiceDialog<String>(
        title: l.settingsCalculationMethodLabel,
        currentKey: sp.settings.calculationMethod,
        onSelected: sp.updateCalculationMethod,
        options:
            const [
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
                  'france',
                  'uoif',
                  'uk',
                  'germany',
                  'russia',
                  'jafari',
                  'moonsighting_committee',
                ]
                .map(
                  (k) => TvChoiceOption(
                    key: k,
                    label: localizedCalculationMethodFromLocalizations(l, k),
                  ),
                )
                .toList(),
      ),
    );
  }

  void _openMadhabDialog(BuildContext context, SettingsProvider sp) {
    final l = AppLocalizations.of(context);
    showDialog<void>(
      context: context,
      builder: (_) => TvSimpleChoiceDialog<String>(
        title: l.settingsMadhabLabel,
        currentKey: sp.settings.madhab,
        onSelected: sp.updateMadhab,
        options: [
          TvChoiceOption(key: 'shafi', label: l.madhabShafiFamily),
          TvChoiceOption(key: 'hanafi', label: l.madhabHanafi),
        ],
      ),
    );
  }

  void _openHighLatDialog(BuildContext context, SettingsProvider sp) {
    final l = AppLocalizations.of(context);
    showDialog<void>(
      context: context,
      builder: (_) => TvSimpleChoiceDialog<String>(
        title: l.settingsHighLatitudeLabel,
        currentKey: sp.settings.highLatitudeRule,
        onSelected: sp.updateHighLatitudeRule,
        options: HighLatitudeRuleKey.all
            .map((k) => TvChoiceOption(key: k, label: _highLatLabel(l, k)))
            .toList(),
      ),
    );
  }

  String _highLatLabel(AppLocalizations l, String key) {
    return switch (key) {
      HighLatitudeRuleKey.auto => l.highLatRuleAuto,
      HighLatitudeRuleKey.middleOfTheNight => l.highLatRuleMiddleOfNight,
      HighLatitudeRuleKey.seventhOfTheNight => l.highLatRuleSeventhOfNight,
      HighLatitudeRuleKey.twilightAngle => l.highLatRuleTwilightAngle,
      _ => l.highLatRuleAuto,
    };
  }
}
