import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/widgets/focus_scroll.dart';

/// Generic TV-focusable wrapper: scale + accent ring + soft glow on focus.
/// Matches the visual language of [TvButton] and [TvSwitchRow]; the focus ring
/// is intentionally accent-colored (not white) so it integrates cleanly with
/// child contents that may themselves carry accent-colored text or icons.
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
    this.focusScale = 1.03,
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
          scale: _isFocused ? widget.focusScale : 1.0,
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOut,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            curve: Curves.easeOut,
            decoration: BoxDecoration(
              borderRadius: widget.borderRadius,
              boxShadow: _isFocused
                  ? [
                      BoxShadow(
                        color: widget.accent.withValues(alpha: 0.50),
                        blurRadius: 22,
                        spreadRadius: 2,
                      ),
                    ]
                  : null,
              border: _isFocused
                  ? Border.all(color: widget.accent, width: 2.5)
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
