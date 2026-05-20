import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class TvRatingActionButton extends StatefulWidget {
  const TvRatingActionButton({
    required this.label,
    required this.autofocus,
    required this.isPrimary,
    required this.onPressed,
    super.key,
  });

  final String label;
  final bool autofocus;
  final bool isPrimary;
  final VoidCallback onPressed;

  @override
  State<TvRatingActionButton> createState() => _TvRatingActionButtonState();
}

class _TvRatingActionButtonState extends State<TvRatingActionButton> {
  bool _isFocused = false;

  @override
  Widget build(BuildContext context) {
    final bg = widget.isPrimary
        ? (_isFocused ? Colors.amberAccent : Colors.amber)
        : Colors.transparent;
    final borderColor = widget.isPrimary
        ? (_isFocused ? Colors.white : Colors.transparent)
        : (_isFocused ? Colors.amberAccent : Colors.white30);
    final fgColor = widget.isPrimary ? Colors.black : Colors.white;

    return AnimatedScale(
      scale: _isFocused ? 1.06 : 1.0,
      duration: const Duration(milliseconds: 150),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        width: 200,
        height: 44,
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: borderColor,
            width: _isFocused ? 2.5 : 1.5,
          ),
          boxShadow: _isFocused
              ? [
                  BoxShadow(
                    color: Colors.amberAccent.withValues(alpha: 0.55),
                    blurRadius: 14,
                    spreadRadius: 1,
                  ),
                ]
              : null,
        ),
        child: Focus(
          autofocus: widget.autofocus,
          onFocusChange: (v) => setState(() => _isFocused = v),
          onKeyEvent: (node, event) {
            if (event is KeyDownEvent &&
                (event.logicalKey == LogicalKeyboardKey.select ||
                    event.logicalKey == LogicalKeyboardKey.enter ||
                    event.logicalKey == LogicalKeyboardKey.gameButtonA)) {
              widget.onPressed();
              return KeyEventResult.handled;
            }
            return KeyEventResult.ignored;
          },
          child: GestureDetector(
            onTap: widget.onPressed,
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: widget.onPressed,
              child: Center(
                child: Text(
                  widget.label,
                  style: TextStyle(
                    color: fgColor,
                    fontSize: 15,
                    fontWeight: widget.isPrimary
                        ? FontWeight.w700
                        : FontWeight.w500,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
