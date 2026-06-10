import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../../core/app_colors.dart';
import '../../settings_provider.dart';
import 'tv_location_option_tile.dart';
import 'tv_location_picker_header.dart';

/// Generic TV picker dialog: a header + a vertical list of selectable
/// options. Reused for calculation-method, madhab and high-latitude-rule
/// settings so each picker stays under the 150-line cap.
///
/// Each option's [key] is what gets passed to [onSelected] when the user
/// picks it; [label] is what's drawn. [currentKey] gets the highlighted
/// "selected" state.
class TvSimpleChoiceDialog<T> extends StatelessWidget {
  final String title;
  final List<TvChoiceOption<T>> options;
  final T currentKey;
  final ValueChanged<T> onSelected;

  const TvSimpleChoiceDialog({
    required this.title,
    required this.options,
    required this.currentKey,
    required this.onSelected,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>().settings;
    final tc = ThemeColors.of(settings.isDarkMode);
    final accent = getThemePalette(settings.themeColorKey).primary;
    return Dialog(
      backgroundColor: tc.bgSurface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: BorderSide(color: accent.withValues(alpha: 0.20), width: 1),
      ),
      child: SizedBox(
        width: 720,
        height: 560,
        child: Column(
          children: [
            TvLocationPickerHeader(
              title: title,
              showBack: false,
              onBack: () {},
            ),
            const SizedBox(height: 8),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                child: ListView.builder(
                  // 8 px scrollable padding so the first/last tile's focus
                  // halo (blur 14) isn't clipped by the parent edges.
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  itemCount: options.length,
                  itemBuilder: (context, index) {
                    final opt = options[index];
                    return TvLocationOptionTile(
                      title: opt.label,
                      isSelected: opt.key == currentKey,
                      isBusy: false,
                      autofocus: index == 0,
                      onPressed: () {
                        onSelected(opt.key);
                        Navigator.of(context).pop();
                      },
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class TvChoiceOption<T> {
  final T key;
  final String label;

  const TvChoiceOption({required this.key, required this.label});
}
