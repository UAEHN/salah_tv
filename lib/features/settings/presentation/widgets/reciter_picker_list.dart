import 'package:flutter/material.dart';
import 'package:ghasaq/l10n/app_localizations.dart';
import 'package:provider/provider.dart';

import '../../../../core/app_colors.dart';
import '../../../../core/arabic_search.dart';
import '../../../quran/domain/entities/quran_reciter.dart';
import '../dialogs/reciter_picker_states.dart';
import '../logic/reciter_list_sorter.dart';
import '../settings_provider.dart';
import 'reciter_list_row.dart';

/// Renders the section-aware list of reciters used inside the picker dialog.
/// Watches [SettingsProvider] so favorite stars update live without the
/// dialog itself owning provider wiring.
class ReciterPickerList extends StatelessWidget {
  final List<QuranApiReciter> reciters;
  final String currentServerUrl;
  final String query;
  final AccentPalette palette;
  final void Function(QuranApiReciter) onSelect;

  const ReciterPickerList({
    required this.reciters,
    required this.currentServerUrl,
    required this.query,
    required this.palette,
    required this.onSelect,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final settingsProv = context.watch<SettingsProvider>();
    final favorites = settingsProv.settings.favoriteReciterServerUrls;
    final normalized = normalizeArabicForSearch(query);
    final entries = buildReciterPickerEntries(
      reciters: reciters,
      favoriteUrls: favorites,
      isSearching: normalized.isNotEmpty,
      matchesQuery: (name) => normalized.isEmpty ||
          normalizeArabicForSearch(name).contains(normalized),
    );
    final rows = entries.whereType<ReciterRow>().toList(growable: false);
    if (rows.isEmpty) {
      return Center(
        child: Text(l.searchNoResults,
            style: const TextStyle(color: Colors.white54)),
      );
    }
    final autofocusUrl = rows
        .firstWhere(
          (e) => e.reciter.serverUrl == currentServerUrl,
          orElse: () => rows.first,
        )
        .reciter
        .serverUrl;
    return ListView.builder(
      itemCount: entries.length,
      itemBuilder: (_, i) => _entry(entries[i], autofocusUrl, settingsProv),
    );
  }

  Widget _entry(
    ReciterPickerEntry entry,
    String autofocusUrl,
    SettingsProvider settingsProv,
  ) {
    if (entry is ReciterSectionHeader) {
      return ReciterSectionLabel(
          section: entry.section, accent: palette.primary);
    }
    final row = entry as ReciterRow;
    return ReciterListRow(
      reciter: row.reciter,
      isSelected: row.reciter.serverUrl == currentServerUrl,
      isFavorite: row.isFavorite,
      autofocus: row.reciter.serverUrl == autofocusUrl && query.isEmpty,
      accent: palette.primary,
      onSelect: () => onSelect(row.reciter),
      onToggleFavorite: () =>
          settingsProv.toggleFavoriteReciter(row.reciter.serverUrl),
    );
  }
}
