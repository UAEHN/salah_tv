import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/app_colors.dart';

class TvFeedbackSubmitButton extends StatefulWidget {
  final String label;
  final bool isLoading;
  final ThemeColors tc;
  final Color accent;
  final VoidCallback onPressed;

  const TvFeedbackSubmitButton({
    required this.label,
    required this.isLoading,
    required this.tc,
    required this.accent,
    required this.onPressed,
    super.key,
  });

  @override
  State<TvFeedbackSubmitButton> createState() => _TvFeedbackSubmitButtonState();
}

class _TvFeedbackSubmitButtonState extends State<TvFeedbackSubmitButton> {
  bool _isFocused = false;

  @override
  Widget build(BuildContext context) {
    final isActive = _isFocused;
    return Focus(
      onFocusChange: (f) => setState(() => _isFocused = f),
      onKeyEvent: (_, event) {
        if (event is KeyDownEvent &&
            (event.logicalKey == LogicalKeyboardKey.select ||
                event.logicalKey == LogicalKeyboardKey.enter)) {
          if (!widget.isLoading) widget.onPressed();
          return KeyEventResult.handled;
        }
        return KeyEventResult.ignored;
      },
      child: GestureDetector(
        onTap: widget.isLoading ? null : widget.onPressed,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 140),
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: widget.tc.glass(opacity: 0.07, borderRadius: 14).copyWith(
                color: isActive ? widget.accent : null,
                border: Border.all(
                  color: isActive ? Colors.white : Colors.white12,
                  width: isActive ? 2 : 1,
                ),
                boxShadow: isActive
                    ? [
                        BoxShadow(
                          color: widget.accent.withValues(alpha: 0.4),
                          blurRadius: 16,
                        ),
                      ]
                    : null,
              ),
          alignment: Alignment.center,
          child: widget.isLoading
              ? const SizedBox(
                  height: 24,
                  width: 24,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2,
                  ),
                )
              : Text(
                  widget.label,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: isActive ? Colors.white : widget.tc.textPrimary,
                  ),
                ),
        ),
      ),
    );
  }
}
