import 'package:flutter/material.dart';
import 'package:ghasaq/l10n/app_localizations.dart';

import '../../../../core/app_colors.dart';
import '../../../../injection.dart';
import '../../../quran/domain/entities/quran_reciter.dart';
import '../../../quran/domain/i_quran_api_repository.dart';
import '../../../quran/domain/usecases/fetch_reciters_usecase.dart';

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

  void _retry() {
    setState(() {
      _error = null;
      _reciters = null;
      _load();
    });
  }

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
          width: 500,
          height: 540,
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.mic_rounded, color: widget.palette.primary, size: 26),
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
              const SizedBox(height: 8),
              const Divider(color: Colors.white12),
              const SizedBox(height: 4),
              Expanded(child: _buildBody(l)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBody(AppLocalizations l) {
    if (_error != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.wifi_off_rounded, color: Colors.white54, size: 48),
            const SizedBox(height: 12),
            Text(
              l.settingsFailedToLoadReciters,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white54, fontSize: 17),
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: _retry,
              child: Text(
                l.commonRetry,
                style: TextStyle(color: widget.palette.primary, fontSize: 16),
              ),
            ),
          ],
        ),
      );
    }

    if (_reciters == null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(color: widget.palette.primary),
            const SizedBox(height: 16),
            Text(
              l.settingsLoadingReciters,
              style: const TextStyle(color: Colors.white60, fontSize: 16),
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      itemCount: _reciters!.length,
      separatorBuilder: (_, _) => const Divider(color: Colors.white10, height: 1),
      itemBuilder: (context, i) {
        final r = _reciters![i];
        final isSelected = r.serverUrl == widget.currentServerUrl;
        return ListTile(
          leading: Icon(
            Icons.mic_rounded,
            color: isSelected ? widget.palette.primary : Colors.white38,
          ),
          title: Text(
            r.nameAr,
            style: TextStyle(
              color: isSelected ? widget.palette.primary : Colors.white,
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.normal,
              fontSize: 18,
            ),
          ),
          trailing:
              isSelected ? Icon(Icons.check_circle_rounded, color: widget.palette.primary) : null,
          onTap: () {
            widget.onSelected(r.nameAr, r.serverUrl);
            Navigator.pop(context);
          },
        );
      },
    );
  }
}
