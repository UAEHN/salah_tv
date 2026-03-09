import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class TvButton extends StatefulWidget {
  final Widget child;
  final VoidCallback onPressed;
  final Color accent;
  final bool filled;
  final bool autofocus;

  const TvButton({
    required this.child,
    required this.onPressed,
    required this.accent,
    this.filled = false,
    this.autofocus = false,
    super.key,
  });

  @override
  State<TvButton> createState() => _TvButtonState();
}

class _TvButtonState extends State<TvButton> {
  bool _focused = false;

  @override
  Widget build(BuildContext context) {
    return Focus(
      autofocus: widget.autofocus,
      onFocusChange: (f) => setState(() => _focused = f),
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
          scale: _focused ? 1.06 : 1.0,
          duration: const Duration(milliseconds: 150),
          curve: Curves.easeOut,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            decoration: BoxDecoration(
              color: _focused
                  ? widget.accent
                  : (widget.filled
                      ? widget.accent.withValues(alpha: 0.85)
                      : Colors.transparent),
              border: Border.all(
                color: _focused
                    ? Colors.white
                    : widget.accent.withValues(alpha: 0.50),
                width: _focused ? 2.5 : 1.5,
              ),
              borderRadius: BorderRadius.circular(10),
              boxShadow: _focused
                  ? [
                      BoxShadow(
                        color: widget.accent.withValues(alpha: 0.60),
                        blurRadius: 22,
                        spreadRadius: 4,
                      ),
                    ]
                  : null,
            ),
            child: widget.child,
          ),
        ),
      ),
    );
  }
}
