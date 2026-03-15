import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Full-width exit/close-app button shown at the bottom of the settings nav panel.
class SettingsExitButton extends StatefulWidget {
  const SettingsExitButton({super.key});

  @override
  State<SettingsExitButton> createState() => _SettingsExitButtonState();
}

class _SettingsExitButtonState extends State<SettingsExitButton> {
  bool _isFocused = false;
  static const _red = Color(0xFFDC2626);

  @override
  Widget build(BuildContext context) {
    return Focus(
      onFocusChange: (f) => setState(() => _isFocused = f),
      onKeyEvent: (_, event) {
        if (event is KeyDownEvent &&
            (event.logicalKey == LogicalKeyboardKey.select ||
                event.logicalKey == LogicalKeyboardKey.enter)) {
          SystemNavigator.pop();
          return KeyEventResult.handled;
        }
        return KeyEventResult.ignored;
      },
      child: GestureDetector(
        onTap: SystemNavigator.pop,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
          decoration: BoxDecoration(
            color: _isFocused ? _red : _red.withValues(alpha: 0.12),
            border: Border.all(
              color: _isFocused
                  ? Colors.white.withValues(alpha: 0.55)
                  : _red.withValues(alpha: 0.35),
              width: _isFocused ? 1.5 : 1.0,
            ),
            borderRadius: BorderRadius.circular(14),
            boxShadow: _isFocused
                ? [
                    BoxShadow(
                      color: _red.withValues(alpha: 0.40),
                      blurRadius: 20,
                      spreadRadius: 2,
                    ),
                  ]
                : null,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.power_settings_new_rounded,
                color: _isFocused ? Colors.white : _red,
                size: 22,
              ),
              const SizedBox(width: 10),
              Text(
                'اغلاق التطبيق',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: _isFocused ? Colors.white : _red,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
