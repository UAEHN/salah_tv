import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../../../../core/app_colors.dart';
import '../../../../../core/widgets/focus_scroll.dart';
import '../../logic/method_preview_computer.dart';
import '../../settings_provider.dart';
import 'tv_method_preview_body.dart';

/// TV-friendly method preview tile: D-pad focusable, glows on focus, fires
/// [onPressed] on Select/Enter. Computes today's five prayer times locally
/// so the user can compare the candidate method against their local
/// mosque before committing.
class TvMethodPreviewCard extends StatefulWidget {
  final String methodKey;
  final double latitude;
  final double longitude;
  final String highLatitudeRuleKey;
  final bool isSuggested;
  final bool autofocus;
  final VoidCallback onPressed;

  const TvMethodPreviewCard({
    required this.methodKey,
    required this.latitude,
    required this.longitude,
    required this.highLatitudeRuleKey,
    required this.onPressed,
    this.isSuggested = false,
    this.autofocus = false,
    super.key,
  });

  @override
  State<TvMethodPreviewCard> createState() => _TvMethodPreviewCardState();
}

class _TvMethodPreviewCardState extends State<TvMethodPreviewCard> {
  bool _isFocused = false;

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>().settings;
    final tc = ThemeColors.of(settings.isDarkMode);
    final accent = getThemePalette(settings.themeColorKey).primary;
    final times = computePreviewForMethod(
      latitude: widget.latitude,
      longitude: widget.longitude,
      methodKey: widget.methodKey,
      highLatitudeRuleKey: widget.highLatitudeRuleKey,
    );
    return Focus(
      autofocus: widget.autofocus,
      onFocusChange: (f) {
        setState(() => _isFocused = f);
        if (f) ensureFocusedVisible(context);
      },
      onKeyEvent: (_, event) {
        if (event is KeyDownEvent &&
            (event.logicalKey == LogicalKeyboardKey.select ||
                event.logicalKey == LogicalKeyboardKey.enter)) {
          widget.onPressed();
          return KeyEventResult.handled;
        }
        return KeyEventResult.ignored;
      },
      child: GestureDetector(
        onTap: widget.onPressed,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOut,
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.fromLTRB(18, 14, 18, 16),
          decoration: BoxDecoration(
            color: _isFocused
                ? accent.withValues(alpha: 0.14)
                : accent.withValues(alpha: widget.isSuggested ? 0.06 : 0.03),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: _isFocused
                  ? accent
                  : accent.withValues(alpha: widget.isSuggested ? 0.55 : 0.18),
              width: _isFocused ? 2.5 : (widget.isSuggested ? 1.5 : 1.0),
            ),
            boxShadow: _isFocused
                ? [
                    BoxShadow(
                      color: accent.withValues(alpha: 0.40),
                      blurRadius: 24,
                      spreadRadius: 1.5,
                    ),
                  ]
                : null,
          ),
          child: TvMethodPreviewBody(
            methodKey: widget.methodKey,
            times: times,
            isSuggested: widget.isSuggested,
            use24Hour: settings.use24HourFormat,
            tc: tc,
            accent: accent,
          ),
        ),
      ),
    );
  }
}
