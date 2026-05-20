import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/app_colors.dart';
import '../bloc/prayer_bloc.dart';
import '../bloc/prayer_event.dart';
import 'takbeerat_button_face.dart';

/// Companion pill to [HomeQuranButton] — same focus contract: Enter/Select
/// toggles, Arrow Up escapes to the main focus node. Lives next to the
/// Quran pill in the InfoCard / classic countdown column.
class HomeTakbeeratButton extends StatefulWidget {
  const HomeTakbeeratButton({
    required this.palette,
    required this.isDarkMode,
    required this.reciterUrl,
    required this.focusNode,
    this.onEscape,
    super.key,
  });

  final AccentPalette palette;
  final bool isDarkMode;
  final String reciterUrl;
  final FocusNode focusNode;
  final VoidCallback? onEscape;

  @override
  State<HomeTakbeeratButton> createState() => _HomeTakbeeratButtonState();
}

class _HomeTakbeeratButtonState extends State<HomeTakbeeratButton> {
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

  void _toggle() => context
      .read<PrayerBloc>()
      .add(PrayerTakbeeratToggled(widget.reciterUrl));

  @override
  Widget build(BuildContext context) {
    final isPlaying = context.select<PrayerBloc, bool>(
      (b) => b.state.takbeeratUserEnabled,
    );
    return Focus(
      focusNode: widget.focusNode,
      onKeyEvent: (_, event) {
        if (event is! KeyDownEvent) return KeyEventResult.ignored;
        final key = event.logicalKey;
        if (key == LogicalKeyboardKey.select ||
            key == LogicalKeyboardKey.enter) {
          _toggle();
          return KeyEventResult.handled;
        }
        if (key == LogicalKeyboardKey.arrowUp ||
            key == LogicalKeyboardKey.arrowLeft) {
          widget.onEscape?.call();
          return KeyEventResult.handled;
        }
        return KeyEventResult.ignored;
      },
      child: GestureDetector(
        onTap: _toggle,
        child: TakbeeratButtonFace(
          palette: widget.palette,
          isDarkMode: widget.isDarkMode,
          isPlaying: isPlaying,
          isFocused: _isFocused,
        ),
      ),
    );
  }
}
