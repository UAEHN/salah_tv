import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/widgets/focus_scroll.dart';

/// Focusable settings row that pushes a named route when activated. Mirrors
/// [TvSwitchRow]'s focus visuals (accent border + glow + scale) for D-pad use.
class SettingsActionButton extends StatefulWidget {
  final Color accent;
  final IconData icon;
  final String label;
  final String routeName;

  const SettingsActionButton({
    required this.accent,
    required this.icon,
    required this.label,
    required this.routeName,
    super.key,
  });

  @override
  State<SettingsActionButton> createState() => _SettingsActionButtonState();
}

class _SettingsActionButtonState extends State<SettingsActionButton> {
  bool _isFocused = false;

  void _activate() => Navigator.pushNamed(context, widget.routeName);

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
          _activate();
          return KeyEventResult.handled;
        }
        return KeyEventResult.ignored;
      },
      child: GestureDetector(
        onTap: _activate,
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
              child: Row(
                children: [
                  Icon(widget.icon, color: widget.accent, size: 26),
                  const SizedBox(width: 12),
                  Text(
                    widget.label,
                    style: TextStyle(
                      fontSize: 20,
                      color: widget.accent,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
