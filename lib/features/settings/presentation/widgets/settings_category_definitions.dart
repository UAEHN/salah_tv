import 'package:flutter/material.dart';
import 'package:ghasaq/l10n/app_localizations.dart';

/// Metadata for one settings rail card. [id] is the canonical 0..8 index used
/// by [SettingsContentPanel]'s IndexedStack (kept stable when mosque-mode
/// hides cards so that focus nodes / key handlers still refer to the right
/// content slot).
typedef SettingsCategoryDef = ({
  int id,
  IconData icon,
  String title,
  String subtitle,
});

List<SettingsCategoryDef> buildSettingsCategories(AppLocalizations l) {
  return [
    (
      id: 0,
      icon: Icons.location_on_rounded,
      title: l.settingsCategoryLocation,
      subtitle: l.settingsCategoryLocationSubtitle,
    ),
    (
      id: 1,
      icon: Icons.menu_book_rounded,
      title: l.settingsCategoryQuran,
      subtitle: l.settingsCategoryQuranSubtitle,
    ),
    (
      id: 2,
      icon: Icons.volume_up_rounded,
      title: l.settingsCategoryAdhan,
      subtitle: l.settingsCategoryAdhanSubtitle,
    ),
    (
      id: 3,
      icon: Icons.tune_rounded,
      title: l.settingsCategoryAdhanOffsets,
      subtitle: l.settingsCategoryAdhanOffsetsSubtitle,
    ),
    (
      id: 4,
      icon: Icons.timer_rounded,
      title: l.settingsCategoryIqama,
      subtitle: l.settingsCategoryIqamaSubtitle,
    ),
    (
      id: 5,
      icon: Icons.mosque_rounded,
      title: l.settingsCategoryMosque,
      subtitle: l.settingsCategoryMosqueSubtitle,
    ),
    (
      id: 6,
      icon: Icons.palette_rounded,
      title: l.settingsCategoryAppearance,
      subtitle: l.settingsCategoryAppearanceSubtitle,
    ),
    (
      id: 7,
      icon: Icons.auto_stories_rounded,
      title: l.settingsCategoryAdhkar,
      subtitle: l.settingsCategoryAdhkarSubtitle,
    ),
    (
      id: 8,
      icon: Icons.mark_chat_read_rounded,
      title: l.feedbackSection,
      subtitle: l.feedbackSettingsTile,
    ),
  ];
}
