import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/widgets/focus_scroll.dart';

/// TV-friendly list row with strong focus visualization (background fill +
/// left/right accent bar). Used inside D-Pad navigable list dialogs.
class TvFocusableListTile extends StatefulWidget {
  final Widget? leading;
  final Widget title;
  final Widget? trailing;
  final VoidCallback onTap;
  final Color accent;
  final bool autofocus;

  const TvFocusableListTile({
    required this.title,
    required this.onTap,
    required this.accent,
    this.leading,
    this.trailing,
    this.autofocus = false,
    super.key,
  });

  @override
  State<TvFocusableListTile> createState() => _TvFocusableListTileState();
}

class _TvFocusableListTileState extends State<TvFocusableListTile> {
  bool _isFocused = false;

  @override
  Widget build(BuildContext context) {
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
          widget.onTap();
          return KeyEventResult.handled;
        }
        return KeyEventResult.ignored;
      },
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 120),
          padding: const EdgeInsetsDirectional.fromSTEB(8, 12, 8, 12),
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
          child: Row(
            children: [
              if (widget.leading != null) ...[
                widget.leading!,
                const SizedBox(width: 12),
              ],
              Expanded(child: widget.title),
              if (widget.trailing != null) ...[
                const SizedBox(width: 12),
                widget.trailing!,
              ],
            ],
          ),
        ),
      ),
    );
  }
}
