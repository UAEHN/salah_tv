import 'package:flutter/material.dart';
import '../../../domain/entities/ayah.dart';
import '../../../domain/entities/mushaf_page.dart';
import '../../../domain/entities/reading_theme.dart';
import '../../bloc/mushaf_reader_state.dart';
import 'mobile_mushaf_ayah_text.dart';
import 'mobile_mushaf_basmala.dart';

/// Renders one Mushaf page: any Basmala interleaved with runs of ayahs
/// from the same surah. Each surah-run is wrapped in a GlobalKey so we
/// can scroll to it when audio starts playing an ayah from that surah
/// (coarse auto-scroll: lines up the surah's first ayah on the page).
class MobileMushafPageView extends StatefulWidget {
  final MushafPage page;
  final MushafReaderState state;
  final void Function(Ayah ayah) onAyahTap;

  const MobileMushafPageView({
    super.key,
    required this.page,
    required this.state,
    required this.onAyahTap,
  });

  @override
  State<MobileMushafPageView> createState() => _MobileMushafPageViewState();
}

class _MobileMushafPageViewState extends State<MobileMushafPageView> {
  final Map<int, GlobalKey> _surahRunKeys = {};

  @override
  void didUpdateWidget(MobileMushafPageView oldWidget) {
    super.didUpdateWidget(oldWidget);
    final playingSurah = widget.state.playingSurah;
    if (playingSurah == null) return;
    if (playingSurah == oldWidget.state.playingSurah) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final ctx = _surahRunKeys[playingSurah]?.currentContext;
      if (ctx == null || !mounted) return;
      Scrollable.ensureVisible(
        ctx,
        duration: const Duration(milliseconds: 280),
        curve: Curves.easeInOut,
        alignment: 0.1,
      );
    });
  }

  GlobalKey _keyForSurah(int surahNumber) =>
      _surahRunKeys.putIfAbsent(surahNumber, GlobalKey.new);

  @override
  Widget build(BuildContext context) {
    final runs = _splitBySurah(widget.page.ayahs);
    final palette = ReadingPalette.of(widget.state.readingTheme);

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        decoration: BoxDecoration(
          color: palette.pageBg,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: palette.pageBorder, width: 1.2),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            for (final run in runs)
              Container(
                key: _keyForSurah(run.first.surahNumber),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (run.first.isFirstAyahOfSurah)
                      MobileMushafBasmala(
                        surahNumber: run.first.surahNumber,
                      ),
                    MobileMushafAyahText(
                      ayahs: run,
                      state: widget.state,
                      onTap: widget.onAyahTap,
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  List<List<Ayah>> _splitBySurah(List<Ayah> ayahs) {
    final out = <List<Ayah>>[];
    for (final a in ayahs) {
      if (out.isEmpty || out.last.first.surahNumber != a.surahNumber) {
        out.add([a]);
      } else {
        out.last.add(a);
      }
    }
    return out;
  }
}
