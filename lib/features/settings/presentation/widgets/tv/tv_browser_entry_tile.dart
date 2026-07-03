import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../../core/app_colors.dart';
import '../../../../../core/widgets/focus_scroll.dart';

/// One focusable row in the TV audio browser. Folders show a chevron; audio
/// files show a music-note. Mirrors [TvButton]'s focus idiom (accent border +
/// scroll-into-view) so D-pad navigation feels consistent.
class TvBrowserEntryTile extends StatefulWidget {
  final IconData icon;
  final String label;
  final AccentPalette palette;
  final bool autofocus;
  final VoidCallback onTap;

  const TvBrowserEntryTile({
    required this.icon,
    required this.label,
    required this.palette,
    required this.onTap,
    this.autofocus = false,
    super.key,
  });

  @override
  State<TvBrowserEntryTile> createState() => _TvBrowserEntryTileState();
}

class _TvBrowserEntryTileState extends State<TvBrowserEntryTile> {
  bool _isFocused = false;

  @override
  Widget build(BuildContext context) {
    final accent = widget.palette.primary;
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
          duration: const Duration(milliseconds: 160),
          curve: Curves.easeOut,
          margin: const EdgeInsets.symmetric(vertical: 3),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: _isFocused ? accent.withValues(alpha: 0.18) : null,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: _isFocused ? accent : Colors.transparent,
              width: 2,
            ),
          ),
          child: Row(
            children: [
              Icon(widget.icon, color: accent, size: 22),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  widget.label,
                  style: const TextStyle(fontSize: 18, color: Colors.white),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
