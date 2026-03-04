part of '../settings_screen.dart';

// ─── Reusable TV-compatible button widgets ────────────────────────────────────

class _TvButton extends StatefulWidget {
  final Widget child;
  final VoidCallback onPressed;
  final Color accent;
  final bool filled;
  final bool autofocus;

  const _TvButton({
    required this.child,
    required this.onPressed,
    required this.accent,
    this.filled = false,
    this.autofocus = false,
  });

  @override
  State<_TvButton> createState() => _TvButtonState();
}

class _TvButtonState extends State<_TvButton> {
  bool _focused = false;

  @override
  Widget build(BuildContext context) {
    return Focus(
      autofocus: widget.autofocus,
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
        // Scale up on focus → clear "pop" effect on TV
        child: AnimatedScale(
          scale: _focused ? 1.06 : 1.0,
          duration: const Duration(milliseconds: 150),
          curve: Curves.easeOut,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            decoration: BoxDecoration(
              // Focused: full solid accent bg so white text is always readable
              color: _focused
                  ? widget.accent
                  : (widget.filled
                      ? widget.accent.withValues(alpha: 0.85)
                      : Colors.transparent),
              border: Border.all(
                color: _focused
                    ? Colors.white
                    : widget.accent.withValues(alpha: 0.50),
                width: _focused ? 2.5 : 1.5,
              ),
              borderRadius: BorderRadius.circular(10),
              boxShadow: _focused
                  ? [
                      BoxShadow(
                        color: widget.accent.withValues(alpha: 0.60),
                        blurRadius: 22,
                        spreadRadius: 4,
                      ),
                    ]
                  : null,
            ),
            child: widget.child,
          ),
        ),
      ),
    );
  }
}

// ─── TV-compatible switch row (whole row is one focusable unit) ───────────────

class _TvSwitchRow extends StatefulWidget {
  final List<Widget> children;
  final bool value;
  final ValueChanged<bool> onChanged;
  final Color accent;

  const _TvSwitchRow({
    required this.children,
    required this.value,
    required this.onChanged,
    required this.accent,
  });

  @override
  State<_TvSwitchRow> createState() => _TvSwitchRowState();
}

class _TvSwitchRowState extends State<_TvSwitchRow> {
  bool _focused = false;

  @override
  Widget build(BuildContext context) {
    return Focus(
      onFocusChange: (f) => setState(() => _focused = f),
      onKeyEvent: (_, event) {
        if (event is KeyDownEvent &&
            (event.logicalKey == LogicalKeyboardKey.select ||
                event.logicalKey == LogicalKeyboardKey.enter)) {
          widget.onChanged(!widget.value);
          return KeyEventResult.handled;
        }
        return KeyEventResult.ignored;
      },
      child: GestureDetector(
        onTap: () => widget.onChanged(!widget.value),
        child: AnimatedScale(
          scale: _focused ? 1.02 : 1.0,
          duration: const Duration(milliseconds: 150),
          curve: Curves.easeOut,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            decoration: BoxDecoration(
              color: _focused
                  ? widget.accent.withValues(alpha: 0.13)
                  : Colors.black.withValues(alpha: 0.03),
              border: Border.all(
                color: _focused
                    ? widget.accent
                    : widget.accent.withValues(alpha: 0.22),
                width: _focused ? 3.5 : 1.0,
              ),
              borderRadius: BorderRadius.circular(12),
              boxShadow: _focused
                  ? [
                      BoxShadow(
                        color: widget.accent.withValues(alpha: 0.50),
                        blurRadius: 20,
                        spreadRadius: 4,
                      ),
                    ]
                  : null,
            ),
            // ExcludeFocus prevents the Switch from stealing TV focus from the row
            child: ExcludeFocus(
              child: Row(children: widget.children),
            ),
          ),
        ),
      ),
    );
  }
}

// ─── +/− small buttons (iqama delays & adhan offsets) ────────────────────────

class _TvSmallButton extends StatefulWidget {
  final IconData icon;
  final AccentPalette palette;
  final VoidCallback onPressed;

  const _TvSmallButton({
    required this.icon,
    required this.palette,
    required this.onPressed,
  });

  @override
  State<_TvSmallButton> createState() => _TvSmallButtonState();
}

class _TvSmallButtonState extends State<_TvSmallButton> {
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
        // Pronounced scale on focus — makes small buttons unmistakable on TV
        child: AnimatedScale(
          scale: _focused ? 1.30 : 1.0,
          duration: const Duration(milliseconds: 150),
          curve: Curves.easeOut,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              // Focused: full gradient → white icon clearly visible
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
