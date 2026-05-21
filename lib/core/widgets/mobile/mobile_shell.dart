import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';

import '../../../features/adhkar/domain/entities/adhkar_session.dart';
import '../../../features/adhkar/domain/i_adhkar_text_repository.dart';
import '../../../features/adhkar/presentation/bloc/adhkar_reader_cubit.dart';
import '../../../features/adhkar/presentation/bloc/adhkar_reader_state.dart';
import '../../../features/adhkar/presentation/screens/mobile/mobile_adhkar_screen.dart';
import 'mobile_shell_adhkar_tap.dart';
import '../../../features/app_update/presentation/app_update_trigger.dart';
import '../../../features/rating/presentation/rating_trigger.dart';
import '../../../features/prayer/presentation/screens/mobile_home_screen.dart';
import '../../../features/qibla/domain/i_qibla_repository.dart';
import '../../../features/qibla/presentation/bloc/qibla_cubit.dart';
import '../../../features/qibla/presentation/bloc/qibla_state.dart';
import '../../../features/qibla/presentation/screens/mobile/mobile_qibla_screen.dart';
import '../../../features/quran/presentation/bloc/mushaf_reader_cubit.dart';
import '../../../features/quran/presentation/screens/mobile/mobile_mushaf_reader_screen.dart';
import '../../../features/quran/presentation/screens/mobile/mobile_mushaf_screen.dart';
import '../../../features/settings/presentation/screens/mobile_settings_screen.dart';
import '../../../features/settings/presentation/settings_provider.dart';
import '../../../features/today/domain/usecases/get_current_greeting.dart';
import '../../../features/today/domain/usecases/get_daily_verse.dart';
import '../../../features/today/domain/usecases/get_upcoming_occasion.dart';
import '../../../features/today/presentation/bloc/today_cubit.dart';
import '../../../features/today/presentation/screens/mobile_today_screen.dart';
import 'mobile_bottom_nav.dart';

/// Mobile shell: keeps all tabs alive via [IndexedStack].
class MobileShell extends StatefulWidget {
  const MobileShell({super.key});

  /// Switch to a tab from anywhere in the mobile widget tree.
  static void switchTab(BuildContext context, int index) {
    context.findAncestorStateOfType<_MobileShellState>()?._onTabChanged(index);
  }

  /// Jump to the Adhkar tab AND open the matching reader session inline,
  /// so the user keeps the shell's bottom nav and `Back` returns to the
  /// adhkar list rather than a stranded standalone screen.
  static void openAdhkarSession(
    BuildContext context,
    AdhkarSession session,
  ) {
    context
        .findAncestorStateOfType<_MobileShellState>()
        ?._openAdhkarSession(session);
  }

  /// Pushes the Mushaf reader screen on the root navigator using the
  /// shared cubit instance, resuming from the saved bookmark when one
  /// exists. Lets the Today tab surface a «متابعة القراءة» shortcut.
  static Future<void> openMushafReader(BuildContext context) async {
    final state = context.findAncestorStateOfType<_MobileShellState>();
    if (state == null) return;
    await state._openMushafReader();
  }

  @override
  State<MobileShell> createState() => _MobileShellState();
}

class _MobileShellState extends State<MobileShell> {
  // Tab order: Settings(0), Qibla(1), Prayer(2 — center), Adhkar(3),
  // Mushaf(4), Today(5 — default).
  // `_prayerIndex = 2` is intentionally not declared — no shell logic
  // currently branches on it; the IndexedStack child position is enough.
  static const int _todayIndex = 5;
  static const int _adhkarIndex = 3;
  static const int _qiblaIndex = 1;

  int _currentIndex = _todayIndex;
  late final AdhkarReaderCubit _adhkarCubit;
  late final QiblaCubit _qiblaCubit;
  late final TodayCubit _todayCubit;
  late final MushafReaderCubit _mushafCubit;
  VoidCallback? _detachWarmAdhkar;

  @override
  void initState() {
    super.initState();
    _adhkarCubit = AdhkarReaderCubit(GetIt.I<IAdhkarTextRepository>())
        ..loadCategories();
    _qiblaCubit = QiblaCubit(GetIt.I<IQiblaRepository>());
    _todayCubit = TodayCubit(
      getGreeting: GetIt.I<GetCurrentGreetingUseCase>(),
      getOccasion: GetIt.I<GetUpcomingOccasionUseCase>(),
      getVerse: GetIt.I<GetDailyVerseUseCase>(),
    )..load();
    _mushafCubit = GetIt.I<MushafReaderCubit>();
    consumeColdStartAdhkarPayload(
      isMounted: () => mounted,
      onSession: _openAdhkarSession,
    );
    _detachWarmAdhkar = registerWarmAdhkarPayloadListener(
      isMounted: () => mounted,
      onSession: _openAdhkarSession,
    );
  }

  void _openAdhkarSession(AdhkarSession session) {
    setState(() => _currentIndex = _adhkarIndex);
    _adhkarCubit.openSession(session);
  }

  Future<void> _openMushafReader() async {
    final navigator = Navigator.of(context);
    await _mushafCubit.openReader(resume: _mushafCubit.state.bookmark);
    if (!mounted) return;
    navigator.push(MaterialPageRoute(
      builder: (_) => BlocProvider.value(
        value: _mushafCubit,
        child: const MobileMushafReaderScreen(),
      ),
    ));
  }

  void _onTabChanged(int index) {
    if (_currentIndex == index) return;
    // Lazy-start Qibla sensors on first visit
    if (index == _qiblaIndex && _qiblaCubit.state is QiblaInitial) {
      _qiblaCubit.start();
    }
    // Re-evaluate the greeting whenever the user lands on Today, in case
    // they crossed a period boundary while the tab was off-screen.
    if (index == _todayIndex) {
      _todayCubit.refreshGreeting();
    }
    setState(() => _currentIndex = index);
  }

  void _handleBack(bool didPop, _) {
    if (didPop) return;
    if (_currentIndex == _adhkarIndex) {
      final s = _adhkarCubit.state;
      if (s is AdhkarReaderReading || s is AdhkarReaderCompleted) {
        _adhkarCubit.backToCategories();
        return;
      }
    }
    if (_currentIndex != _todayIndex) {
      setState(() => _currentIndex = _todayIndex);
    }
  }

  @override
  void dispose() {
    _detachWarmAdhkar?.call();
    _adhkarCubit.close();
    _qiblaCubit.close();
    _todayCubit.close();
    _mushafCubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>().settings;
    return AppUpdateTrigger(
      child: RatingTrigger(
        child: PopScope(
          canPop: false,
          onPopInvokedWithResult: _handleBack,
          child: Scaffold(
              extendBody: true,
              body: Stack(
                children: [
                  // Qibla + Mushaf cubits hoisted around the whole stack so
                  // the Today screen can read them (mini Qibla tile + the
                  // «متابعة القراءة» shortcut) without owning separate
                  // instances. The full Qibla tab triggers `start()` lazily
                  // on its first visit; the Today tile is a passive
                  // observer.
                  MultiBlocProvider(
                    providers: [
                      BlocProvider.value(value: _qiblaCubit),
                      BlocProvider.value(value: _mushafCubit),
                    ],
                    child: IndexedStack(
                      index: _currentIndex,
                      children: [
                        const MobileSettingsScreen(),
                        MobileQiblaScreen(
                          city: settings.selectedCity,
                          country: settings.selectedCountry,
                        ),
                        MobileHomeScreen(
                          city: settings.selectedCity,
                          country: settings.selectedCountry,
                          is24HourFormat: settings.use24HourFormat,
                        ),
                        BlocProvider.value(
                          value: _adhkarCubit,
                          child: const MobileAdhkarScreen(),
                        ),
                        const MobileMushafScreen(),
                        BlocProvider.value(
                          value: _todayCubit,
                          child: const MobileTodayScreen(),
                        ),
                      ],
                    ),
                  ),
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: 0,
                    child: BlocBuilder<AdhkarReaderCubit, AdhkarReaderState>(
                      bloc: _adhkarCubit,
                      builder: (context, adhkarState) {
                        final isReading = _currentIndex == _adhkarIndex &&
                            (adhkarState is AdhkarReaderReading ||
                                adhkarState is AdhkarReaderCompleted);
                        if (isReading) return const SizedBox.shrink();
                        return MobileBottomNav(
                          currentIndex: _currentIndex,
                          onTabChanged: _onTabChanged,
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
  }
}
