import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// TV-friendly search input that pairs nicely with a vertical list below it.
///
/// DPAD behaviour:
///   • when focused, ←/→ move the text caret (default TextField),
///   • Enter/Select on Android TV opens the system on-screen keyboard,
///   • ↓ moves focus to the next focusable widget (the first list row),
///   • ↑ from the first list row returns here (handled by Flutter traversal).
class TvSearchBar extends StatefulWidget {
  final String hintText;
  final ValueChanged<String> onChanged;
  final Color accent;
  const TvSearchBar({
    required this.hintText,
    required this.onChanged,
    required this.accent,
    super.key,
  });

  @override
  State<TvSearchBar> createState() => _TvSearchBarState();
}

class _TvSearchBarState extends State<TvSearchBar> {
  final FocusNode _focus = FocusNode(skipTraversal: false);
  final TextEditingController _ctrl = TextEditingController();
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _focus.addListener(() => setState(() => _isFocused = _focus.hasFocus));
  }

  @override
  void dispose() {
    _focus.dispose();
    _ctrl.dispose();
    super.dispose();
  }

  KeyEventResult _onKey(FocusNode node, KeyEvent event) {
    // Forward DPAD-Down/Up to focus traversal. Without this, the TextField
    // swallows arrow keys for caret movement (and on Android TV may open the
    // on-screen keyboard) instead of moving focus to the list above/below.
    if (event is KeyDownEvent) {
      if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
        node.nextFocus();
        return KeyEventResult.handled;
      }
      if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
        node.previousFocus();
        return KeyEventResult.handled;
      }
    }
    return KeyEventResult.ignored;
  }

  void _clear() {
    _ctrl.clear();
    widget.onChanged('');
    _focus.requestFocus();
  }

  @override
  Widget build(BuildContext context) {
    return Focus(
      onKeyEvent: _onKey,
      child: TextField(
        focusNode: _focus,
        controller: _ctrl,
        onChanged: widget.onChanged,
        textInputAction: TextInputAction.search,
        style: const TextStyle(color: Colors.white, fontSize: 17),
        decoration: InputDecoration(
          hintText: widget.hintText,
          hintStyle: const TextStyle(color: Colors.white38),
          prefixIcon: Icon(
            Icons.search_rounded,
            color: _isFocused ? widget.accent : Colors.white54,
          ),
          suffixIcon: _ctrl.text.isEmpty
              ? null
              : IconButton(
                  icon: const Icon(Icons.close_rounded, color: Colors.white54),
                  onPressed: _clear,
                  tooltip: 'Clear',
                ),
          filled: true,
          fillColor: Colors.white.withValues(alpha: 0.05),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 14,
            vertical: 10,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.white12),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: widget.accent, width: 2),
          ),
        ),
      ),
    );
  }
}
