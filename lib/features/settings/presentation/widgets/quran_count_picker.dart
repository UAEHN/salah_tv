import 'package:flutter/material.dart';
import 'package:ghasaq/l10n/app_localizations.dart';

import '../../../../core/app_colors.dart';
import '../../../quran/domain/entities/quran_playback_mode.dart';
import 'tv_focusable_card.dart';

/// Horizontal chip row letting the user pick a finite repeat count or
/// infinity ([kInfiniteRepeat]).
class QuranCountPicker extends StatelessWidget {
  final String label;
  final int currentCount;
  final List<int> options; // each element is a positive int or kInfiniteRepeat
  final AccentPalette palette;
  final ThemeColors tc;
  final ValueChanged<int> onChanged;

  const QuranCountPicker({
    required this.label,
    required this.currentCount,
    required this.options,
    required this.palette,
    required this.tc,
    required this.onChanged,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: tc.textPrimary,
          ),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            for (var i = 0; i < options.length; i++) ...[
              if (i > 0) const SizedBox(width: 8),
              Expanded(
                child: _CountChip(
                  count: options[i],
                  isSelected: options[i] == currentCount,
                  palette: palette,
                  tc: tc,
                  onTap: () => onChanged(options[i]),
                ),
              ),
            ],
          ],
        ),
      ],
    );
  }
}

class _CountChip extends StatelessWidget {
  final int count;
  final bool isSelected;
  final AccentPalette palette;
  final ThemeColors tc;
  final VoidCallback onTap;

  const _CountChip({
    required this.count,
    required this.isSelected,
    required this.palette,
    required this.tc,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isInfinite = count == kInfiniteRepeat;
    final l = AppLocalizations.of(context);
    final label = isInfinite
        ? l.settingsQuranCountInfinite
        : l.settingsQuranCountValue(count);
    return TvFocusableCard(
      onPressed: onTap,
      accent: palette.primary,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? palette.primary.withValues(alpha: 0.18)
              : tc.glass(opacity: 0.05).color,
          border: Border.all(
            color: isSelected ? palette.primary : Colors.white12,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 16,
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
              color: isSelected ? palette.primary : tc.textPrimary,
            ),
          ),
        ),
      ),
    );
  }
}
