import 'package:flutter/material.dart';
import 'package:ghasaq/l10n/app_localizations.dart';
import 'package:provider/provider.dart';

import '../../../../core/app_colors.dart';
import '../../../../injection.dart';
import '../../../quran/domain/entities/quran_reciter.dart';
import '../../../quran/domain/i_quran_api_repository.dart';
import '../../../quran/domain/usecases/fetch_reciters_usecase.dart';
import '../../../../core/widgets/tv_button.dart';
import '../dialogs/moshaf_picker_dialog.dart';
import '../settings_provider.dart';

/// Separate «القراءة» row under [QuranReciterRow]. Lists the طرق of the
/// CURRENTLY selected reciter only and opens a dropdown to switch between them.
/// Renders nothing until reciters load, or when the active reciter has a single
/// طريقة — so it never adds noise for reciters without alternatives.
class QuranMoshafRow extends StatefulWidget {
  const QuranMoshafRow({super.key});

  @override
  State<QuranMoshafRow> createState() => _QuranMoshafRowState();
}

class _QuranMoshafRowState extends State<QuranMoshafRow> {
  List<QuranApiReciter>? _reciters;

  @override
  void initState() {
    super.initState();
    // §8: never await directly in initState — defer to a microtask.
    Future.microtask(_load);
  }

  Future<void> _load() async {
    final lang = context.read<SettingsProvider>().settings.locale;
    final useCase = FetchRecitersUseCase(getIt<IQuranApiRepository>());
    final result = await useCase(language: lang);
    if (!mounted) return;
    result.fold((_) {}, (list) => setState(() => _reciters = list));
  }

  QuranApiReciter? _currentReciter(String url) {
    final reciters = _reciters;
    if (reciters == null) return null;
    for (final r in reciters) {
      if (r.containsServerUrl(url)) return r;
    }
    return null;
  }

  String _activeName(QuranApiReciter r, String url) {
    for (final m in r.moshafs) {
      if (m.serverUrl == url) return m.name;
    }
    return r.moshafs.first.name;
  }

  void _openPicker(QuranApiReciter reciter, SettingsProvider prov) {
    final palette = getThemePalette(prov.settings.themeColorKey);
    showDialog<void>(
      context: context,
      builder: (_) => MoshafPickerDialog(
        reciter: reciter,
        currentServerUrl: prov.settings.quranReciterServerUrl,
        palette: palette,
        isRtl: prov.settings.locale != 'en',
        onSelected: (url) => prov.updateQuranReciter(reciter.nameAr, url),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final settingsProv = context.watch<SettingsProvider>();
    final settings = settingsProv.settings;
    final current = _currentReciter(settings.quranReciterServerUrl);
    if (current == null || !current.hasMultipleMoshafs) {
      return const SizedBox.shrink();
    }
    final palette = getThemePalette(settings.themeColorKey);
    final tc = ThemeColors.of(settings.isDarkMode);

    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Row(
        children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: tc.glass(opacity: 0.06, borderRadius: 10),
              child: Row(
                children: [
                  Icon(
                    Icons.queue_music_rounded,
                    color: palette.primary,
                    size: 22,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      _activeName(current, settings.quranReciterServerUrl),
                      style: TextStyle(
                        fontSize: 18,
                        color: tc.textPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 16),
          TvButton(
            onPressed: () => _openPicker(current, settingsProv),
            accent: palette.primary,
            filled: true,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.tune_rounded, color: Colors.white, size: 20),
                const SizedBox(width: 8),
                Text(
                  l.reciterChangeMoshaf,
                  style: const TextStyle(fontSize: 18, color: Colors.white),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
