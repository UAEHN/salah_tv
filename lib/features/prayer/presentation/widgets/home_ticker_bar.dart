import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';

import '../../../../core/app_colors.dart';
import '../../../../core/ticker_content.dart';
import 'classic/classic_visuals.dart';

/// Calm rotating banner for the TV home screen: shows one verse / hadith /
/// dhikr at a time, cross-fading to the next every [_interval]. No scrolling.
///
/// Performance (CLAUDE.md §7): a single periodic [Timer] flips the index; the
/// [AnimatedSwitcher] only animates briefly during the swap, so the bar is
/// idle (zero per-frame work) between changes. Wrapped in a [RepaintBoundary].
/// Only mounted under the home view, so it is removed during prayer-cycle
/// overlays.
class HomeTickerBar extends StatefulWidget {
  final AccentPalette palette;
  final bool isDarkMode;

  const HomeTickerBar({
    required this.palette,
    required this.isDarkMode,
    super.key,
  });

  @override
  State<HomeTickerBar> createState() => _HomeTickerBarState();
}

class _HomeTickerBarState extends State<HomeTickerBar> {
  Timer? _timer; // cancelled in dispose()
  int _index = 0;

  static const Duration _interval = Duration(minutes: 20);

  @override
  void initState() {
    super.initState();
    // Start at a random item so returning to the home view (after a screensaver
    // or adhkar takeover removed/remounted this bar) doesn't always replay the
    // rotation from the first item. Advance stays sequential from there.
    _index = Random().nextInt(kTickerItems.length);
    _timer = Timer.periodic(_interval, (_) {
      if (!mounted) return;
      setState(() => _index = (_index + 1) % kTickerItems.length);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tc = ThemeColors.of(widget.isDarkMode);
    final item = kTickerItems[_index];
    final vis = ClassicVisuals(tc, widget.palette);

    return RepaintBoundary(
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: vis.panelBg,
          border: Border(top: BorderSide(color: vis.line)),
          boxShadow: vis.panelShadow,
        ),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 36),
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 600),
              child: FittedBox(
                key: ValueKey(_index),
                fit: BoxFit.scaleDown,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  textDirection: TextDirection.rtl,
                  children: [
                    Text(
                      item.text,
                      textDirection: TextDirection.rtl,
                      style: TextStyle(
                        fontSize: 24,
                        height: 1.2,
                        color: tc.textPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 18),
                    Text(
                      item.source,
                      textDirection: TextDirection.rtl,
                      style: TextStyle(
                        fontSize: 18,
                        height: 1.2,
                        color: widget.palette.primary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
