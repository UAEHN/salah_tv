import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/app_colors.dart';

class TvSmallButton extends StatefulWidget {
  final IconData icon;
  final AccentPalette palette;
  final VoidCallback onPressed;

  const TvSmallButton({
    required this.icon,
    required this.palette,
    required this.onPressed,
    super.key,
  });

  @override
  State<TvSmallButton> createState() => _TvSmallButtonState();
}

class _TvSmallButtonState extends State<TvSmallButton> {
  bool _focused = false;

  @override
  Widget build(BuildContext context) {
    return Focus(
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
          scale: _focused ? 1.30 : 1.0,
          duration: const Duration(milliseconds: 150),
          curve: Curves.easeOut,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              gradient: _focused ? widget.palette.gradient : null,
              color: _focused
                  ? null
                  : widget.palette.primary.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: _focused
                    ? Colors.white
                    : widget.palette.primary.withValues(alpha: 0.35),
                width: _focused ? 2.5 : 1.0,
              ),
              boxShadow: _focused
                  ? [
                      BoxShadow(
                        color: widget.palette.glow.withValues(alpha: 0.85),
                        blurRadius: 18,
                        spreadRadius: 5,
                      ),
                    ]
                  : null,
            ),
            child: Icon(
              widget.icon,
              color: _focused ? Colors.white : widget.palette.primary,
              size: 22,
            ),
          ),
        ),
      ),
    );
  }
}
