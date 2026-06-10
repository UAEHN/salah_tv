import 'package:flutter/material.dart';
import 'package:ghasaq/l10n/app_localizations.dart';

import '../../../../core/app_colors.dart';
import '../../../../core/surahs_data.dart';
import '../../../../core/widgets/tv_search_bar.dart';
import '../../../quran/domain/entities/surah.dart';
import '../widgets/tv_focusable_list_tile.dart';
import 'surah_search.dart';

/// TV-friendly picker for selecting a single surah (1..114) with search.
class SurahPickerDialog extends StatefulWidget {
  final AccentPalette palette;
  final int? selectedSurahNumber;
  final ValueChanged<int> onSelected;

  const SurahPickerDialog({
    required this.palette,
    required this.selectedSurahNumber,
    required this.onSelected,
    super.key,
  });

  @override
  State<SurahPickerDialog> createState() => _SurahPickerDialogState();
}

class _SurahPickerDialogState extends State<SurahPickerDialog> {
  String _query = '';

  List<Surah> get _filtered => filterSurahsByQuery(kSurahs, _query);

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final list = _filtered;
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Dialog(
        backgroundColor: const Color(0xFF0A1628),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          width: 540,
          height: 620,
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.menu_book_rounded,
                    color: widget.palette.primary,
                    size: 26,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    l.surahPickerTitle,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              TvSearchBar(
                hintText: l.searchSurahHint,
                accent: widget.palette.primary,
                onChanged: (v) => setState(() => _query = v),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: list.isEmpty
                    ? Center(
                        child: Text(
                          l.searchNoResults,
                          style: const TextStyle(color: Colors.white54),
                        ),
                      )
                    : ListView.separated(
                        itemCount: list.length,
                        separatorBuilder: (_, _) =>
                            const Divider(color: Colors.white10, height: 1),
                        itemBuilder: (context, i) {
                          final surah = list[i];
                          final isSelected =
                              surah.number == widget.selectedSurahNumber;
                          // Initial focus lands on the first row so DPad-Down
                          // navigates the list immediately instead of opening
                          // the on-screen keyboard via the search field.
                          return TvFocusableListTile(
                            autofocus: i == 0 && _query.isEmpty,
                            accent: widget.palette.primary,
                            leading: SizedBox(
                              width: 40,
                              child: Text(
                                '${surah.number}',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: isSelected
                                      ? widget.palette.primary
                                      : Colors.white38,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                            title: Text(
                              surah.nameAr,
                              style: TextStyle(
                                color: isSelected
                                    ? widget.palette.primary
                                    : Colors.white,
                                fontWeight: isSelected
                                    ? FontWeight.w700
                                    : FontWeight.normal,
                                fontSize: 18,
                              ),
                            ),
                            trailing: isSelected
                                ? Icon(
                                    Icons.check_circle_rounded,
                                    color: widget.palette.primary,
                                  )
                                : null,
                            onTap: () {
                              widget.onSelected(surah.number);
                              Navigator.pop(context);
                            },
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
