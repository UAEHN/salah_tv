import 'package:flutter/material.dart';
import 'package:ghasaq/l10n/app_localizations.dart';

import '../../../../../core/mobile_theme.dart';

const _warn = Color(0xFFD9534F);

/// Shown when compass accuracy is low. Instructs the user to move the
/// phone in a figure-8 to recalibrate the magnetometer.
class QiblaCalibrationGuide extends StatelessWidget {
  const QiblaCalibrationGuide({super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final isDark = MobileColors.isDark(context);
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withValues(alpha: 0.04)
            : _warn.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _warn.withValues(alpha: 0.40), width: 1),
      ),
      child: Row(
        textDirection: TextDirection.rtl,
        children: [
          const _Figure8Icon(),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  l.qiblaCalibrationTitle,
                  style: const TextStyle(
                    color: _warn,
                    fontSize: 12.5,
                    fontWeight: FontWeight.w700,
                  ),
                  textDirection: TextDirection.rtl,
                ),
                const SizedBox(height: 3),
                Text(
                  l.qiblaCalibrationBody,
                  style: TextStyle(
                    color: MobileColors.onSurfaceMuted(context),
                    fontSize: 11.5,
                    height: 1.5,
                  ),
                  textDirection: TextDirection.rtl,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Figure8Icon extends StatefulWidget {
  const _Figure8Icon();

  @override
  State<_Figure8Icon> createState() => _Figure8IconState();
}

class _Figure8IconState extends State<_Figure8Icon>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RotationTransition(
      turns: _ctrl,
      child: const Icon(Icons.screen_rotation_rounded, color: _warn, size: 26),
    );
  }
}
