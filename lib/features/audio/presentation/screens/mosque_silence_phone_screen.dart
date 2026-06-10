import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:ghasaq/l10n/app_localizations.dart';

import '../../../../core/app_colors.dart';
import '../../../prayer/presentation/painters/arabesque_painter.dart';

/// Mosque-mode visual: shown for 10 minutes after iqama ends — i.e. during
/// the prayer itself. Static across all themes: black phone + text, red slash.
class MosqueSilencePhoneScreen extends StatelessWidget {
  static const Color _kRed = Color(0xFFD32F2F);
  static const double _kIconSize = 360;
  static const double _kSlashThickness = 28;

  final AccentPalette palette;

  const MosqueSilencePhoneScreen({required this.palette, super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Container(
      color: Colors.white,
      child: Stack(
        children: [
          Positioned.fill(
            child: RepaintBoundary(
              child: CustomPaint(
                painter: ArabescPainter(color: _kRed, opacity: 0.10),
              ),
            ),
          ),
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const _PhoneWithSlash(),
                const SizedBox(height: 40),
                Text(
                  l.mosqueSilencePhoneText,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 80,
                    fontWeight: FontWeight.w800,
                    color: Colors.black,
                    height: 1.15,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PhoneWithSlash extends StatelessWidget {
  const _PhoneWithSlash();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: MosqueSilencePhoneScreen._kIconSize,
      height: MosqueSilencePhoneScreen._kIconSize,
      child: Stack(
        alignment: Alignment.center,
        children: [
          const Icon(
            Icons.smartphone,
            size: MosqueSilencePhoneScreen._kIconSize,
            color: Colors.black,
          ),
          Transform.rotate(
            angle: -math.pi / 4,
            child: Container(
              width: MosqueSilencePhoneScreen._kIconSize * 0.95,
              height: MosqueSilencePhoneScreen._kSlashThickness,
              decoration: BoxDecoration(
                color: MosqueSilencePhoneScreen._kRed,
                borderRadius: BorderRadius.circular(
                  MosqueSilencePhoneScreen._kSlashThickness / 2,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
