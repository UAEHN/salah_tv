import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'focus_scroll.dart';

/// Generic TV-focusable button.
///   • [filled]=true  → solid accent fill at rest, brightens on focus.
///                      Use for primary CTAs whose [child] is white text/icon.
///   • [filled]=false → transparent fill at rest, neutral surface on focus.
///                      Used for secondary actions whose [child] may carry
///                      accent-colored content that must remain visible.
///
/// Focus indicator is the accent border + soft glow + scale, never an
/// accent-tinted background that would mute accent text/icons.
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
  bool _isFocused = false;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final neutralFocus = isDark
        ? Colors.white.withValues(alpha: 0.07)
        : Colors.black.withValues(alpha: 0.045);
    final restingFill = widget.filled
        ? widget.accent.withValues(alpha: 0.85)
        : Colors.transparent;
    final focusedFill = widget.filled
        ? Color.lerp(widget.accent, Colors.white, 0.10)!
        : neutralFocus;
    return Focus(
      autofocus: widget.autofocus,
      onFocusChange: (f) {
        setState(() => _isFocused = f);
        if (f) ensureFocusedVisible(context);
      },
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
          scale: _isFocused ? 1.05 : 1.0,
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOut,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            curve: Curves.easeOut,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            decoration: BoxDecoration(
              color: _isFocused ? focusedFill : restingFill,
              border: Border.all(
                color: _isFocused
                    ? widget.accent
                    : widget.accent.withValues(alpha: 0.50),
                width: _isFocused ? 2.5 : 1.5,
              ),
              borderRadius: BorderRadius.circular(12),
              boxShadow: _isFocused
                  ? [
                      BoxShadow(
                        color: widget.accent.withValues(alpha: 0.50),
                        blurRadius: 24,
                        spreadRadius: 2,
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
