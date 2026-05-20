import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/app_colors.dart';
import '../../../../core/widgets/focus_scroll.dart';

/// Focusable trigger card used by the country and city pickers in settings.
/// Mirrors the focus design language of [TvSwitchRow] / [TvFocusableCard]:
/// neutral theme-aware background, accent border, soft accent glow, subtle
/// scale. Theme-adaptive — works in both dark and light modes (no hardcoded
/// white-only colors).
class LocationValueCard extends StatefulWidget {
  final IconData icon;
  final String label;
  final String value;
  final ThemeColors tc;
  final Color accent;
  final VoidCallback onPressed;
  final bool autofocus;

  const LocationValueCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.tc,
    required this.accent,
    required this.onPressed,
    this.autofocus = false,
    super.key,
  });

  @override
  State<LocationValueCard> createState() => _LocationValueCardState();
}

class _LocationValueCardState extends State<LocationValueCard> {
  bool _isFocused = false;

  @override
  Widget build(BuildContext context) {
    final isDark = widget.tc.isDark;
    final restingBg = isDark
        ? Colors.white.withValues(alpha: 0.04)
        : Colors.black.withValues(alpha: 0.03);
    final focusedBg = isDark
        ? Colors.white.withValues(alpha: 0.08)
        : Colors.black.withValues(alpha: 0.05);
    return Focus(
      autofocus: widget.autofocus,
      onFocusChange: (f) {
        setState(() => _isFocused = f);
        if (f) ensureFocusedVisible(context);
      },
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
          scale: _isFocused ? 1.02 : 1.0,
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOut,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            curve: Curves.easeOut,
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
            decoration: BoxDecoration(
              color: _isFocused ? focusedBg : restingBg,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: _isFocused
                    ? widget.accent
                    : widget.accent.withValues(alpha: 0.18),
                width: _isFocused ? 2.5 : 1.0,
              ),
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
            child: Row(
              children: [
                Icon(widget.icon, color: widget.accent, size: 22),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.label,
                        style: TextStyle(
                          fontSize: 14,
                          color: widget.tc.textSecondary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        widget.value,
                        style: TextStyle(
                          fontSize: 20,
                          color: widget.tc.textPrimary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.chevron_left_rounded,
                  color: _isFocused
                      ? widget.accent
                      : widget.tc.textMuted,
                  size: 30,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
