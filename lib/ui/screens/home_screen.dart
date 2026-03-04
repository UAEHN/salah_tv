import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../core/app_colors.dart';
import '../../providers/prayer_provider.dart';
import '../../providers/settings_provider.dart';
import '../../ui/painters/arabesque_painter.dart';
import '../widgets/clock_widget.dart';
import '../widgets/date_widget.dart';
import '../widgets/iqama_countdown_widget.dart';
import '../widgets/next_prayer_widget.dart';
import '../widgets/prayer_panel.dart';
import 'adhan_screen.dart';
import 'dua_screen.dart';
import 'iqama_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late final FocusNode _focusNode;
  late final FocusNode _quranFocusNode;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
    _quranFocusNode = FocusNode();
  }

  @override
  void dispose() {
    _focusNode.dispose();
    _quranFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>().settings;
    final palette  = getThemePalette(settings.themeColorKey);
    final tc       = ThemeColors.of(settings.isDarkMode);
    final screenW  = MediaQuery.of(context).size.width;
    final screenH  = MediaQuery.of(context).size.height;

    final prayerProv     = context.watch<PrayerProvider>();
    final reciterServerUrl = settings.quranReciterServerUrl;

    return PopScope(
      canPop: false,
      child: Scaffold(
        body: Focus(
          focusNode: _focusNode,
          autofocus: true,
          onKeyEvent: (_, event) {
            if (event is KeyDownEvent) {
              // Media play/pause key (most TV remotes have this)
              if (event.logicalKey == LogicalKeyboardKey.mediaPlayPause ||
                  event.logicalKey == LogicalKeyboardKey.mediaPlay ||
                  event.logicalKey == LogicalKeyboardKey.mediaPause) {
                if (!prayerProv.isAdhanPlaying &&
                    !prayerProv.isDuaPlaying &&
                    !prayerProv.isIqamaPlaying) {
                  prayerProv.toggleQuran(reciterServerUrl);
                }
                return KeyEventResult.handled;
              }

              // D-pad DOWN → focus the Quran button (if visible)
              if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
                if (settings.isQuranEnabled &&
                    settings.hasQuranReciter &&
                    !prayerProv.isIqamaCountdown &&
                    !prayerProv.isAdhanPlaying &&
                    !prayerProv.isDuaPlaying &&
                    !prayerProv.isIqamaPlaying) {
                  _quranFocusNode.requestFocus();
                  return KeyEventResult.handled;
                }
              }

              if (event.logicalKey == LogicalKeyboardKey.select ||
                  event.logicalKey == LogicalKeyboardKey.enter ||
                  event.logicalKey == LogicalKeyboardKey.contextMenu) {
                if (prayerProv.isAdhanPlaying) {
                  prayerProv.stopAdhan();
                  return KeyEventResult.handled;
                } else if (prayerProv.isDuaPlaying) {
                  prayerProv.stopDua();
                  return KeyEventResult.handled;
                } else if (prayerProv.isIqamaPlaying) {
                  prayerProv.stopIqama();
                  return KeyEventResult.handled;
                } else {
                  Navigator.pushNamed(context, '/settings');
                  return KeyEventResult.handled;
                }
              }
            }
            return KeyEventResult.ignored;
          },
          child: prayerProv.isAdhanPlaying
              ? AdhanScreen(
                  prayerName: prayerProv.currentAdhanPrayerName,
                  palette: palette,
                )
              : prayerProv.isDuaPlaying
                  ? DuaScreen(palette: palette)
                  : prayerProv.isIqamaPlaying
                      ? IqamaScreen(
                          prayerName: prayerProv.iqamaPrayerName,
                          palette: palette,
                        )
                      : Container(
            decoration: BoxDecoration(gradient: tc.bgGradient),
            child: Stack(
              children: [
                // Islamic geometric pattern
                Positioned.fill(
                  child: CustomPaint(
                    painter: ArabescPainter(color: palette.primary, opacity: 0.05),
                  ),
                ),

                // Soft radial gradient overlay from accent
                Positioned.fill(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: RadialGradient(
                        center: Alignment.centerRight,
                        radius: 1.2,
                        colors: [
                          palette.glow.withValues(alpha: settings.isDarkMode ? 0.12 : 0.08),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                ),

                // Main layout: Column with top content + bottom bar
                Column(
                  children: [
                    // === TOP AREA: Prayer panel (left) + Clock/Date/Hadith (right) ===
                    Expanded(
                      child: Row(
                        children: [
                          // === LEFT PANEL (~30%): Prayer times ===
                          Container(
                            width: screenW * 0.30,
                            margin: EdgeInsets.all(screenH * 0.03),
                            child: const PrayerPanel(),
                          ),

                          // === RIGHT PANEL (~62%): Clock, date, hadith ===
                          Expanded(
                            child: Center(
                              child: SingleChildScrollView(
                                padding: EdgeInsets.symmetric(
                                  horizontal: screenW * 0.04,
                                  vertical: screenH * 0.03,
                                ),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment:
                                      CrossAxisAlignment.center,
                                  children: [
                                    // Large Clock
                                    ClockWidget(palette: palette),

                                    SizedBox(height: screenH * 0.01),

                                    // Hijri Date
                                    DateWidget(palette: palette),

                                    SizedBox(height: screenH * 0.04),

                                    // Next Prayer Section
                                    NextPrayerWidget(palette: palette),

                                    // Quran pill button — hides during iqama countdown
                                    AnimatedSize(
                                      duration: const Duration(milliseconds: 350),
                                      curve: Curves.easeInOut,
                                      child: (settings.isQuranEnabled &&
                                              settings.hasQuranReciter &&
                                              !prayerProv.isIqamaCountdown)
                                          ? Padding(
                                              padding: EdgeInsets.only(
                                                  top: screenH * 0.022),
                                              child: _HomeQuranButton(
                                                palette: palette,
                                                isDarkMode: settings.isDarkMode,
                                                serverUrl: settings
                                                    .quranReciterServerUrl,
                                                focusNode: _quranFocusNode,
                                                onEscape: () =>
                                                    _focusNode.requestFocus(),
                                              ),
                                            )
                                          : const SizedBox.shrink(),
                                    ),

                                    // Iqama Countdown (shown only when active)
                                    AnimatedSize(
                                      duration: const Duration(milliseconds: 400),
                                      curve: Curves.easeInOut,
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          if (prayerProv.isIqamaCountdown)
                                            SizedBox(height: screenH * 0.025),
                                          IqamaCountdownWidget(palette: palette),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ── Quran pill button with animated sweep-gradient border ────────────────────

class _HomeQuranButton extends StatefulWidget {
  final AccentPalette palette;
  final String serverUrl;
  final bool isDarkMode;
  final FocusNode focusNode;
  final VoidCallback? onEscape;

  const _HomeQuranButton({
    required this.palette,
    required this.serverUrl,
    required this.isDarkMode,
    required this.focusNode,
    this.onEscape,
  });

  @override
  State<_HomeQuranButton> createState() => _HomeQuranButtonState();
}

class _HomeQuranButtonState extends State<_HomeQuranButton>
    with TickerProviderStateMixin {
  late final AnimationController _rotCtrl;  // border rotation (4s, repeating)
  late final AnimationController _glowCtrl; // idle↔playing fade (600ms)
  late final Animation<double> _fade;
  bool _focused = false;
  bool _lastPlaying = false;

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

    // Listen to external focus node so _focused stays in sync
    widget.focusNode.addListener(_onFocusChange);
  }

  void _onFocusChange() {
    setState(() => _focused = widget.focusNode.hasFocus);
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
    final prayerProv = context.watch<PrayerProvider>();
    final isPlaying = prayerProv.isQuranPlaying;
    final isPausedForAdhan = prayerProv.quranUserEnabled && !isPlaying;

    // Drive the fade controller whenever playing state changes
    if (isPlaying != _lastPlaying) {
      _lastPlaying = isPlaying;
      isPlaying ? _glowCtrl.forward() : _glowCtrl.reverse();
    }

    return Focus(
      focusNode: widget.focusNode,
      onKeyEvent: (_, event) {
        if (event is KeyDownEvent) {
          // Center button → toggle Quran
          if (event.logicalKey == LogicalKeyboardKey.select ||
              event.logicalKey == LogicalKeyboardKey.enter) {
            context.read<PrayerProvider>().toggleQuran(widget.serverUrl);
            return KeyEventResult.handled;
          }
          // D-pad UP → return focus to the main screen
          if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
            widget.onEscape?.call();
            return KeyEventResult.handled;
          }
        }
        return KeyEventResult.ignored;
      },
      child: GestureDetector(
        onTap: () =>
            context.read<PrayerProvider>().toggleQuran(widget.serverUrl),
        child: AnimatedBuilder(
          animation: Listenable.merge([_rotCtrl, _fade]),
          builder: (_, __) {
            final angle = _rotCtrl.value * 2 * math.pi;
            final pulse = (math.sin(angle * 2) + 1) / 2; // fast glow cycle
            final t = _fade.value; // 0 = idle, 1 = playing

            // Lerp border gradient alphas: idle(0.45→0.70) ↔ playing(0.65→0.95)
            final a0 = 0.45 + (0.65 - 0.45) * t;
            final a1 = 0.70 + (0.95 - 0.70) * t;

            // Lerp glow shadow — fades in as t increases
            final shadowAlpha = (0.25 + pulse * 0.35) * t;
            final blurR = (10 + pulse * 8) * t;
            final spreadR = (pulse * 1.5) * t;

            // Lerp inner background — adapts to dark / light mode
            // Playing state gets a stronger opaque backing so text stays readable
            final idleInner = widget.isDarkMode
                ? Colors.white.withValues(alpha: 0.10)
                : Colors.black.withValues(alpha: 0.07);
            final playingInner = widget.isDarkMode
                ? Colors.black.withValues(alpha: 0.55)
                : Colors.white.withValues(alpha: 0.75);
            final innerColor = Color.lerp(idleInner, playingInner, t)!;

            // Text stays high-contrast always — never blends with glow
            final textColor = widget.isDarkMode
                ? Colors.white.withValues(alpha: 0.92 + 0.08 * t)
                : kTextPrimary.withValues(alpha: 0.88 + 0.12 * t);

            // Icon animates to palette color for visual playing feedback
            final idleIconColor = widget.isDarkMode
                ? Colors.white.withValues(alpha: 0.85)
                : kTextPrimary.withValues(alpha: 0.80);
            final iconColor = Color.lerp(
              idleIconColor,
              widget.isDarkMode ? widget.palette.primary : widget.palette.secondary,
              t,
            )!;

            // Text shadow grows during playback to maintain contrast against glow
            final textShadow = t > 0.05
                ? Shadow(
                    color: widget.isDarkMode
                        ? Colors.black.withValues(alpha: 0.6 * t)
                        : Colors.white.withValues(alpha: 0.7 * t),
                    blurRadius: 6 * t,
                  )
                : null;

            return Container(
              padding: const EdgeInsets.all(1.5),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(30),
                gradient: SweepGradient(
                  startAngle: angle,
                  endAngle: angle + 2 * math.pi,
                  colors: [
                    widget.palette.primary.withValues(alpha: a0),
                    widget.palette.primary.withValues(alpha: a1),
                    widget.palette.primary.withValues(alpha: a0),
                  ],
                  stops: const [0.0, 0.5, 1.0],
                ),
                border: _focused
                    ? Border.all(
                        color: widget.isDarkMode
                            ? Colors.white.withValues(alpha: 0.9)
                            : kTextPrimary.withValues(alpha: 0.85),
                        width: 2)
                    : null,
                boxShadow: shadowAlpha > 0.01
                    ? [
                        BoxShadow(
                          color: widget.palette.glow
                              .withValues(alpha: shadowAlpha),
                          blurRadius: blurR,
                          spreadRadius: spreadR,
                        ),
                      ]
                    : null,
              ),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(28.5),
                  color: innerColor,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      child: Icon(
                        isPlaying
                            ? Icons.stop_rounded
                            : Icons.play_arrow_rounded,
                        key: ValueKey(isPlaying),
                        color: iconColor,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'القرآن الكريم',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.lerp(
                              FontWeight.w600, FontWeight.w700, t) ??
                            FontWeight.w600,
                        color: textColor,
                        letterSpacing: 0.5,
                        shadows: textShadow != null ? [textShadow] : null,
                      ),
                    ),
                    if (isPausedForAdhan) ...[
                      const SizedBox(width: 8),
                      Icon(
                        Icons.pause_circle_outline_rounded,
                        color: const Color(0xFFF59E0B).withValues(alpha: 0.90),
                        size: 18,
                      ),
                    ],
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
