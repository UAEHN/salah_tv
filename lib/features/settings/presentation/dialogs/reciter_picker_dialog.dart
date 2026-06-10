import 'package:flutter/material.dart';
import 'package:ghasaq/l10n/app_localizations.dart';

import '../../../../core/app_colors.dart';
import '../../../../core/widgets/tv_search_bar.dart';
import '../../../../injection.dart';
import '../../../quran/domain/entities/quran_reciter.dart';
import '../../../quran/domain/i_quran_api_repository.dart';
import '../../../quran/domain/usecases/fetch_reciters_usecase.dart';
import '../widgets/reciter_picker_list.dart';
import 'reciter_picker_states.dart';

class ReciterPickerDialog extends StatefulWidget {
  final AccentPalette palette;
  final String currentServerUrl;
  final String language;
  final void Function(String name, String serverUrl) onSelected;

  const ReciterPickerDialog({
    required this.palette,
    required this.currentServerUrl,
    required this.language,
    required this.onSelected,
    super.key,
  });

  @override
  State<ReciterPickerDialog> createState() => _ReciterPickerDialogState();
}

class _ReciterPickerDialogState extends State<ReciterPickerDialog> {
  List<QuranApiReciter>? _reciters;
  String? _error;
  String _query = '';

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final useCase = FetchRecitersUseCase(getIt<IQuranApiRepository>());
    final result = await useCase(language: widget.language);
    if (!mounted) return;
    result.fold(
      (f) => setState(() => _error = f.message),
      (list) => setState(() => _reciters = list),
    );
  }

  void _retry() => setState(() {
    _error = null;
    _reciters = null;
    _load();
  });

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final isEn = widget.language == 'en';
    return Directionality(
      textDirection: isEn ? TextDirection.ltr : TextDirection.rtl,
      child: Dialog(
        backgroundColor: const Color(0xFF0A1628),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          width: 540,
          height: 580,
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.mic_rounded,
                    color: widget.palette.primary,
                    size: 26,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    l.settingsSelectReciter,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              if (_reciters != null)
                TvSearchBar(
                  hintText: l.searchReciterHint,
                  accent: widget.palette.primary,
                  onChanged: (v) => setState(() => _query = v),
                ),
              if (_reciters != null) const SizedBox(height: 8),
              Expanded(child: _buildBody()),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBody() {
    if (_error != null) {
      return ReciterErrorView(onRetry: _retry, palette: widget.palette);
    }
    if (_reciters == null) return ReciterLoadingView(palette: widget.palette);
    return ReciterPickerList(
      reciters: _reciters!,
      currentServerUrl: widget.currentServerUrl,
      query: _query,
      palette: widget.palette,
      onSelect: (r) {
        widget.onSelected(r.nameAr, r.serverUrl);
        Navigator.pop(context);
      },
    );
  }
}
