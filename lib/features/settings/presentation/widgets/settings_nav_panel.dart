import 'package:flutter/material.dart';
import '../../../../core/app_colors.dart';
import 'exit_button.dart';
import 'settings_nav_card.dart';

/// Vertical navigation panel with category cards and exit button.
class SettingsNavPanel extends StatelessWidget {
  final List<(IconData, String, String)> categories;
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
                icon: cat.$1,
                title: cat.$2,
                subtitle: cat.$3,
                isSelected: selectedIndex == i,
                onFocused: () => onSelectIndex(i),
                focusNode: navFocusNodes[i],
                palette: palette,
                isDarkMode: tc.isDark,
                autofocus: i == 0,
              );
            },
          ),
        ),
        const Padding(
          padding: EdgeInsets.all(14),
          child: SettingsExitButton(),
        ),
      ],
    );
  }
}
