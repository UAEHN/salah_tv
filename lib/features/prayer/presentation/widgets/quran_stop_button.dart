import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/app_colors.dart';
import '../bloc/prayer_bloc.dart';
import '../bloc/prayer_event.dart';

/// Companion to [QuranPlayPauseButton]. Mirrors the play/pause pill's outer
/// shape and height so the two buttons sit together as a balanced pair (no
/// shape mismatch, no visual jump when the stop button appears).
///
/// Visible only when the user has Quran enabled (playing or user-paused) —
/// nothing to stop otherwise.
///
/// [layoutWidth] is the reserved horizontal extent (icon + paddings + outer
/// border). [HomeQuranButton] uses it to mirror an invisible spacer on the
/// opposite side so the play/pause pill stays optically centered when the
/// stop button toggles in/out.
class QuranStopButton extends StatefulWidget {
  static const double layoutWidth = 47;

  final AccentPalette palette;
  final bool isDarkMode;
  final FocusNode focusNode;
  final VoidCallback? onLeft;
  final VoidCallback? onDown;
  final VoidCallback? onEscape;

  const QuranStopButton({
    required this.palette,
    required this.isDarkMode,
    required this.focusNode,
    this.onLeft,
    this.onDown,
    this.onEscape,
    super.key,
  });

  @override
  State<QuranStopButton> createState() => _QuranStopButtonState();
}

class _QuranStopButtonState extends State<QuranStopButton> {
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    widget.focusNode.addListener(_onFocusChange);
  }

  void _onFocusChange() =>
      setState(() => _isFocused = widget.focusNode.hasFocus);

  @override
  void dispose() {
    widget.focusNode.removeListener(_onFocusChange);
    super.dispose();
  }

  void _stop() => context.read<PrayerBloc>().add(const PrayerQuranStopped());

  KeyEventResult _onKey(FocusNode _, KeyEvent event) {
    if (event is! KeyDownEvent) return KeyEventResult.ignored;
    final key = event.logicalKey;
    if (key == LogicalKeyboardKey.select || key == LogicalKeyboardKey.enter) {
      _stop();
      return KeyEventResult.handled;
    }
    if (key == LogicalKeyboardKey.arrowLeft) {
      widget.onLeft?.call();
      return KeyEventResult.handled;
    }
    if (key == LogicalKeyboardKey.arrowDown && widget.onDown != null) {
      widget.onDown!();
      return KeyEventResult.handled;
    }
    if (key == LogicalKeyboardKey.arrowUp) {
      widget.onEscape?.call();
      return KeyEventResult.handled;
    }
    return KeyEventResult.ignored;
  }

  @override
  Widget build(BuildContext context) {
    final iconColor = widget.isDarkMode
        ? Colors.white.withValues(alpha: 0.85)
        : kTextPrimary.withValues(alpha: 0.80);
    final innerColor = widget.isDarkMode
        ? Colors.white.withValues(alpha: 0.10)
        : Colors.black.withValues(alpha: 0.07);
    return Focus(
      focusNode: widget.focusNode,
      onKeyEvent: _onKey,
      child: GestureDetector(
        onTap: _stop,
        child: Container(
          padding: const EdgeInsets.all(1.5),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(30),
            color: widget.palette.primary.withValues(alpha: 0.55),
            border: _isFocused
                ? Border.all(
                    color: widget.isDarkMode
                        ? Colors.white.withValues(alpha: 0.9)
                        : kTextPrimary.withValues(alpha: 0.85),
                    width: 2,
                  )
                : null,
          ),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(28.5),
              color: innerColor,
            ),
            child: Icon(Icons.stop_rounded, color: iconColor, size: 20),
          ),
        ),
      ),
    );
  }
}
