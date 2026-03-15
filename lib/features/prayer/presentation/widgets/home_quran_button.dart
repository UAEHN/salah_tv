import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/app_colors.dart';
import '../bloc/prayer_bloc.dart';
import '../bloc/prayer_event.dart';
import '../bloc/prayer_state.dart';
import 'quran_button_face.dart';

/// Animated Quran pill button with a rotating sweep-gradient border.
/// Shows play/stop icon and a pause indicator when Quran is paused for adhan.
class HomeQuranButton extends StatefulWidget {
  final AccentPalette palette;
  final String serverUrl;
  final bool isDarkMode;
  final FocusNode focusNode;
  final VoidCallback? onEscape;

  const HomeQuranButton({
    required this.palette,
    required this.serverUrl,
    required this.isDarkMode,
    required this.focusNode,
    this.onEscape,
    super.key,
  });

  @override
  State<HomeQuranButton> createState() => _HomeQuranButtonState();
}

class _HomeQuranButtonState extends State<HomeQuranButton>
    with TickerProviderStateMixin {
  late final AnimationController _rotCtrl; // border rotation (4s, repeating)
  late final AnimationController _glowCtrl; // idle↔playing fade (600ms)
  late final Animation<double> _fade;
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _rotCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();
    _glowCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fade = CurvedAnimation(parent: _glowCtrl, curve: Curves.easeInOut);
    widget.focusNode.addListener(_onFocusChange);
  }

  void _onFocusChange() {
    setState(() => _isFocused = widget.focusNode.hasFocus);
  }

  @override
  void dispose() {
    widget.focusNode.removeListener(_onFocusChange);
    _rotCtrl.dispose();
    _glowCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final prayerState = context.watch<PrayerBloc>().state;
    final isPlaying = prayerState.isQuranPlaying;
    final isPausedForAdhan = prayerState.quranUserEnabled && !isPlaying;

    // BlocListener drives the glow animation; keeps build() side-effect-free.
    return BlocListener<PrayerBloc, PrayerState>(
      listenWhen: (prev, cur) => prev.isQuranPlaying != cur.isQuranPlaying,
      listener: (_, state) {
        state.isQuranPlaying ? _glowCtrl.forward() : _glowCtrl.reverse();
      },
      child: Focus(
        focusNode: widget.focusNode,
        onKeyEvent: (_, event) {
          if (event is KeyDownEvent) {
            if (event.logicalKey == LogicalKeyboardKey.select ||
                event.logicalKey == LogicalKeyboardKey.enter) {
              context.read<PrayerBloc>().add(PrayerQuranToggled(widget.serverUrl));
              return KeyEventResult.handled;
            }
            if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
              widget.onEscape?.call();
              return KeyEventResult.handled;
            }
          }
          return KeyEventResult.ignored;
        },
        child: GestureDetector(
          onTap: () =>
              context.read<PrayerBloc>().add(PrayerQuranToggled(widget.serverUrl)),
          child: AnimatedBuilder(
            animation: Listenable.merge([_rotCtrl, _fade]),
            builder: (_, _) => QuranButtonFace(
              palette: widget.palette,
              isDarkMode: widget.isDarkMode,
              isPlaying: isPlaying,
              isPausedForAdhan: isPausedForAdhan,
              isFocused: _isFocused,
              angle: _rotCtrl.value * 2 * math.pi,
              fadeT: _fade.value,
            ),
          ),
        ),
      ),
    );
  }
}
