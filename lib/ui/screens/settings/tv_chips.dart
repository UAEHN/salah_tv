part of '../settings_screen.dart';

// ─── TV-compatible selection chip widgets ────────────────────────────────────

class _TvColorChip extends StatefulWidget {
  final AccentPalette palette;
  final String label;
  final bool isSelected;
  final VoidCallback onPressed;

  const _TvColorChip({
    required this.palette,
    required this.label,
    required this.isSelected,
    required this.onPressed,
  });

  @override
  State<_TvColorChip> createState() => _TvColorChipState();
}

class _TvColorChipState extends State<_TvColorChip> {
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
                          ? Border.all(
                              color: widget.palette.secondary, width: 2.5)
                          : Border.all(color: Colors.transparent, width: 2),
                  boxShadow: _focused
                      ? [
                          BoxShadow(
                            color: widget.palette.secondary
                                .withValues(alpha: 0.95),
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
                    ? const Icon(Icons.check_rounded,
                        color: Colors.white, size: 36)
                    : null,
              ),
              const SizedBox(height: 8),
              AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 150),
                style: TextStyle(
                  fontSize: 15,
                  color: (_focused || widget.isSelected)
                      ? kTextPrimary
                      : kTextMuted,
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

class _TvFormatButton extends StatefulWidget {
  final String label;
  final bool isSelected;
  final AccentPalette palette;
  final VoidCallback onPressed;

  const _TvFormatButton({
    required this.label,
    required this.isSelected,
    required this.palette,
    required this.onPressed,
  });

  @override
  State<_TvFormatButton> createState() => _TvFormatButtonState();
}

class _TvFormatButtonState extends State<_TvFormatButton> {
  bool _focused = false;

  @override
  Widget build(BuildContext context) {
    // Active when focused OR selected — both show gradient + white text
    final isActive = _focused || widget.isSelected;

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
          scale: _focused ? 1.06 : 1.0,
          duration: const Duration(milliseconds: 150),
          curve: Curves.easeOut,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            padding:
                const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
            decoration: BoxDecoration(
              // Focused OR selected → full gradient → white text guaranteed
              gradient: isActive ? widget.palette.gradient : null,
              border: Border.all(
                color: _focused
                    ? Colors.white
                    : widget.palette.primary.withValues(alpha: 0.45),
                width: _focused ? 3.0 : 1.5,
              ),
              borderRadius: BorderRadius.circular(10),
              boxShadow: _focused
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
                // Always white on gradient, muted otherwise
                color: isActive ? Colors.white : kTextMuted,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _TvFontChip extends StatefulWidget {
  final String fontKey;
  final String label;
  final bool isSelected;
  final AccentPalette palette;
  final VoidCallback onPressed;

  const _TvFontChip({
    required this.fontKey,
    required this.label,
    required this.isSelected,
    required this.palette,
    required this.onPressed,
  });

  @override
  State<_TvFontChip> createState() => _TvFontChipState();
}

class _TvFontChipState extends State<_TvFontChip> {
  bool _focused = false;

  @override
  Widget build(BuildContext context) {
    // Active when focused OR selected — both show gradient + white text
    final isActive = _focused || widget.isSelected;

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
          scale: _focused ? 1.06 : 1.0,
          duration: const Duration(milliseconds: 150),
          curve: Curves.easeOut,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            padding:
                const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            decoration: BoxDecoration(
              // Focused OR selected → full gradient → all text turns white
              gradient: isActive ? widget.palette.gradient : null,
              color: isActive
                  ? null
                  : widget.palette.primary.withValues(alpha: 0.05),
              border: Border.all(
                color: _focused
                    ? Colors.white
                    : widget.isSelected
                        ? widget.palette.primary
                        : widget.palette.primary.withValues(alpha: 0.30),
                width: _focused ? 3.0 : widget.isSelected ? 2.0 : 1.5,
              ),
              borderRadius: BorderRadius.circular(14),
              boxShadow: isActive
                  ? [
                      BoxShadow(
                        color: widget.palette.glow
                            .withValues(alpha: _focused ? 0.75 : 0.40),
                        blurRadius: _focused ? 22 : 16,
                        spreadRadius: _focused ? 4 : 2,
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
                    // Always white when active (focused/selected)
                    color: isActive ? Colors.white : kTextPrimary,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  widget.label,
                  style: TextStyle(
                    fontSize: 14,
                    color: isActive
                        ? Colors.white.withValues(alpha: 0.85)
                        : kTextMuted,
                  ),
                ),
                if (widget.isSelected) ...[
                  const SizedBox(height: 4),
                  Icon(Icons.check_circle_rounded,
                      color: Colors.white.withValues(alpha: 0.9), size: 18),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
