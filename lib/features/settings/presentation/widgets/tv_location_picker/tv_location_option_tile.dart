import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../../../../core/app_colors.dart';
import '../../../../../core/widgets/focus_scroll.dart';
import '../../settings_provider.dart';

/// Selectable row in the city / country picker dialog. Theme-adaptive — the
/// previous version used hardcoded white/dark-blue colors that broke in light
/// mode and didn't match the focus design language used elsewhere in
/// settings (accent border + soft glow + neutral background).
class TvLocationOptionTile extends StatefulWidget {
  final String title;
  final bool isSelected;
  final bool isBusy;
  final bool autofocus;
  final VoidCallback onPressed;

  const TvLocationOptionTile({
    required this.title,
    required this.isSelected,
    required this.isBusy,
    required this.onPressed,
    this.autofocus = false,
    super.key,
  });

  @override
  State<TvLocationOptionTile> createState() => _TvLocationOptionTileState();
}

class _TvLocationOptionTileState extends State<TvLocationOptionTile> {
  bool _isFocused = false;

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>().settings;
    final tc = ThemeColors.of(settings.isDarkMode);
    final accent = getThemePalette(settings.themeColorKey).primary;
    final isDark = tc.isDark;
    final restingBg = widget.isSelected
        ? accent.withValues(alpha: 0.12)
        : (isDark
              ? Colors.white.withValues(alpha: 0.04)
              : Colors.black.withValues(alpha: 0.03));
    final focusedBg = widget.isSelected
        ? accent.withValues(alpha: 0.18)
        : (isDark
              ? Colors.white.withValues(alpha: 0.08)
              : Colors.black.withValues(alpha: 0.05));
    return Focus(
      autofocus: widget.autofocus,
      onFocusChange: (f) {
        setState(() => _isFocused = f);
        if (f) ensureFocusedVisible(context);
      },
      onKeyEvent: (_, event) {
        if (widget.isBusy) return KeyEventResult.ignored;
        if (event is KeyDownEvent &&
            (event.logicalKey == LogicalKeyboardKey.select ||
                event.logicalKey == LogicalKeyboardKey.enter)) {
          widget.onPressed();
          return KeyEventResult.handled;
        }
        return KeyEventResult.ignored;
      },
      child: GestureDetector(
        onTap: widget.isBusy ? null : widget.onPressed,
        // Dropped the AnimatedScale(1.02) wrapper — on TV the scale-on-focus
        // pushed the rendered box ~0.5px past the layout slot, which the list
        // viewport clipped at the bottom edge (the "missing bottom border"
        // visible in dark-mode pickers). Focus is already clear from the
        // brighter border + glow; no scale needed.
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOut,
          // Symmetric vertical margin so the focus glow has breathing room on
          // both sides instead of bleeding asymmetrically into the next tile.
          margin: const EdgeInsets.symmetric(vertical: 5),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
          decoration: BoxDecoration(
            color: _isFocused ? focusedBg : restingBg,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: _isFocused
                  ? accent
                  : (widget.isSelected
                        ? accent.withValues(alpha: 0.55)
                        : accent.withValues(alpha: 0.18)),
              width: _isFocused ? 2.5 : (widget.isSelected ? 1.5 : 1.0),
            ),
            // Softer halo — blur 24 + spread 1.5 was wider than the 10 px gap
            // between tiles, so the glow bled under the next tile and made
            // the focused tile's bottom edge look chopped.
            boxShadow: _isFocused
                ? [
                    BoxShadow(
                      color: accent.withValues(alpha: 0.35),
                      blurRadius: 14,
                    ),
                  ]
                : null,
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  widget.title,
                  style: TextStyle(
                    color: tc.textPrimary,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              if (widget.isBusy)
                SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation(accent),
                  ),
                )
              else if (widget.isSelected)
                Icon(Icons.check_circle_rounded, color: accent),
            ],
          ),
        ),
      ),
    );
  }
}
