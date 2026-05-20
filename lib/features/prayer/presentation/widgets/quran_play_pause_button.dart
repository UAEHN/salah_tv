import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/app_colors.dart';
import '../bloc/prayer_bloc.dart';
import '../bloc/prayer_event.dart';
import '../bloc/prayer_state.dart';
import 'quran_button_face.dart';

/// The primary Quran pill: tri-state toggle (play / pause / resume).
/// Sibling [QuranStopButton] handles the full-clear path. Extracted from
/// [HomeQuranButton] to honor the 150-line cap and isolate the glow fade.
class QuranPlayPauseButton extends StatefulWidget {
  final AccentPalette palette;
  final String serverUrl;
  final bool isDarkMode;
  final FocusNode focusNode;
  final VoidCallback? onRight;
  final VoidCallback? onDown;
  final VoidCallback? onEscape;

  const QuranPlayPauseButton({
    required this.palette,
    required this.serverUrl,
    required this.isDarkMode,
    required this.focusNode,
    this.onRight,
    this.onDown,
    this.onEscape,
    super.key,
  });

  @override
  State<QuranPlayPauseButton> createState() => _QuranPlayPauseButtonState();
}

class _QuranPlayPauseButtonState extends State<QuranPlayPauseButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _glowCtrl;
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

  void _onFocusChange() =>
      setState(() => _isFocused = widget.focusNode.hasFocus);

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_didInitSync) {
      _didInitSync = true;
      if (context.read<PrayerBloc>().state.isQuranPlaying) {
        _glowCtrl.value = 1.0;
      }
    }
  }

  @override
  void dispose() {
    widget.focusNode.removeListener(_onFocusChange);
    _glowCtrl.dispose();
    super.dispose();
  }

  void _toggle() => context
      .read<PrayerBloc>()
      .add(PrayerQuranToggled(widget.serverUrl));

  KeyEventResult _onKey(FocusNode _, KeyEvent event) {
    if (event is! KeyDownEvent) return KeyEventResult.ignored;
    final key = event.logicalKey;
    if (key == LogicalKeyboardKey.select || key == LogicalKeyboardKey.enter) {
      _toggle();
      return KeyEventResult.handled;
    }
    if (key == LogicalKeyboardKey.arrowRight && widget.onRight != null) {
      widget.onRight!();
      return KeyEventResult.handled;
    }
    if (key == LogicalKeyboardKey.arrowDown && widget.onDown != null) {
      widget.onDown!();
      return KeyEventResult.handled;
    }
    if (key == LogicalKeyboardKey.arrowUp ||
        key == LogicalKeyboardKey.arrowLeft) {
      widget.onEscape?.call();
      return KeyEventResult.handled;
    }
    return KeyEventResult.ignored;
  }

  @override
  Widget build(BuildContext context) {
    final flags = context.select<PrayerBloc, (bool, bool, bool)>(
      (b) => (
        b.state.isQuranPlaying,
        b.state.quranUserEnabled,
        b.state.isQuranPausedByUser,
      ),
    );
    final isPlaying = flags.$1;
    final quranUserEnabled = flags.$2;
    final isPausedByUser = flags.$3;
    final isPausedForAdhan = quranUserEnabled && !isPlaying && !isPausedByUser;

    return BlocListener<PrayerBloc, PrayerState>(
      listenWhen: (prev, cur) => prev.isQuranPlaying != cur.isQuranPlaying,
      listener: (_, state) {
        state.isQuranPlaying ? _glowCtrl.forward() : _glowCtrl.reverse();
      },
      child: Focus(
        focusNode: widget.focusNode,
        onKeyEvent: _onKey,
        child: GestureDetector(
          onTap: _toggle,
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
