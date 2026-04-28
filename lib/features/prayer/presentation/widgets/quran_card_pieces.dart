import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/app_colors.dart';
import '../bloc/prayer_bloc.dart';
import '../bloc/prayer_event.dart';

/// Pulsing red dot indicating live Quran playback.
class LiveDot extends StatefulWidget {
  final Color color;
  const LiveDot({required this.color, super.key});
  @override
  State<LiveDot> createState() => _LiveDotState();
}

class _LiveDotState extends State<LiveDot> with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1100),
  )..repeat(reverse: true);

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
        animation: _ctrl,
        builder: (_, _) {
          final t = _ctrl.value;
          return Container(
            width: 9,
            height: 9,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: widget.color.withValues(alpha: 0.55 + 0.45 * t),
              boxShadow: [
                BoxShadow(
                  color: widget.color.withValues(alpha: 0.55 * t),
                  blurRadius: 6 * t,
                  spreadRadius: 1.5 * t,
                ),
              ],
            ),
          );
        },
      );
}

/// Circular skip-next-surah button with TV focus styling. Only meaningful in
/// playlist mode (parent gates visibility).
class SurahSkipButton extends StatefulWidget {
  final AccentPalette palette;
  final bool isDarkMode;
  const SurahSkipButton({required this.palette, required this.isDarkMode, super.key});
  @override
  State<SurahSkipButton> createState() => _SurahSkipButtonState();
}

class _SurahSkipButtonState extends State<SurahSkipButton> {
  final FocusNode _focus = FocusNode();
  bool _f = false;
  @override
  void initState() {
    super.initState();
    _focus.addListener(() => setState(() => _f = _focus.hasFocus));
  }
  @override
  void dispose() { _focus.dispose(); super.dispose(); }
  void _skip() => context.read<PrayerBloc>().add(const PrayerSurahSkipped());

  @override
  Widget build(BuildContext context) {
    final p = widget.palette;
    final ring = widget.isDarkMode ? Colors.white : Colors.black.withValues(alpha: 0.85);
    return Focus(
      focusNode: _focus,
      onKeyEvent: (_, e) {
        if (e is KeyDownEvent &&
            (e.logicalKey == LogicalKeyboardKey.select ||
                e.logicalKey == LogicalKeyboardKey.enter)) {
          _skip();
          return KeyEventResult.handled;
        }
        return KeyEventResult.ignored;
      },
      child: GestureDetector(
        onTap: _skip,
        child: AnimatedScale(
          scale: _f ? 1.10 : 1.0,
          duration: const Duration(milliseconds: 150),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            width: 36, height: 36,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: _f ? p.primary : p.primary.withValues(alpha: 0.18),
              border: Border.all(
                color: _f ? ring : p.primary.withValues(alpha: 0.45),
                width: _f ? 2.5 : 1.2,
              ),
            ),
            child: Icon(Icons.skip_next_rounded,
                color: _f ? Colors.white : p.primary, size: 20),
          ),
        ),
      ),
    );
  }
}
