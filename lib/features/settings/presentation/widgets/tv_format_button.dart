import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../../../core/app_colors.dart';
import '../settings_provider.dart';

class TvFormatButton extends StatefulWidget {
  final String label;
  final bool isSelected;
  final AccentPalette palette;
  final VoidCallback onPressed;

  const TvFormatButton({
    required this.label,
    required this.isSelected,
    required this.palette,
    required this.onPressed,
    super.key,
  });

  @override
  State<TvFormatButton> createState() => _TvFormatButtonState();
}

class _TvFormatButtonState extends State<TvFormatButton> {
  bool _isFocused = false;

  @override
  Widget build(BuildContext context) {
    final tc = ThemeColors.of(
      context.watch<SettingsProvider>().settings.isDarkMode,
    );
    final isActive = _isFocused || widget.isSelected;
    return Focus(
      onFocusChange: (f) => setState(() => _isFocused = f),
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
          scale: _isFocused ? 1.06 : 1.0,
          duration: const Duration(milliseconds: 150),
          curve: Curves.easeOut,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
            decoration: BoxDecoration(
              gradient: isActive ? widget.palette.gradient : null,
              border: Border.all(
                color: _isFocused
                    ? Colors.white
                    : widget.palette.primary.withValues(alpha: 0.45),
                width: _isFocused ? 3.0 : 1.5,
              ),
              borderRadius: BorderRadius.circular(10),
              boxShadow: _isFocused
                  ? [
                      BoxShadow(
                        color: widget.palette.glow.withValues(alpha: 0.70),
                        blurRadius: 18,
                        spreadRadius: 4,
                      ),
                    ]
                  : widget.isSelected
                      ? [
                          BoxShadow(
                            color: widget.palette.glow.withValues(alpha: 0.40),
                            blurRadius: 12,
                            spreadRadius: 2,
                          ),
                        ]
                      : null,
            ),
            child: Text(
              widget.label,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: isActive ? Colors.white : tc.textMuted,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
