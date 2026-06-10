import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../../core/app_colors.dart';
import '../../../../prayer/presentation/painters/arabesque_painter.dart';
import '../../../../settings/presentation/settings_provider.dart';

/// Shared full-screen visual for both adhkar takeovers (silent after-prayer and
/// audio-driven morning/evening session), styled to match the in-cycle
/// `DuaScreen`: white backdrop, arabesque, top/bottom gradient bars, a pinned
/// title, and the current dhikr rendered in the Quranic `AmiriQuran` face.
/// Display-only — each screen wires its own cubit and passes the current text.
class AdhkarTakeoverBody extends StatelessWidget {
  final AccentPalette palette;
  final String title;

  /// Raw dhikr text (trailing period stripped here). Empty → chrome only.
  final String text;

  /// Drives the [AnimatedSwitcher] cross-fade between dhikr.
  final Object switchKey;

  const AdhkarTakeoverBody({
    super.key,
    required this.palette,
    required this.title,
    required this.text,
    required this.switchKey,
  });

  @override
  Widget build(BuildContext context) {
    final screenH = MediaQuery.of(context).size.height;
    final dhikrText = _stripTrailingDot(text);
    // Follow the user's light/dark choice: light keeps the clean white takeover,
    // dark uses the app's dark surface with light text (no blinding screen on a
    // 24/7 TV at Fajr/Isha).
    final isDark = context.select<SettingsProvider, bool>(
      (p) => p.settings.isDarkMode,
    );
    final tc = ThemeColors.of(isDark);
    final bg = isDark ? tc.bgMain : Colors.white;
    return Container(
      color: bg,
      child: Stack(
        children: [
          Positioned.fill(
            child: RepaintBoundary(
              child: CustomPaint(
                painter: ArabescPainter(color: palette.primary, opacity: 0.08),
              ),
            ),
          ),
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment.center,
                  radius: 1.3,
                  colors: [palette.primary.withValues(alpha: 0.07), bg],
                ),
              ),
            ),
          ),
          _bar(top: true),
          _bar(top: false),
          if (dhikrText.isNotEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(90, 72, 90, 72),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      title,
                      textDirection: TextDirection.rtl,
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.w700,
                        color: tc.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Container(
                      width: 60,
                      height: 3,
                      decoration: BoxDecoration(
                        gradient: palette.gradient,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(height: 28),
                    // Fixed-height stage so the pinned title never shifts as
                    // dhikr of different lengths fade in and out — only the
                    // dhikr text moves, keeping the motion calm.
                    SizedBox(
                      height: screenH * 0.55,
                      child: Center(
                        child: AnimatedSwitcher(
                          duration: const Duration(milliseconds: 500),
                          child: FittedBox(
                            key: ValueKey(switchKey),
                            fit: BoxFit.scaleDown,
                            child: ConstrainedBox(
                              constraints: const BoxConstraints(maxWidth: 1400),
                              child: Text(
                                dhikrText,
                                textAlign: TextAlign.center,
                                textDirection: TextDirection.rtl,
                                // AmiriQuran is a Naskh face designed for full
                                // tashkeel — diacritics sit correctly above the
                                // letters instead of crowding in like the bold
                                // UI font. Regular only, so no synthetic bold.
                                style: TextStyle(
                                  fontFamily: 'AmiriQuran',
                                  fontSize: 64,
                                  fontWeight: FontWeight.w400,
                                  color: tc.textPrimary,
                                  height: 1.9,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _bar({required bool top}) => Positioned(
    top: top ? 0 : null,
    bottom: top ? null : 0,
    left: 0,
    right: 0,
    child: Container(
      height: 6,
      decoration: BoxDecoration(gradient: palette.gradient),
    ),
  );
}

/// Drops the trailing sentence period from a dhikr so it doesn't render as a
/// stray floating dot at the end of the (RTL) line on screen.
String _stripTrailingDot(String text) =>
    text.trimRight().replaceFirst(RegExp(r'\.+$'), '').trimRight();
