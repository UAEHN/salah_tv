import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

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
            child: ExcludeFocus(
              child: Row(children: widget.children),
            ),
          ),
        ),
      ),
    );
  }
}
