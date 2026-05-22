import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../../core/mobile_theme.dart';

/// Round +/- button with haptics and hold-to-repeat used by the prayer
/// offsets row. Public so it can live in its own file under the 150-line cap.
class MobilePrayerOffsetStepperButton extends StatefulWidget {
  final IconData icon;
  final bool enabled;
  final VoidCallback onStep;
  final Color color;

  const MobilePrayerOffsetStepperButton({
    super.key,
    required this.icon,
    required this.enabled,
    required this.onStep,
    required this.color,
  });

  @override
  State<MobilePrayerOffsetStepperButton> createState() =>
      _StepperButtonState();
}

class _StepperButtonState extends State<MobilePrayerOffsetStepperButton> {
  Timer? _holdTimer;
  bool _pressed = false;

  @override
  void dispose() {
    _holdTimer?.cancel();
    super.dispose();
  }

  void _startHold() {
    _holdTimer?.cancel();
    _holdTimer = Timer.periodic(const Duration(milliseconds: 90), (_) {
      if (!widget.enabled) {
        _stopHold();
        return;
      }
      widget.onStep();
    });
  }

  void _stopHold() {
    _holdTimer?.cancel();
    _holdTimer = null;
  }

  void _setPressed(bool v) {
    if (_pressed != v) setState(() => _pressed = v);
  }

  @override
  Widget build(BuildContext context) {
    final bg = widget.enabled
        ? widget.color.withValues(
            alpha: _pressed
                ? 0.32
                : (MobileColors.isDark(context) ? 0.20 : 0.14),
          )
        : MobileColors.border(context).withValues(alpha: 0.5);
    final fg = widget.enabled
        ? widget.color
        : MobileColors.onSurfaceFaint(context);

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: widget.enabled ? widget.onStep : null,
      onTapDown: widget.enabled ? (_) => _setPressed(true) : null,
      onTapCancel: () => _setPressed(false),
      onTapUp: (_) => _setPressed(false),
      onLongPressStart: widget.enabled
          ? (_) {
              HapticFeedback.mediumImpact();
              _setPressed(true);
              _startHold();
            }
          : null,
      onLongPressEnd: (_) {
        _stopHold();
        _setPressed(false);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 120),
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: bg,
          shape: BoxShape.circle,
          border: Border.all(
            color: widget.enabled
                ? widget.color.withValues(alpha: 0.32)
                : Colors.transparent,
            width: 1,
          ),
        ),
        alignment: Alignment.center,
        child: Icon(widget.icon, size: 22, color: fg),
      ),
    );
  }
}
