import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/app_colors.dart';
import '../bloc/prayer_bloc.dart';
import 'quran_play_pause_button.dart';
import 'quran_stop_button.dart';

/// Pairs [QuranPlayPauseButton] with the optional [QuranStopButton] so the
/// two pills sit balanced. When the user disables Quran the stop button
/// retracts; an invisible spacer of equal width keeps the play/pause pill
/// optically centered instead of jumping sideways.
class HomeQuranButton extends StatefulWidget {
  final AccentPalette palette;
  final String serverUrl;
  final bool isDarkMode;
  final FocusNode focusNode;
  final VoidCallback? onEscape;

  /// Arrow Down from either child pill → caller decides (e.g. focus the
  /// Takbeerat pill below). Null disables the down traversal.
  final VoidCallback? onDown;

  const HomeQuranButton({
    required this.palette,
    required this.serverUrl,
    required this.isDarkMode,
    required this.focusNode,
    this.onEscape,
    this.onDown,
    super.key,
  });

  @override
  State<HomeQuranButton> createState() => _HomeQuranButtonState();
}

class _HomeQuranButtonState extends State<HomeQuranButton> {
  late final FocusNode _stopFocusNode;

  @override
  void initState() {
    super.initState();
    _stopFocusNode = FocusNode(debugLabel: 'QuranStop');
  }

  @override
  void dispose() {
    _stopFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final showStop = context.select<PrayerBloc, bool>(
      (b) => b.state.quranUserEnabled,
    );
    const gap = SizedBox(width: 8);
    const spacer = SizedBox(width: QuranStopButton.layoutWidth);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        spacer,
        gap,
        QuranPlayPauseButton(
          palette: widget.palette,
          serverUrl: widget.serverUrl,
          isDarkMode: widget.isDarkMode,
          focusNode: widget.focusNode,
          onRight: showStop ? () => _stopFocusNode.requestFocus() : null,
          onDown: widget.onDown,
          onEscape: widget.onEscape,
        ),
        gap,
        if (showStop)
          QuranStopButton(
            palette: widget.palette,
            isDarkMode: widget.isDarkMode,
            focusNode: _stopFocusNode,
            onLeft: () => widget.focusNode.requestFocus(),
            onDown: widget.onDown,
            onEscape: widget.onEscape,
          )
        else
          spacer,
      ],
    );
  }
}
