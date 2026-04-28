import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Generic TV-focusable wrapper: scale + ring + glow on focus, identical to
/// the visual language used by [TvButton] and the Quran toggle. Wraps any
/// child widget that should be selectable via D-Pad.
class TvFocusableCard extends StatefulWidget {
  final Widget child;
  final VoidCallback onPressed;
  final Color accent;
  final BorderRadius borderRadius;
  final double focusScale;

  const TvFocusableCard({
    required this.child,
    required this.onPressed,
    required this.accent,
    this.borderRadius = const BorderRadius.all(Radius.circular(10)),
    this.focusScale = 1.04,
    super.key,
  });

  @override
  State<TvFocusableCard> createState() => _TvFocusableCardState();
}

class _TvFocusableCardState extends State<TvFocusableCard> {
  bool _isFocused = false;

  @override
  Widget build(BuildContext context) {
    return Focus(
      onFocusChange: (f) => setState(() => _isFocused = f),
      onKeyEvent: (_, event) {
        if (event is KeyDownEvent &&
            (event.logicalKey == LogicalKeyboardKey.select ||
                event.logicalKey == LogicalKeyboardKey.enter)) {
          widget.onPressed();
          return KeyEventResult.handled;
        }
        return KeyEventResult.ignored;
      },
      child: GestureDetector(
        onTap: widget.onPressed,
        child: AnimatedScale(
          scale: _isFocused ? widget.focusScale : 1.0,
          duration: const Duration(milliseconds: 150),
          curve: Curves.easeOut,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            decoration: BoxDecoration(
              borderRadius: widget.borderRadius,
              boxShadow: _isFocused
                  ? [
                      BoxShadow(
                        color: widget.accent.withValues(alpha: 0.55),
                        blurRadius: 18,
                        spreadRadius: 2,
                      ),
                    ]
                  : null,
              border: _isFocused
                  ? Border.all(color: Colors.white, width: 2.5)
                  : null,
            ),
            child: ClipRRect(
              borderRadius: widget.borderRadius,
              child: widget.child,
            ),
          ),
        ),
      ),
    );
  }
}
