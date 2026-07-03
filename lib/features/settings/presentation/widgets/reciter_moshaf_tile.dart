import 'package:flutter/material.dart';
import 'package:ghasaq/l10n/app_localizations.dart';

import '../../../quran/domain/entities/quran_moshaf.dart';
import 'tv_focusable_list_tile.dart';

/// One طريقة (moshaf) sub-row shown under an expanded reciter. Renders a radio
/// dot, the moshaf name, an «افتراضي» badge on the reciter's default طريقة, and
/// a check on the active selection. Selecting it picks that recitation URL.
class ReciterMoshafTile extends StatelessWidget {
  final QuranMoshaf moshaf;
  final bool isSelected;
  final bool isDefault;
  final Color accent;
  final VoidCallback onSelect;

  const ReciterMoshafTile({
    required this.moshaf,
    required this.isSelected,
    required this.isDefault,
    required this.accent,
    required this.onSelect,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return TvFocusableListTile(
      accent: accent,
      leading: Icon(
        isSelected
            ? Icons.radio_button_checked_rounded
            : Icons.radio_button_unchecked_rounded,
        color: isSelected ? accent : Colors.white30,
        size: 20,
      ),
      title: Row(
        children: [
          Flexible(
            child: Text(
              moshaf.name,
              style: TextStyle(
                color: isSelected ? accent : Colors.white70,
                fontSize: 16,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.normal,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (isDefault) ...[
            const SizedBox(width: 8),
            _DefaultBadge(text: l.reciterDefaultMoshaf, accent: accent),
          ],
        ],
      ),
      trailing: isSelected
          ? Icon(Icons.check_circle_rounded, color: accent, size: 20)
          : null,
      onTap: onSelect,
    );
  }
}

class _DefaultBadge extends StatelessWidget {
  final String text;
  final Color accent;
  const _DefaultBadge({required this.text, required this.accent});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: accent.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: accent,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
