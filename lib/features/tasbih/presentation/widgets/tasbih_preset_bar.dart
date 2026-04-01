import 'package:flutter/material.dart';

import '../../../../core/localization/tasbih_text_localizer.dart';
import '../../../../core/mobile_theme.dart';
import '../../domain/entities/tasbih_preset.dart';

class TasbihPresetBar extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onSelect;

  const TasbihPresetBar({
    super.key,
    required this.selectedIndex,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 48,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: kTasbihPresets.length,
        separatorBuilder: (_, _) => const SizedBox(width: 10),
        itemBuilder: (context, i) {
          final preset = kTasbihPresets[i];
          final isSelected = i == selectedIndex;
          return ChoiceChip(
            label: Text('${localizedTasbihPhrase(context, preset.key)}  ×${preset.target}'),
            selected: isSelected,
            onSelected: (_) => onSelect(i),
            selectedColor: MobileColors.primary.withValues(alpha: 0.2),
            labelStyle: TextStyle(
              color: isSelected
                  ? MobileColors.primary
                  : MobileColors.onSurfaceMuted(context),
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              fontSize: 13,
            ),
          );
        },
      ),
    );
  }
}
