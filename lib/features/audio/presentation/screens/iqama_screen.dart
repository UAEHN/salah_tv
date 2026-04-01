import 'package:flutter/material.dart';
import 'package:ghasaq/l10n/app_localizations.dart';
import '../../../../core/app_colors.dart';
import '../../../prayer/presentation/painters/arabesque_painter.dart';

class IqamaScreen extends StatelessWidget {
  final String prayerName;
  final AccentPalette palette;

  const IqamaScreen({
    super.key,
    required this.prayerName,
    required this.palette,
  });

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Container(
      color: Colors.white,
      child: Stack(
        children: [
          // Background pattern
          Positioned.fill(
            child: CustomPaint(
              painter: ArabescPainter(color: palette.primary, opacity: 0.1),
            ),
          ),

          // Gradient overlay
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment.center,
                  radius: 1.2,
                  colors: [
                    palette.primary.withValues(alpha: 0.1),
                    Colors.white,
                  ],
                ),
              ),
            ),
          ),

          // Content
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.mosque_rounded, size: 100, color: palette.primary),
                const SizedBox(height: 30),
                Text(
                  l.iqamaNowTitle,
                  style: TextStyle(
                    fontSize: 40,
                    fontWeight: FontWeight.w500,
                    color: kTextSecondary,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  prayerName,
                  style: TextStyle(
                    fontSize: 80,
                    fontWeight: FontWeight.w800,
                    color: palette.primary,
                    shadows: [Shadow(color: palette.glow, blurRadius: 20)],
                  ),
                ),
                const SizedBox(height: 16),
                // Iqama label
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 28,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: palette.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(
                      color: palette.primary.withValues(alpha: 0.3),
                      width: 1.5,
                    ),
                  ),
                  child: Text(
                    l.iqamaLabel,
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w700,
                      color: palette.primary,
                    ),
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
