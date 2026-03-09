import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../../../core/app_colors.dart';
import '../settings_provider.dart';

class TvColorChip extends StatefulWidget {
  final AccentPalette palette;
  final String label;
  final bool isSelected;
  final VoidCallback onPressed;

  const TvColorChip({
    required this.palette,
    required this.label,
    required this.isSelected,
    required this.onPressed,
    super.key,
  });

  @override
  State<TvColorChip> createState() => _TvColorChipState();
}

class _TvColorChipState extends State<TvColorChip> {
  bool _focused = false;

  @override
  Widget build(BuildContext context) {
    final tc = ThemeColors.of(
      context.watch<SettingsProvider>().settings.isDarkMode,
    );
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
          scale: _focused ? 1.15 : 1.0,
          duration: const Duration(milliseconds: 150),
          curve: Curves.easeOut,
          child: Column(
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  gradient: widget.palette.gradient,
                  borderRadius: BorderRadius.circular(14),
                  border: _focused
                      ? Border.all(color: Colors.white, width: 4.5)
                      : widget.isSelected
                          ? Border.all(color: widget.palette.secondary, width: 2.5)
                          : Border.all(color: Colors.transparent, width: 2),
                  boxShadow: _focused
                      ? [
                          BoxShadow(
                            color: widget.palette.secondary.withValues(alpha: 0.95),
                            blurRadius: 0,
                            spreadRadius: 4,
                          ),
                          BoxShadow(
                            color: widget.palette.glow.withValues(alpha: 0.85),
                            blurRadius: 24,
                            spreadRadius: 6,
                          ),
                        ]
                      : widget.isSelected
                          ? [
                              BoxShadow(
                                color: widget.palette.glow,
                                blurRadius: 18,
                                spreadRadius: 3,
                              ),
                            ]
                          : null,
                ),
                child: widget.isSelected
                    ? const Icon(Icons.check_rounded, color: Colors.white, size: 36)
                    : null,
              ),
              const SizedBox(height: 8),
              AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 150),
                style: TextStyle(
                  fontSize: 15,
                  color: (_focused || widget.isSelected) ? tc.textPrimary : tc.textMuted,
                  fontWeight: (_focused || widget.isSelected)
                      ? FontWeight.w700
                      : FontWeight.w400,
                ),
                child: Text(widget.label),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
