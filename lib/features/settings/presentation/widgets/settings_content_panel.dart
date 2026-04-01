import 'package:flutter/material.dart';
import 'package:ghasaq/l10n/app_localizations.dart';

import 'adhan_offsets_table.dart';
import 'adhan_section.dart';
import 'adhkar_section.dart';
import 'city_section.dart';
import 'country_section.dart';
import 'dark_mode_section.dart';
import 'iqama_table.dart';
import 'language_section.dart';
import 'quran_section.dart';
import 'section_title.dart';
import 'simple_sections.dart';

class SettingsContentPanel extends StatelessWidget {
  final int selectedIndex;

  const SettingsContentPanel({required this.selectedIndex, super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final slots = [
      _slot([
        const CountrySection(),
        const SizedBox(height: 16),
        const CitySection(),
      ]),
      _slot([const QuranSection()]),
      _slot([const AdhanSection()]),
      _slot([const AdhanOffsetsTable()]),
      _slot([const IqamaTable()]),
      _slot([
        SettingsSectionTitle(title: l.settingsFont),
        const SizedBox(height: 12),
        const FontSection(),
        const SizedBox(height: 24),
        SettingsSectionTitle(title: l.settingsThemeColor),
        const SizedBox(height: 12),
        const ThemeSection(),
        const SizedBox(height: 24),
        SettingsSectionTitle(title: l.settingsAppearance),
        const SizedBox(height: 12),
        const DarkModeSection(),
        const SizedBox(height: 24),
        SettingsSectionTitle(title: l.settingsLayoutDesign),
        const SizedBox(height: 12),
        const LayoutStyleSection(),
        const SizedBox(height: 24),
        SettingsSectionTitle(title: l.settingsLanguage),
        const SizedBox(height: 12),
        const LanguageSection(),
        const SizedBox(height: 24),
        SettingsSectionTitle(title: l.settingsTimeFormat),
        const SizedBox(height: 12),
        const TimeFormatSection(),
        const SizedBox(height: 24),
        SettingsSectionTitle(title: l.settingsClockType),
        const SizedBox(height: 12),
        const ClockStyleSection(),
      ]),
      _slot([const AdhkarSection()]),
    ];

    return IndexedStack(
      index: selectedIndex,
      children: [
        for (int i = 0; i < slots.length; i++)
          ExcludeFocus(excluding: i != selectedIndex, child: slots[i]),
      ],
    );
  }

  Widget _slot(List<Widget> children) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children,
      ),
    );
  }
}
