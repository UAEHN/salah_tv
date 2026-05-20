import 'package:flutter/material.dart';

import '../../../../core/app_colors.dart';
import '../../../prayer/presentation/painters/arabesque_painter.dart';

/// Shared minimal announcement layout for mosque-mode takeovers (adhan/iqama).
/// Pure typography on the arabesque ground; no card, no icon. Caller supplies
/// a label and the large prayer-name accent. [labelBelow] places the label
/// after the accent (used by iqama: "[الفجر] إقامة صلاة").
class MosqueAnnouncementScreen extends StatelessWidget {
  final String label;
  final String prayerName;
  final AccentPalette palette;
  final bool labelBelow;

  const MosqueAnnouncementScreen({
    required this.label,
    required this.prayerName,
    required this.palette,
    this.labelBelow = false,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final labelWidget = Text(
      label,
      textAlign: TextAlign.center,
      style: const TextStyle(
        fontSize: 72,
        fontWeight: FontWeight.w600,
        color: Colors.black87,
        height: 1.2,
        letterSpacing: 1.5,
      ),
    );
    final accentWidget = Text(
      prayerName,
      textAlign: TextAlign.center,
      style: TextStyle(
        fontSize: 220,
        fontWeight: FontWeight.w900,
        color: palette.primary,
        height: 1.0,
        letterSpacing: 2,
      ),
    );
    return Container(
      color: Colors.white,
      child: Stack(
        children: [
          Positioned.fill(
            child: RepaintBoundary(
              child: CustomPaint(
                painter: ArabescPainter(color: palette.primary, opacity: 0.10),
              ),
            ),
          ),
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: labelBelow
                  ? [accentWidget, const SizedBox(height: 24), labelWidget]
                  : [labelWidget, const SizedBox(height: 24), accentWidget],
            ),
          ),
        ],
      ),
    );
  }
}
