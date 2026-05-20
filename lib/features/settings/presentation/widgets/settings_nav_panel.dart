import 'package:flutter/material.dart';
import '../../../../core/app_colors.dart';
import 'exit_button.dart';
import 'settings_category_definitions.dart';
import 'settings_nav_card.dart';
import 'update_button.dart';

/// Vertical navigation panel with category cards and exit button.
/// Each card holds its canonical [SettingsCategoryDef.id] so the focus node
/// lookup stays correct when mosque-mode filters the visible list.
class SettingsNavPanel extends StatelessWidget {
  final List<SettingsCategoryDef> categories;
  final int selectedIndex;
  final List<FocusNode> navFocusNodes;
  final AccentPalette palette;
  final ThemeColors tc;
  final ValueChanged<int> onSelectIndex;

  const SettingsNavPanel({
    required this.categories,
    required this.selectedIndex,
    required this.navFocusNodes,
    required this.palette,
    required this.tc,
    required this.onSelectIndex,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.fromLTRB(14, 14, 14, 0),
            itemCount: categories.length,
            itemBuilder: (context, i) {
              final cat = categories[i];
              return SettingsNavCard(
                icon: cat.icon,
                title: cat.title,
                subtitle: cat.subtitle,
                isSelected: selectedIndex == cat.id,
                onFocused: () => onSelectIndex(cat.id),
                focusNode: navFocusNodes[cat.id],
                palette: palette,
                isDarkMode: tc.isDark,
                autofocus: selectedIndex == cat.id,
              );
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
          child: SettingsUpdateButton(tc: tc, palette: palette),
        ),
        const Padding(
          padding: EdgeInsets.fromLTRB(14, 7, 14, 14),
          child: SettingsExitButton(),
        ),
      ],
    );
  }
}
