import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/app_colors.dart';

/// Focusable dismiss button for TV dialogs.
/// Handles D-Pad OK/Select/Enter keys and glows when focused.
class TvDialogDismissButton extends StatefulWidget {
  const TvDialogDismissButton({
    super.key,
    required this.label,
    required this.onPressed,
    required this.tc,
    this.autofocus = true,
  });

  final String label;
  final VoidCallback onPressed;
  final ThemeColors tc;
  final bool autofocus;

  @override
  State<TvDialogDismissButton> createState() => _TvDialogDismissButtonState();
}

class _TvDialogDismissButtonState extends State<TvDialogDismissButton> {
  bool _isFocused = false;

  @override
  Widget build(BuildContext context) {
    return Focus(
      autofocus: widget.autofocus,
      onFocusChange: (v) => setState(() => _isFocused = v),
      onKeyEvent: (_, event) {
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
        onTap: widget.onPressed,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            gradient: _isFocused
                ? const LinearGradient(
                    colors: [Color(0xFF10B981), Color(0xFF059669)],
                  )
                : null,
            color: _isFocused ? null : Colors.white.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: _isFocused
                  ? const Color(0xFF10B981)
                  : Colors.white.withValues(alpha: 0.15),
            ),
            boxShadow: _isFocused
                ? [
                    const BoxShadow(
                      color: Color(0x6010B981),
                      blurRadius: 16,
                      spreadRadius: 2,
                    ),
                  ]
                : null,
          ),
          child: Text(
            widget.label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: _isFocused ? Colors.white : widget.tc.textSecondary,
            ),
          ),
        ),
      ),
    );
  }
}
