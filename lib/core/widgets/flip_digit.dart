import 'package:flutter/material.dart';

/// A single digit that slides up when its value changes.
class FlipDigit extends StatefulWidget {
  final String value;
  final double width;
  final double height;
  final TextStyle style;

  const FlipDigit({
    super.key,
    required this.value,
    required this.width,
    required this.height,
    required this.style,
  });

  @override
  State<FlipDigit> createState() => _FlipDigitState();
}

class _FlipDigitState extends State<FlipDigit>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  String _currentValue = '';
  String _previousValue = '';

  @override
  void initState() {
    super.initState();
    _currentValue = widget.value;
    _previousValue = widget.value;
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 450),
    );
  }

  @override
  void didUpdateWidget(FlipDigit old) {
    super.didUpdateWidget(old);
    if (old.value != widget.value) {
      _previousValue = _currentValue;
      _currentValue = widget.value;
      _ctrl.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.width,
      height: widget.height,
      child: ClipRect(
        child: AnimatedBuilder(
          animation: _ctrl,
          builder: (_, _) {
            final t = Curves.easeInOutCubic.transform(_ctrl.value);
            final oldOpacity = (1.0 - t * 2).clamp(0.0, 1.0);
            final newOpacity = ((t - 0.3) / 0.7).clamp(0.0, 1.0);
            return Stack(
              children: [
                Positioned.fill(
                  child: Transform.translate(
                    offset: Offset(0, -widget.height * 0.6 * t),
                    child: Opacity(
                      opacity: oldOpacity,
                      child: Center(
                        child: Text(_previousValue, style: widget.style),
                      ),
                    ),
                  ),
                ),
                Positioned.fill(
                  child: Transform.translate(
                    offset: Offset(0, widget.height * 0.6 * (1 - t)),
                    child: Opacity(
                      opacity: newOpacity,
                      child: Center(
                        child: Text(_currentValue, style: widget.style),
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
