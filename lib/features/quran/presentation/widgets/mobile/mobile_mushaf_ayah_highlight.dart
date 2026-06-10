import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

import '../../../domain/entities/ayah_glyph_bounds.dart';
import '../../../domain/i_ayah_bounds_repository.dart';

/// Semi-transparent overlay that paints a rectangle over every glyph
/// of the currently-playing ayah on the visible page. Lives inside
/// the 1024×1656 FittedBox canvas of [MobileMushafImagePage], so the
/// glyph coordinates straight out of the SQLite are also the local
/// paint coordinates — no scaling required.
///
/// Stateful so we cache the last fetched (page, surah, ayah) → glyphs
/// list. Hopping verses fires one SQLite query; staying on the same
/// verse rebuilds without touching the DB.
class MobileMushafAyahHighlight extends StatefulWidget {
  final int pageNumber;
  final int surah;
  final int ayah;
  final Color color;

  const MobileMushafAyahHighlight({
    super.key,
    required this.pageNumber,
    required this.surah,
    required this.ayah,
    required this.color,
  });

  @override
  State<MobileMushafAyahHighlight> createState() =>
      _MobileMushafAyahHighlightState();
}

class _MobileMushafAyahHighlightState extends State<MobileMushafAyahHighlight> {
  List<AyahGlyphBounds> _glyphs = const [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void didUpdateWidget(covariant MobileMushafAyahHighlight oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.surah != widget.surah ||
        oldWidget.ayah != widget.ayah ||
        oldWidget.pageNumber != widget.pageNumber) {
      _load();
    }
  }

  Future<void> _load() async {
    final repo = GetIt.I<IAyahBoundsRepository>();
    final page = widget.pageNumber;
    final surah = widget.surah;
    final ayah = widget.ayah;
    final glyphs = await repo.glyphsForAyah(
      pageNumber: page,
      sura: surah,
      ayah: ayah,
    );
    if (!mounted) return;
    if (widget.pageNumber != page ||
        widget.surah != surah ||
        widget.ayah != ayah) {
      return;
    }
    setState(() => _glyphs = glyphs);
  }

  @override
  Widget build(BuildContext context) {
    if (_glyphs.isEmpty) return const SizedBox.shrink();
    return IgnorePointer(
      child: CustomPaint(painter: _HighlightPainter(_glyphs, widget.color)),
    );
  }
}

class _HighlightPainter extends CustomPainter {
  final List<AyahGlyphBounds> glyphs;
  final Color color;

  _HighlightPainter(this.glyphs, this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color.withValues(alpha: 0.35);
    for (final g in glyphs) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTRB(
            g.minX.toDouble(),
            g.minY.toDouble(),
            g.maxX.toDouble(),
            g.maxY.toDouble(),
          ),
          const Radius.circular(6),
        ),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _HighlightPainter old) =>
      old.glyphs != glyphs || old.color != color;
}
