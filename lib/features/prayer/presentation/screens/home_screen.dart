import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import '../../../../core/app_colors.dart';
import '../../../../core/localization/prayer_name_localizer.dart';
import '../../../../core/platform_config.dart';
import '../bloc/prayer_bloc.dart';
import '../bloc/prayer_event.dart';
import '../../../settings/presentation/settings_provider.dart';
import '../../../takbeerat/presentation/cubit/takbeerat_visibility_cubit.dart';
import '../widgets/home_main_view.dart';
import '../../../audio/presentation/screens/adhan_screen.dart';
import '../../../audio/presentation/screens/dua_screen.dart';
import '../../../audio/presentation/screens/iqama_screen.dart';
import '../../../audio/presentation/screens/mosque_adhan_screen.dart';
import '../../../audio/presentation/screens/mosque_iqama_screen.dart';
import '../../../audio/presentation/screens/mosque_silence_phone_screen.dart';
import '../../../adhkar/presentation/screens/tv/after_prayer_adhkar_screen.dart';
import '../../../adhkar/presentation/screens/tv/session_adhkar_screen.dart';
import '../../../screensaver/presentation/screens/tv/screensaver_screen.dart';
import '../../../../features/rating/presentation/tv_rating_trigger.dart';
import 'home_key_handler.dart';
import 'mobile_home_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late final FocusNode _focusNode;
  late final FocusNode _quranFocusNode;
  late final FocusNode _takbeeratFocusNode;

  /// Idle screensaver: [_idleReached] flips true after [_kScreensaverIdle] of
  /// no remote activity; any key press or focus gain resets it. [_screensaverVisible]
  /// caches the final visibility (computed in build) for the key handler so the
  /// first press only wakes the screen instead of acting.
  static const Duration _kScreensaverIdle = Duration(minutes: 10);
  Timer? _idleTimer; // cancelled in dispose()
  bool _idleReached = false;
  bool _screensaverVisible = false;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
    _quranFocusNode = FocusNode();
    _takbeeratFocusNode = FocusNode();
    _resetIdle();
  }

  @override
  void dispose() {
    _idleTimer?.cancel();
    _focusNode.dispose();
    _quranFocusNode.dispose();
    _takbeeratFocusNode.dispose();
    super.dispose();
  }

  /// Restarts the idle countdown and wakes the screen if it was sleeping.
  void _resetIdle() {
    _idleTimer?.cancel();
    if (_idleReached && mounted) {
      setState(() => _idleReached = false);
    }
    _idleTimer = Timer(_kScreensaverIdle, () {
      if (mounted) setState(() => _idleReached = true);
    });
  }

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>().settings;
    if (!kIsTV) {
      return MobileHomeScreen(
        city: settings.selectedCity,
        country: settings.selectedCountry,
        is24HourFormat: settings.use24HourFormat,
      );
    }

    final palette = getThemePalette(settings.themeColorKey);
    final tc = ThemeColors.of(settings.isDarkMode);
    final screenW = MediaQuery.of(context).size.width;
    final screenH = MediaQuery.of(context).size.height;

    final isAdhanPlaying = context.select(
      (PrayerBloc b) => b.state.isAdhanPlaying,
    );
    final isDuaPlaying = context.select((PrayerBloc b) => b.state.isDuaPlaying);
    final isIqamaPlaying = context.select(
      (PrayerBloc b) => b.state.isIqamaPlaying,
    );
    final isIqamaCountdown = context.select(
      (PrayerBloc b) => b.state.isIqamaCountdown,
    );
    final currentAdhanPrayerKey = context.select(
      (PrayerBloc b) => b.state.currentAdhanPrayerKey,
    );
    final iqamaPrayerKey = context.select(
      (PrayerBloc b) => b.state.iqamaPrayerKey,
    );
    final isMosqueMode = settings.isMosqueMode;
    // Mosque-mode silence-phone takeover: 10-minute window after iqama ends,
    // covering the actual prayer. Engine sets/clears the flag, so this
    // selector flips only twice per prayer (no per-tick rebuild).
    final isSilencePhoneWindow =
        isMosqueMode &&
        context.select((PrayerBloc b) => b.state.isInPostIqamaPrayer);
    // After-prayer adhkar takeover — engine flips this ~10 min after iqama
    // (non-mosque) or when the mosque prayer window ends, for a fixed display
    // window before Quran resumes.
    final isAfterPrayerAdhkar = context.select(
      (PrayerBloc b) => b.state.isAfterPrayerAdhkarPlaying,
    );
    // Morning/evening session adhkar takeover — engine flips this 25 min after
    // iqama (after Fajr → morning, Asr → evening), for a fixed display window
    // before Quran resumes. Renders the generalized [AdhkarTakeoverScreen].
    final isSessionAdhkar = context.select(
      (PrayerBloc b) => b.state.isSessionAdhkarPlaying,
    );
    final sessionAdhkarCategory = context.select(
      (PrayerBloc b) => b.state.sessionAdhkarCategory,
    );
    // Reciter URL from the hoisted takbeerat cubit — empty when the Eid
    // card isn't visible or no reciter is configured remotely, which
    // automatically disables the Arrow Up shortcut in [handleHomeKey].
    final takbeeratReciterUrl = context
        .select<TakbeeratVisibilityCubit, String>(
          (cubit) => cubit.state.defaultReciter?.url ?? '',
        );

    // Idle screensaver shows only on the bare home view: feature on, not mosque
    // mode, idle long enough, no prayer within 15 min (so the countdown stays
    // visible as it approaches), and no cycle takeover already on screen.
    // The countdown selector is bucketed to a bool so it flips rarely, not 1 Hz.
    final isScreensaverOn = settings.isScreensaverEnabled && !isMosqueMode;
    final isFarFromPrayer = context.select(
      (PrayerBloc b) => b.state.countdown.inSeconds > 15 * 60,
    );
    final noCycleTakeover =
        !isAdhanPlaying &&
        !isDuaPlaying &&
        !isIqamaPlaying &&
        !isIqamaCountdown &&
        !isSilencePhoneWindow &&
        !isAfterPrayerAdhkar &&
        !isSessionAdhkar;
    final showScreensaver =
        isScreensaverOn && _idleReached && isFarFromPrayer && noCycleTakeover;
    _screensaverVisible = showScreensaver;

    return TvRatingTrigger(
      child: PopScope(
        canPop: false,
        child: Scaffold(
          // Debug adhkar-takeover previews are triggered by the TV remote in
          // [handleHomeKey] (arrowLeft = after-prayer, arrowRight = session) —
          // a FloatingActionButton is unreachable without a touchscreen.
          body: Focus(
            focusNode: _focusNode,
            autofocus: true,
            onFocusChange: (hasFocus) {
              // Returning to the home (e.g. from settings) counts as activity.
              if (hasFocus) _resetIdle();
            },
            onKeyEvent: (_, event) {
              if (event is KeyDownEvent) {
                final wasScreensaver = _screensaverVisible;
                _resetIdle();
                // First press while the screensaver is up only wakes it.
                if (wasScreensaver) return KeyEventResult.handled;
              }
              return handleHomeKey(
                event,
                context,
                settings,
                isAdhanPlaying: isAdhanPlaying,
                isDuaPlaying: isDuaPlaying,
                isIqamaPlaying: isIqamaPlaying,
                isIqamaCountdown: isIqamaCountdown,
                quranFocusNode: _quranFocusNode,
                takbeeratFocusNode: _takbeeratFocusNode,
                takbeeratReciterUrl: takbeeratReciterUrl,
              );
            },
            child: isAdhanPlaying
                ? (isMosqueMode
                      ? MosqueAdhanScreen(
                          prayerName: localizedPrayerName(
                            context,
                            currentAdhanPrayerKey,
                          ),
                          palette: palette,
                        )
                      : AdhanScreen(
                          prayerName: localizedPrayerName(
                            context,
                            currentAdhanPrayerKey,
                          ),
                          palette: palette,
                        ))
                : isDuaPlaying
                ? DuaScreen(palette: palette)
                : isIqamaPlaying
                ? (isMosqueMode
                      ? MosqueIqamaScreen(
                          prayerName: localizedPrayerName(
                            context,
                            iqamaPrayerKey,
                          ),
                          palette: palette,
                        )
                      : IqamaScreen(
                          prayerName: localizedPrayerName(
                            context,
                            iqamaPrayerKey,
                          ),
                          palette: palette,
                        ))
                : isSilencePhoneWindow
                ? MosqueSilencePhoneScreen(palette: palette)
                : isAfterPrayerAdhkar
                ? AfterPrayerAdhkarScreen(palette: palette)
                : (isSessionAdhkar && sessionAdhkarCategory.isNotEmpty)
                ? SessionAdhkarScreen(
                    palette: palette,
                    categoryId: sessionAdhkarCategory,
                    onCompleted: () => context.read<PrayerBloc>().add(
                      const PrayerSessionAdhkarStopped(),
                    ),
                  )
                : showScreensaver
                ? ScreensaverScreen(palette: palette)
                : HomeMainView(
                    palette: palette,
                    tc: tc,
                    isIqamaCountdown: isIqamaCountdown,
                    settings: settings,
                    screenW: screenW,
                    screenH: screenH,
                    quranFocusNode: _quranFocusNode,
                    takbeeratFocusNode: _takbeeratFocusNode,
                    takbeeratReciterUrl: takbeeratReciterUrl,
                    mainFocusNode: _focusNode,
                  ),
          ),
        ),
      ),
    );
  }
}
