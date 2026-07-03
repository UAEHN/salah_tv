import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../../core/app_colors.dart';
import '../../../../../core/widgets/focus_scroll.dart';

/// A selectable sound row in the TV sound picker. Shows a selected check and,
/// for user-imported sounds, a focusable trailing delete button. Mirrors the
/// [TvButton] focus idiom for consistent D-pad navigation.
class TvSoundPickerTile extends StatefulWidget {
  final String label;
  final bool isSelected;
  final AccentPalette palette;
  final bool autofocus;
  final bool isPreviewing;
  final VoidCallback onSelect;
  final VoidCallback? onPreview;
  final VoidCallback? onDelete;

  const TvSoundPickerTile({
    required this.label,
    required this.isSelected,
    required this.palette,
    required this.onSelect,
    this.onPreview,
    this.onDelete,
    this.isPreviewing = false,
    this.autofocus = false,
    super.key,
  });

  @override
  State<TvSoundPickerTile> createState() => _TvSoundPickerTileState();
}

class _TvSoundPickerTileState extends State<TvSoundPickerTile> {
  bool _isFocused = false;

  @override
  Widget build(BuildContext context) {
    final accent = widget.palette.primary;
    return Row(
      children: [
        Expanded(
          child: Focus(
            autofocus: widget.autofocus,
            onFocusChange: (f) {
              setState(() => _isFocused = f);
              if (f) ensureFocusedVisible(context);
            },
            onKeyEvent: (_, e) => _activateOn(e, widget.onSelect),
            child: GestureDetector(
              onTap: widget.onSelect,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 160),
                curve: Curves.easeOut,
                margin: const EdgeInsets.symmetric(vertical: 3),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
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
                    Icon(
                      widget.isSelected
                          ? Icons.check_circle_rounded
                          : Icons.music_note_rounded,
                      color: widget.isSelected ? accent : Colors.white38,
                      size: 22,
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Text(
                        widget.label,
                        style: TextStyle(
                          fontSize: 18,
                          color: widget.isSelected ? accent : Colors.white,
                          fontWeight: widget.isSelected
                              ? FontWeight.w700
                              : FontWeight.normal,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        if (widget.onPreview != null)
          _IconActionButton(
            icon: widget.isPreviewing
                ? Icons.stop_rounded
                : Icons.play_arrow_rounded,
            color: accent,
            onTap: widget.onPreview!,
          ),
        if (widget.onDelete != null)
          _IconActionButton(
            icon: Icons.delete_outline_rounded,
            color: Colors.redAccent,
            onTap: widget.onDelete!,
          ),
      ],
    );
  }

  KeyEventResult _activateOn(KeyEvent e, VoidCallback action) {
    if (e is KeyDownEvent &&
        (e.logicalKey == LogicalKeyboardKey.select ||
            e.logicalKey == LogicalKeyboardKey.enter)) {
      action();
      return KeyEventResult.handled;
    }
    return KeyEventResult.ignored;
  }
}

/// Focusable circular icon action (preview / delete) inside a picker row.
class _IconActionButton extends StatefulWidget {
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  const _IconActionButton({
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  State<_IconActionButton> createState() => _IconActionButtonState();
}

class _IconActionButtonState extends State<_IconActionButton> {
  bool _isFocused = false;

  @override
  Widget build(BuildContext context) {
    return Focus(
      onFocusChange: (f) => setState(() => _isFocused = f),
      onKeyEvent: (_, e) {
        if (e is KeyDownEvent &&
            (e.logicalKey == LogicalKeyboardKey.select ||
                e.logicalKey == LogicalKeyboardKey.enter)) {
          widget.onTap();
          return KeyEventResult.handled;
        }
        return KeyEventResult.ignored;
      },
      child: GestureDetector(
        onTap: widget.onTap,
        child: Container(
          margin: const EdgeInsets.only(right: 8),
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: _isFocused
                ? widget.color.withValues(alpha: 0.25)
                : Colors.transparent,
            border: Border.all(
              color: _isFocused ? widget.color : Colors.transparent,
              width: 2,
            ),
          ),
          child: Icon(widget.icon, color: widget.color, size: 22),
        ),
      ),
    );
  }
}
