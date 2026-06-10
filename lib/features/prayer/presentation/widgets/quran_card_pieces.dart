import 'package:flutter/material.dart';

/// Pulsing red dot indicating live Quran playback.
class LiveDot extends StatefulWidget {
  final Color color;
  const LiveDot({required this.color, super.key});
  @override
  State<LiveDot> createState() => _LiveDotState();
}

class _LiveDotState extends State<LiveDot> with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1100),
  )..repeat(reverse: true);

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: _ctrl,
    builder: (_, _) {
      final t = _ctrl.value;
      return Container(
        width: 9,
        height: 9,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: widget.color.withValues(alpha: 0.55 + 0.45 * t),
          boxShadow: [
            BoxShadow(
              color: widget.color.withValues(alpha: 0.55 * t),
              blurRadius: 6 * t,
              spreadRadius: 1.5 * t,
            ),
          ],
        ),
      );
    },
  );
}
