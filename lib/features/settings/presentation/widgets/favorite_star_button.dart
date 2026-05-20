import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/widgets/focus_scroll.dart';

/// TV-focusable star toggle. Renders a filled star when [isFavorite], an
/// outline star otherwise. OK / Enter triggers [onToggle]; the surrounding
/// Focus widget keeps it reachable via D-pad RIGHT/LEFT inside a row.
class FavoriteStarButton extends StatefulWidget {
  final bool isFavorite;
  final Color accent;
  final VoidCallback onToggle;

  const FavoriteStarButton({
    required this.isFavorite,
    required this.accent,
    required this.onToggle,
    super.key,
  });

  @override
  State<FavoriteStarButton> createState() => _FavoriteStarButtonState();
}

class _FavoriteStarButtonState extends State<FavoriteStarButton> {
  bool _isFocused = false;

  @override
  Widget build(BuildContext context) {
    final filled = widget.isFavorite;
    return Focus(
      onFocusChange: (f) {
        setState(() => _isFocused = f);
        if (f) ensureFocusedVisible(context);
      },
      onKeyEvent: (_, event) {
        if (event is KeyDownEvent &&
            (event.logicalKey == LogicalKeyboardKey.select ||
                event.logicalKey == LogicalKeyboardKey.enter)) {
          widget.onToggle();
          return KeyEventResult.handled;
        }
        return KeyEventResult.ignored;
      },
      child: GestureDetector(
        onTap: widget.onToggle,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 120),
          width: 44,
          height: 44,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: _isFocused
                ? widget.accent.withValues(alpha: 0.22)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: _isFocused ? widget.accent : Colors.transparent,
              width: 2,
            ),
          ),
          child: Icon(
            filled ? Icons.star_rounded : Icons.star_border_rounded,
            color: filled ? widget.accent : Colors.white54,
            size: 26,
          ),
        ),
      ),
    );
  }
}
