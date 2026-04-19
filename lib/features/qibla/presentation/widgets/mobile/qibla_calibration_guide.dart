import 'package:flutter/material.dart';
import 'package:ghasaq/l10n/app_localizations.dart';

import '../../../../../core/mobile_theme.dart';

/// Shown when compass accuracy is low due to magnetic interference.
/// Instructs the user to move the phone in a figure-8 to calibrate.
class QiblaCalibrationGuide extends StatelessWidget {
  const QiblaCalibrationGuide({super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFFF5722).withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFFF5722).withValues(alpha: 0.35),
        ),
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
                  style: MobileTextStyles.labelSm(context).copyWith(
                    color: const Color(0xFFFF5722),
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
                  ),
                  textDirection: TextDirection.rtl,
                ),
                const SizedBox(height: 2),
                Text(
                  l.qiblaCalibrationBody,
                  style: MobileTextStyles.labelSm(context).copyWith(
                    color: MobileColors.onSurfaceMuted(context),
                    fontSize: 11,
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
  late final Animation<double> _rotation;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
    _rotation = Tween<double>(begin: 0, end: 1).animate(_ctrl);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RotationTransition(
      turns: _rotation,
      child: const Icon(
        Icons.screen_rotation_rounded,
        color: Color(0xFFFF5722),
        size: 28,
      ),
    );
  }
}
