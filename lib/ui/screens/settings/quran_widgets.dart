part of '../settings_screen.dart';

// ── Reciter picker dialog (loads from mp3quran.net API) ──────────────────────

class _ReciterPickerDialog extends StatefulWidget {
  final AccentPalette palette;
  final String currentServerUrl;
  final void Function(String name, String serverUrl) onSelected;

  const _ReciterPickerDialog({
    required this.palette,
    required this.currentServerUrl,
    required this.onSelected,
  });

  @override
  State<_ReciterPickerDialog> createState() => _ReciterPickerDialogState();
}

class _ReciterPickerDialogState extends State<_ReciterPickerDialog> {
  List<QuranApiReciter>? _reciters;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadReciters();
  }

  Future<void> _loadReciters() async {
    try {
      final list = await QuranApiService().fetchReciters();
      if (mounted) setState(() => _reciters = list);
    } catch (e) {
      if (mounted) setState(() => _error = e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Dialog(
        backgroundColor: const Color(0xFF0A1628),
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          width: 500,
          height: 540,
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title row
              Row(
                children: [
                  Icon(Icons.mic_rounded,
                      color: widget.palette.primary, size: 26),
                  const SizedBox(width: 12),
                  Text(
                    'اختر القاريء',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon:
                        const Icon(Icons.close, color: Colors.white54),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              const Divider(color: Colors.white12),
              const SizedBox(height: 4),

              // Body
              Expanded(
                child: _error != null
                    ? Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.wifi_off_rounded,
                                color: Colors.white54, size: 48),
                            const SizedBox(height: 12),
                            Text(
                              'تعذّر تحميل القائمة.\nتحقق من الاتصال بالإنترنت.',
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                  color: Colors.white54, fontSize: 17),
                            ),
                            const SizedBox(height: 16),
                            TextButton(
                              onPressed: () {
                                setState(() {
                                  _error = null;
                                  _reciters = null;
                                });
                                _loadReciters();
                              },
                              child: Text(
                                'إعادة المحاولة',
                                style: TextStyle(
                                    color: widget.palette.primary,
                                    fontSize: 16),
                              ),
                            ),
                          ],
                        ),
                      )
                    : _reciters == null
                        ? Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                CircularProgressIndicator(
                                    color: widget.palette.primary),
                                const SizedBox(height: 16),
                                const Text(
                                  'جاري تحميل القراء...',
                                  style: TextStyle(
                                      color: Colors.white60,
                                      fontSize: 16),
                                ),
                              ],
                            ),
                          )
                        : ListView.separated(
                            itemCount: _reciters!.length,
                            separatorBuilder: (_, __) => const Divider(
                                color: Colors.white10, height: 1),
                            itemBuilder: (context, i) {
                              final r = _reciters![i];
                              final isSelected =
                                  r.serverUrl == widget.currentServerUrl;
                              return ListTile(
                                leading: Icon(
                                  Icons.mic_rounded,
                                  color: isSelected
                                      ? widget.palette.primary
                                      : Colors.white38,
                                ),
                                title: Text(
                                  r.nameAr,
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
                                    ? Icon(Icons.check_circle_rounded,
                                        color: widget.palette.primary)
                                    : null,
                                onTap: () {
                                  widget.onSelected(
                                      r.nameAr, r.serverUrl);
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
