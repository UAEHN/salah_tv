import 'package:flutter/material.dart';

import '../../../quran/domain/entities/quran_reciter.dart';
import 'favorite_star_button.dart';
import 'tv_focusable_list_tile.dart';

/// One reciter row in the picker: select-tile + favorite star button. The
/// two are independently focusable so D-pad LEFT/RIGHT moves between them
/// while UP/DOWN moves to the next reciter.
class ReciterListRow extends StatelessWidget {
  final QuranApiReciter reciter;
  final bool isSelected;
  final bool isFavorite;
  final bool autofocus;
  final Color accent;
  final VoidCallback onSelect;
  final VoidCallback onToggleFavorite;

  const ReciterListRow({
    required this.reciter,
    required this.isSelected,
    required this.isFavorite,
    required this.autofocus,
    required this.accent,
    required this.onSelect,
    required this.onToggleFavorite,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: TvFocusableListTile(
            autofocus: autofocus,
            accent: accent,
            leading: Icon(
              Icons.mic_rounded,
              color: isSelected ? accent : Colors.white38,
            ),
            title: Text(
              reciter.nameAr,
              style: TextStyle(
                color: isSelected ? accent : Colors.white,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.normal,
                fontSize: 18,
              ),
            ),
            trailing: isSelected
                ? Icon(Icons.check_circle_rounded, color: accent)
                : null,
            onTap: onSelect,
          ),
        ),
        const SizedBox(width: 8),
        FavoriteStarButton(
          isFavorite: isFavorite,
          accent: accent,
          onToggle: onToggleFavorite,
        ),
      ],
    );
  }
}
