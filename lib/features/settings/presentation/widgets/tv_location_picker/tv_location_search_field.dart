import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../../../../core/app_colors.dart';
import '../../settings_provider.dart';

class TvLocationSearchField extends StatelessWidget {
  final String hintText;
  final ValueChanged<String> onChanged;

  const TvLocationSearchField({
    required this.hintText,
    required this.onChanged,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>().settings;
    final tc = ThemeColors.of(settings.isDarkMode);
    final accent = getThemePalette(settings.themeColorKey).primary;
    final isDark = tc.isDark;
    final fill = isDark
        ? Colors.white.withValues(alpha: 0.05)
        : Colors.black.withValues(alpha: 0.04);
    // DPad-Down/Up forwarded to focus traversal so the search field never
    // traps focus on TV — without this the TextField swallows arrow keys for
    // caret movement and the user cannot reach the list below.
    //
    // canRequestFocus:false + skipTraversal makes this wrapper a pure key
    // interceptor: DPad-Up from the first list row must land on the TextField's
    // own editable node (cursor + focused border + on-screen keyboard), NOT on
    // this wrapper node. Key events still bubble up here from the focused
    // TextField, so onKeyEvent keeps working. Without this, traversal stopped on
    // the wrapper and the user could never actually reach/type in the search box.
    return Focus(
      canRequestFocus: false,
      skipTraversal: true,
      onKeyEvent: (node, event) {
        if (event is KeyDownEvent) {
          if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
            FocusScope.of(context).focusInDirection(TraversalDirection.down);
            return KeyEventResult.handled;
          }
          if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
            FocusScope.of(context).focusInDirection(TraversalDirection.up);
            return KeyEventResult.handled;
          }
        }
        return KeyEventResult.ignored;
      },
      child: TextField(
        onChanged: onChanged,
        style: TextStyle(color: tc.textPrimary, fontSize: 18),
        cursorColor: accent,
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: TextStyle(color: tc.textMuted),
          prefixIcon: Icon(Icons.search_rounded, color: tc.textSecondary),
          filled: true,
          fillColor: fill,
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(color: accent.withValues(alpha: 0.18)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(color: accent, width: 2),
          ),
        ),
      ),
    );
  }
}
