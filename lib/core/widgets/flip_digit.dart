import 'package:flutter/material.dart';

/// A single digit that slides up when its value changes.
///
/// The child [Text] is built once per value change, not per frame, and the
/// animation is driven by stock [SlideTransition] + [FadeTransition].
/// The previous implementation created a new [TextStyle] every frame during
/// the 450 ms transition; on TV boxes that churned Skia's paragraph/shader
/// caches and caused a slow GPU memory leak that froze the UI after hours.
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
  late final AnimationController _ctrl;
  late final Animation<Offset> _slideOut;
  late final Animation<Offset> _slideIn;
  late final Animation<double> _fadeOut;
  late final Animation<double> _fadeIn;
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
      value: 1.0, // idle at final position, previous digit fully faded.
    );
    final curve = CurvedAnimation(parent: _ctrl, curve: Curves.easeInOutCubic);
    _slideOut = Tween<Offset>(
      begin: Offset.zero,
      end: const Offset(0, -0.6),
    ).animate(curve);
    _slideIn = Tween<Offset>(
      begin: const Offset(0, 0.6),
      end: Offset.zero,
    ).animate(curve);
    _fadeOut = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _ctrl,
        curve: const Interval(0.0, 0.5, curve: Curves.easeInOutCubic),
      ),
    );
    _fadeIn = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _ctrl,
        curve: const Interval(0.3, 1.0, curve: Curves.easeInOutCubic),
      ),
    );
  }

  @override
  void didUpdateWidget(FlipDigit old) {
    super.didUpdateWidget(old);
    if (old.value != widget.value) {
      setState(() {
        _previousValue = _currentValue;
        _currentValue = widget.value;
      });
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
    // RepaintBoundary isolates the 60 fps transition to this digit only so
    // sibling digits and parents keep their cached layers.
    return RepaintBoundary(
      child: SizedBox(
        width: widget.width,
        height: widget.height,
        child: ClipRect(
          clipBehavior: Clip.hardEdge,
          child: Stack(
            children: [
              Positioned.fill(
                child: SlideTransition(
                  position: _slideOut,
                  child: FadeTransition(
                    opacity: _fadeOut,
                    child: Center(
                      child: Text(_previousValue, style: widget.style),
                    ),
                  ),
                ),
              ),
              Positioned.fill(
                child: SlideTransition(
                  position: _slideIn,
                  child: FadeTransition(
                    opacity: _fadeIn,
                    child: Center(
                      child: Text(_currentValue, style: widget.style),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
