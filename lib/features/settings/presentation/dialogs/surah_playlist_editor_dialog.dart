import 'package:flutter/material.dart';
import 'package:ghasaq/l10n/app_localizations.dart';

import '../../../../core/app_colors.dart';
import '../../../../core/surahs_data.dart';
import '../../../../core/widgets/tv_search_bar.dart';
import '../widgets/tv_focusable_list_tile.dart';
import 'surah_playlist_actions_panel.dart';
import 'surah_playlist_editor_header.dart';
import 'surah_search.dart';

/// Multi-select editor for the surah playlist. Layout is split into a
/// scrollable list on the right and a sticky action panel on the left so the
/// user can reach Save/Cancel/Select-all from any list position with one
/// D-Pad press.
class SurahPlaylistEditorDialog extends StatefulWidget {
  final AccentPalette palette;
  final List<int> initialSelection;
  final ValueChanged<List<int>> onSaved;

  const SurahPlaylistEditorDialog({
    required this.palette,
    required this.initialSelection,
    required this.onSaved,
    super.key,
  });

  @override
  State<SurahPlaylistEditorDialog> createState() =>
      _SurahPlaylistEditorDialogState();
}

class _SurahPlaylistEditorDialogState extends State<SurahPlaylistEditorDialog> {
  late Set<int> _selected = {...widget.initialSelection};
  String _query = '';

  void _toggle(int n) {
    setState(() {
      if (!_selected.add(n)) _selected.remove(n);
    });
  }

  void _replaceSelection(Set<int> next) {
    setState(() => _selected = next);
  }

  @override
  Widget build(BuildContext context) {
    final palette = widget.palette;
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Dialog(
        backgroundColor: const Color(0xFF0A1628),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: SizedBox(
          width: 820,
          height: 660,
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SurahPlaylistEditorHeader(
                  palette: palette,
                  count: _selected.length,
                ),
                const SizedBox(height: 10),
                TvSearchBar(
                  hintText: AppLocalizations.of(context).searchSurahHint,
                  accent: palette.primary,
                  onChanged: (v) => setState(() => _query = v),
                ),
                const SizedBox(height: 10),
                Expanded(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Expanded(flex: 6, child: _list(palette)),
                      const SizedBox(width: 16),
                      const VerticalDivider(color: Colors.white12, width: 1),
                      const SizedBox(width: 16),
                      SizedBox(
                        width: 220,
                        child: SurahPlaylistActionsPanel(
                          palette: palette,
                          selected: _selected,
                          onSelectionChanged: _replaceSelection,
                          onCancel: () => Navigator.pop(context),
                          onSave: () {
                            widget.onSaved(_selected.toList()..sort());
                            Navigator.pop(context);
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _list(AccentPalette palette) {
    final list = filterSurahsByQuery(kSurahs, _query);
    if (list.isEmpty) {
      return Center(
        child: Text(
          AppLocalizations.of(context).searchNoResults,
          style: const TextStyle(color: Colors.white54),
        ),
      );
    }
    return ListView.separated(
      itemCount: list.length,
      separatorBuilder: (_, _) =>
          const Divider(color: Colors.white10, height: 1),
      itemBuilder: (context, i) {
        final surah = list[i];
        final isSelected = _selected.contains(surah.number);
        // Initial focus on the first row so DPad-Down navigates the list
        // immediately instead of opening the on-screen keyboard via search.
        return TvFocusableListTile(
          autofocus: i == 0 && _query.isEmpty,
          accent: palette.primary,
          leading: SizedBox(
            width: 40,
            child: Text(
              '${surah.number}',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: isSelected ? palette.primary : Colors.white38,
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
            ),
          ),
          title: Text(
            surah.nameAr,
            style: TextStyle(
              color: isSelected ? palette.primary : Colors.white,
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.normal,
              fontSize: 18,
            ),
          ),
          trailing: Icon(
            isSelected
                ? Icons.check_box_rounded
                : Icons.check_box_outline_blank_rounded,
            color: isSelected ? palette.primary : Colors.white38,
          ),
          onTap: () => _toggle(surah.number),
        );
      },
    );
  }
}
