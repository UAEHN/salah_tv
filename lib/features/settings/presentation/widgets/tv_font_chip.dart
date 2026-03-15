import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../../../core/app_colors.dart';
import '../settings_provider.dart';

class TvFontChip extends StatefulWidget {
  final String fontKey;
  final String label;
  final bool isSelected;
  final AccentPalette palette;
  final VoidCallback onPressed;

  const TvFontChip({
    required this.fontKey,
    required this.label,
    required this.isSelected,
    required this.palette,
    required this.onPressed,
    super.key,
  });

  @override
  State<TvFontChip> createState() => _TvFontChipState();
}

class _TvFontChipState extends State<TvFontChip> {
  bool _isFocused = false;

  @override
  Widget build(BuildContext context) {
    final isDark = context.watch<SettingsProvider>().settings.isDarkMode;
    final tc = ThemeColors.of(isDark);
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
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            decoration: BoxDecoration(
              gradient: isActive ? widget.palette.gradient : null,
              color: isActive
                  ? null
                  : widget.palette.primary.withValues(alpha: 0.05),
              border: Border.all(
                color: _isFocused
                    ? Colors.white
                    : widget.isSelected
                        ? widget.palette.primary
                        : widget.palette.primary.withValues(alpha: 0.30),
                width: _isFocused ? 3.0 : widget.isSelected ? 2.0 : 1.5,
              ),
              borderRadius: BorderRadius.circular(14),
              boxShadow: isActive
                  ? [
                      BoxShadow(
                        color: widget.palette.glow
                            .withValues(alpha: _isFocused ? 0.75 : 0.40),
                        blurRadius: _isFocused ? 22 : 16,
                        spreadRadius: _isFocused ? 4 : 2,
                      ),
                    ]
                  : null,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'أبجد هوز',
                  style: TextStyle(
                    fontFamily: widget.fontKey,
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: isActive ? Colors.white : tc.textPrimary,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  widget.label,
                  style: TextStyle(
                    fontSize: 14,
                    color: isActive
                        ? Colors.white.withValues(alpha: 0.85)
                        : tc.textMuted,
                  ),
                ),
                if (widget.isSelected) ...[
                  const SizedBox(height: 4),
                  Icon(
                    Icons.check_circle_rounded,
                    color: Colors.white.withValues(alpha: 0.9),
                    size: 18,
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
