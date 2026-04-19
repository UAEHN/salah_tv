import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/app_colors.dart';
import '../bloc/prayer_bloc.dart';
import '../bloc/prayer_event.dart';
import '../bloc/prayer_state.dart';
import 'quran_button_face.dart';

/// Quran pill button with a soft idle↔playing fade.
/// Rotation was removed: the continuous 60 fps SweepGradient repaint
/// accumulated GPU shader pressure on TV boxes, causing UI freezes after
/// multi-hour sessions while the audio thread kept running.
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
    with SingleTickerProviderStateMixin {
  late final AnimationController _glowCtrl; // idle↔playing fade (600ms)
  late final Animation<double> _fade;
  bool _isFocused = false;
  bool _didInitSync = false;

  @override
  void initState() {
    super.initState();
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
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_didInitSync) {
      _didInitSync = true;
      final initial = context.read<PrayerBloc>().state;
      if (initial.isQuranPlaying) _glowCtrl.value = 1.0;
    }
  }

  @override
  void dispose() {
    widget.focusNode.removeListener(_onFocusChange);
    _glowCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Narrow select: rebuild only when either field actually changes.
    final quranFlags = context.select<PrayerBloc, (bool, bool)>(
      (b) => (b.state.isQuranPlaying, b.state.quranUserEnabled),
    );
    final isPlaying = quranFlags.$1;
    final quranUserEnabled = quranFlags.$2;
    final isPausedForAdhan = quranUserEnabled && !isPlaying;

    // BlocListener drives the glow fade off the build path.
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
          // RepaintBoundary isolates the short glow fade to this layer so the
          // 600 ms transition doesn't repaint the whole info card.
          child: RepaintBoundary(
            child: AnimatedBuilder(
              animation: _fade,
              builder: (_, _) => QuranButtonFace(
                palette: widget.palette,
                isDarkMode: widget.isDarkMode,
                isPlaying: isPlaying,
                isPausedForAdhan: isPausedForAdhan,
                isFocused: _isFocused,
                fadeT: _fade.value,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
