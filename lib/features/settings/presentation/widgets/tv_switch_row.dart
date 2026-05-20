import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/widgets/focus_scroll.dart';

/// Focusable row used by toggle settings (adhan, iqama, Quran, adhkar, dark
/// mode). The focus state intentionally uses a neutral theme-aware background
/// so accent-colored child text/icons stay vivid — never tinted by an accent
/// overlay. Visual cues are limited to a crisp accent border, soft accent
/// glow, and a subtle scale-up.
class TvSwitchRow extends StatefulWidget {
  final List<Widget> children;
  final bool value;
  final ValueChanged<bool> onChanged;
  final Color accent;

  const TvSwitchRow({
    required this.children,
    required this.value,
    required this.onChanged,
    required this.accent,
    super.key,
  });

  @override
  State<TvSwitchRow> createState() => _TvSwitchRowState();
}

class _TvSwitchRowState extends State<TvSwitchRow> {
  bool _isFocused = false;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final restingBg = isDark
        ? Colors.white.withValues(alpha: 0.03)
        : Colors.black.withValues(alpha: 0.025);
    final focusedBg = isDark
        ? Colors.white.withValues(alpha: 0.07)
        : Colors.black.withValues(alpha: 0.045);
    return Focus(
      onFocusChange: (f) {
        setState(() => _isFocused = f);
        if (f) ensureFocusedVisible(context);
      },
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
          scale: _isFocused ? 1.02 : 1.0,
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOut,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            curve: Curves.easeOut,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            decoration: BoxDecoration(
              color: _isFocused ? focusedBg : restingBg,
              border: Border.all(
                color: _isFocused
                    ? widget.accent
                    : widget.accent.withValues(alpha: 0.18),
                width: _isFocused ? 2.5 : 1.0,
              ),
              borderRadius: BorderRadius.circular(14),
              boxShadow: _isFocused
                  ? [
                      BoxShadow(
                        color: widget.accent.withValues(alpha: 0.40),
                        blurRadius: 24,
                        spreadRadius: 1.5,
                      ),
                    ]
                  : null,
            ),
            child: ExcludeFocus(
              child: Row(children: widget.children),
            ),
          ),
        ),
      ),
    );
  }
}
