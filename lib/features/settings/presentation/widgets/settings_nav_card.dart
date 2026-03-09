import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/app_colors.dart';

class SettingsNavCard extends StatefulWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool isSelected;
  final VoidCallback onFocused;
  final AccentPalette palette;
  final FocusNode? focusNode;
  final bool autofocus;
  final bool isDarkMode;

  const SettingsNavCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.isSelected,
    required this.onFocused,
    required this.palette,
    this.focusNode,
    this.autofocus = false,
    this.isDarkMode = false,
    super.key,
  });

  @override
  State<SettingsNavCard> createState() => _SettingsNavCardState();
}

class _SettingsNavCardState extends State<SettingsNavCard> {
  bool _focused = false;

  bool get _highlighted => _focused || widget.isSelected;

  @override
  Widget build(BuildContext context) {
    final tc = ThemeColors.of(widget.isDarkMode);
    return Focus(
      focusNode: widget.focusNode,
      autofocus: widget.autofocus,
      onFocusChange: (f) {
        setState(() => _focused = f);
        if (f) widget.onFocused();
      },
      onKeyEvent: (_, event) {
        if (event is KeyDownEvent &&
            (event.logicalKey == LogicalKeyboardKey.select ||
                event.logicalKey == LogicalKeyboardKey.enter)) {
          widget.onFocused();
          return KeyEventResult.handled;
        }
        return KeyEventResult.ignored;
      },
      child: GestureDetector(
        onTap: widget.onFocused,
        child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        margin: const EdgeInsets.symmetric(vertical: 5),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        decoration: BoxDecoration(
          gradient: _highlighted ? widget.palette.gradient : null,
          color: _highlighted
              ? null
              : Colors.white.withValues(alpha: tc.isDark ? 0.06 : 0.35),
          border: Border.all(
            color: _highlighted
                ? Colors.white.withValues(alpha: 0.55)
                : Colors.white.withValues(alpha: tc.isDark ? 0.18 : 0.08),
            width: _highlighted ? 1.5 : 1.0,
          ),
          borderRadius: BorderRadius.circular(14),
          boxShadow: _highlighted
              ? [
                  BoxShadow(
                    color: widget.palette.glow,
                    blurRadius: 20,
                    spreadRadius: 2,
                  ),
                ]
              : null,
        ),
        child: Row(
          children: [
            Icon(
              widget.icon,
              color: _highlighted ? Colors.white : widget.palette.primary,
              size: 26,
            ),
            const SizedBox(width: 14),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  widget.title,
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: _highlighted ? Colors.white : tc.textPrimary,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  widget.subtitle,
                  style: TextStyle(
                    fontSize: 12,
                    color: _highlighted
                        ? Colors.white.withValues(alpha: 0.70)
                        : tc.textMuted,
                  ),
                ),
              ],
            ),
            const Spacer(),
            Icon(
              Icons.chevron_right_rounded,
              color: _highlighted ? Colors.white70 : Colors.white24,
              size: 20,
            ),
          ],
        ),
      ),
      ),
    );
  }
}
