import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class TvLocationOptionTile extends StatefulWidget {
  final String title;
  final bool isSelected;
  final bool isBusy;
  final bool autofocus;
  final VoidCallback onPressed;

  const TvLocationOptionTile({
    required this.title,
    required this.isSelected,
    required this.isBusy,
    required this.onPressed,
    this.autofocus = false,
    super.key,
  });

  @override
  State<TvLocationOptionTile> createState() => _TvLocationOptionTileState();
}

class _TvLocationOptionTileState extends State<TvLocationOptionTile> {
  bool _isFocused = false;

  @override
  Widget build(BuildContext context) {
    final isActive = _isFocused || widget.isSelected;
    return Focus(
      autofocus: widget.autofocus,
      onFocusChange: (isFocused) => setState(() => _isFocused = isFocused),
      onKeyEvent: (_, event) {
        if (widget.isBusy) return KeyEventResult.ignored;
        if (event is KeyDownEvent &&
            (event.logicalKey == LogicalKeyboardKey.select ||
                event.logicalKey == LogicalKeyboardKey.enter)) {
          widget.onPressed();
          return KeyEventResult.handled;
        }
        return KeyEventResult.ignored;
      },
      child: GestureDetector(
        onTap: widget.isBusy ? null : widget.onPressed,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 140),
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
          decoration: BoxDecoration(
            color: isActive
                ? const Color(0xFF1B4E7A)
                : Colors.white.withValues(alpha: 0.04),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isActive ? Colors.white : Colors.white12,
              width: isActive ? 2 : 1,
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  widget.title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              if (widget.isBusy)
                const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              else if (widget.isSelected)
                const Icon(Icons.check_circle_rounded, color: Colors.white),
            ],
          ),
        ),
      ),
    );
  }
}
