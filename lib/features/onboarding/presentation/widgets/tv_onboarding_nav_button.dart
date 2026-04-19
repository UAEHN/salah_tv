import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../../core/brand_colors.dart';

/// Primary action button for TV onboarding (Next / Finish).
/// Glows with [brandGold] when focused via D-Pad.
class TvOnboardingNavButton extends StatefulWidget {
  const TvOnboardingNavButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.isEnabled = true,
    this.isLoading = false,
    this.autofocus = false,
    this.icon,
  });

  final String label;
  final VoidCallback onPressed;
  final bool isEnabled;
  final bool isLoading;
  final bool autofocus;
  final IconData? icon;

  @override
  State<TvOnboardingNavButton> createState() => _TvOnboardingNavButtonState();
}

class _TvOnboardingNavButtonState extends State<TvOnboardingNavButton> {
  bool _isFocused = false;

  @override
  Widget build(BuildContext context) {
    final isActive = widget.isEnabled && !widget.isLoading;

    return Focus(
      autofocus: widget.autofocus,
      onFocusChange: (v) => setState(() => _isFocused = v),
      onKeyEvent: (_, event) {
        if (!isActive) return KeyEventResult.ignored;
        if (event is KeyDownEvent &&
            (event.logicalKey == LogicalKeyboardKey.select ||
                event.logicalKey == LogicalKeyboardKey.enter ||
                event.logicalKey == LogicalKeyboardKey.gameButtonA)) {
          widget.onPressed();
          return KeyEventResult.handled;
        }
        return KeyEventResult.ignored;
      },
      child: GestureDetector(
        onTap: isActive ? widget.onPressed : null,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 14),
          decoration: BoxDecoration(
            gradient: isActive && _isFocused
                ? LinearGradient(
                    colors: [brandGold, brandGoldDark],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  )
                : null,
            color: isActive && !_isFocused
                ? brandGold.withValues(alpha: 0.15)
                : !isActive
                    ? Colors.white.withValues(alpha: 0.05)
                    : null,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isActive
                  ? (_isFocused
                      ? brandGold
                      : brandGold.withValues(alpha: 0.5))
                  : Colors.white.withValues(alpha: 0.15),
            ),
            boxShadow: _isFocused && isActive
                ? [
                    BoxShadow(
                      color: brandGold.withValues(alpha: 0.4),
                      blurRadius: 20,
                      spreadRadius: 2,
                    ),
                  ]
                : null,
          ),
          child: widget.isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    color: brandGold,
                    strokeWidth: 2,
                  ),
                )
              : Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (widget.icon != null) ...[
                      Icon(
                        widget.icon,
                        size: 18,
                        color: isActive
                            ? (_isFocused
                                ? Colors.white
                                : brandGold)
                            : Colors.white.withValues(alpha: 0.3),
                      ),
                      const SizedBox(width: 8),
                    ],
                    Text(
                      widget.label,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: isActive
                            ? (_isFocused
                                ? Colors.white
                                : brandGold)
                            : Colors.white.withValues(alpha: 0.3),
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}
