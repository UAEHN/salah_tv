import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/app_colors.dart';
import '../../../quran/domain/entities/quran_reciter.dart';
import '../settings_provider.dart';

class ReciterPickerDialog extends StatefulWidget {
  final AccentPalette palette;
  final String currentServerUrl;
  final void Function(String name, String serverUrl) onSelected;

  const ReciterPickerDialog({
    required this.palette,
    required this.currentServerUrl,
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
    try {
      final list = await context.read<SettingsProvider>().fetchReciters();
      if (mounted) setState(() => _reciters = list);
    } catch (e) {
      if (mounted) setState(() => _error = e.toString());
    }
  }

  void _retry() => setState(() { _error = null; _reciters = null; _load(); });

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
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
                  Text('اختر القاريء',
                      style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: Colors.white)),
                ],
              ),
              const SizedBox(height: 8),
              const Divider(color: Colors.white12),
              const SizedBox(height: 4),
              Expanded(child: _buildBody()),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBody() {
    if (_error != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.wifi_off_rounded, color: Colors.white54, size: 48),
            const SizedBox(height: 12),
            const Text('تعذّر تحميل القائمة.\nتحقق من الاتصال بالإنترنت.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white54, fontSize: 17)),
            const SizedBox(height: 16),
            TextButton(
              onPressed: _retry,
              child: Text('إعادة المحاولة',
                  style: TextStyle(color: widget.palette.primary, fontSize: 16)),
            ),
          ],
        ),
      );
    }
    if (_reciters == null) {
      return Center(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          CircularProgressIndicator(color: widget.palette.primary),
          const SizedBox(height: 16),
          const Text('جاري تحميل القراء...',
              style: TextStyle(color: Colors.white60, fontSize: 16)),
        ]),
      );
    }
    return ListView.separated(
      itemCount: _reciters!.length,
      separatorBuilder: (_, _) => const Divider(color: Colors.white10, height: 1),
      itemBuilder: (context, i) {
        final r = _reciters![i];
        final isSelected = r.serverUrl == widget.currentServerUrl;
        return ListTile(
          leading: Icon(Icons.mic_rounded,
              color: isSelected ? widget.palette.primary : Colors.white38),
          title: Text(r.nameAr,
              style: TextStyle(
                color: isSelected ? widget.palette.primary : Colors.white,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.normal,
                fontSize: 18,
              )),
          trailing: isSelected
              ? Icon(Icons.check_circle_rounded, color: widget.palette.primary)
              : null,
          onTap: () {
            widget.onSelected(r.nameAr, r.serverUrl);
            Navigator.pop(context);
          },
        );
      },
    );
  }
}
