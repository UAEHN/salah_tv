import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';

import '../../../features/adhkar/domain/i_adhkar_text_repository.dart';
import '../../../features/adhkar/presentation/bloc/adhkar_reader_cubit.dart';
import '../../../features/adhkar/presentation/bloc/adhkar_reader_state.dart';
import '../../../features/adhkar/presentation/screens/mobile/mobile_adhkar_screen.dart';
import '../../../features/app_tour/presentation/app_tour_cubit.dart';
import '../../../features/app_update/presentation/app_update_trigger.dart';
import '../../../features/rating/presentation/rating_trigger.dart';
import '../../../features/prayer/presentation/screens/mobile_home_screen.dart';
import '../../../features/qibla/domain/i_qibla_repository.dart';
import '../../../features/qibla/presentation/bloc/qibla_cubit.dart';
import '../../../features/qibla/presentation/bloc/qibla_state.dart';
import '../../../features/qibla/presentation/screens/mobile/mobile_qibla_screen.dart';
import '../../../features/settings/presentation/screens/mobile_settings_screen.dart';
import '../../../features/settings/presentation/settings_provider.dart';
import 'mobile_bottom_nav.dart';
import 'mobile_shell_tour_launcher.dart';
import 'tour_target_keys.dart';

/// Mobile shell: keeps all tabs alive via [IndexedStack].
class MobileShell extends StatefulWidget {
  const MobileShell({super.key});

  /// Switch to a tab from anywhere in the mobile widget tree.
  static void switchTab(BuildContext context, int index) {
    context.findAncestorStateOfType<_MobileShellState>()?._onTabChanged(index);
  }

  @override
  State<MobileShell> createState() => _MobileShellState();
}

class _MobileShellState extends State<MobileShell> {
  int _currentIndex = 3;
  late final AdhkarReaderCubit _adhkarCubit;
  late final QiblaCubit _qiblaCubit;
  final _tourKeys = TourTargetKeys();

  @override
  void initState() {
    super.initState();
    _adhkarCubit = AdhkarReaderCubit(GetIt.I<IAdhkarTextRepository>())
        ..loadCategories();
    _qiblaCubit = QiblaCubit(GetIt.I<IQiblaRepository>());
    _checkTourFromRoute();
  }

  void _checkTourFromRoute() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final args = ModalRoute.of(context)?.settings.arguments;
      if (args is Map && args['showTour'] == true) {
        context.read<AppTourCubit>().checkAndRequestTour();
      }
    });
  }

  void _onTabChanged(int index) {
    if (_currentIndex == index) return;
    // Lazy-start Qibla sensors on first visit
    if (index == 1 && _qiblaCubit.state is QiblaInitial) {
      _qiblaCubit.start();
    }
    setState(() => _currentIndex = index);
  }

  void _handleBack(bool didPop, _) {
    if (didPop) return;
    if (_currentIndex == 2) {
      final s = _adhkarCubit.state;
      if (s is AdhkarReaderReading || s is AdhkarReaderCompleted) {
        _adhkarCubit.backToCategories();
        return;
      }
    }
    if (_currentIndex != 3) {
      setState(() => _currentIndex = 3);
    }
  }

  @override
  void dispose() {
    _adhkarCubit.close();
    _qiblaCubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>().settings;
    return AppUpdateTrigger(
      child: RatingTrigger(
        child: TourTargetKeysProvider(
        keys: _tourKeys,
        child: MobileShellTourLauncher(
          tourKeys: _tourKeys,
          child: PopScope(
            canPop: false,
            onPopInvokedWithResult: _handleBack,
            child: Scaffold(
              extendBody: true,
              body: Stack(
                children: [
                  IndexedStack(
                    index: _currentIndex,
                    children: [
                      const MobileSettingsScreen(),
                      BlocProvider.value(
                        value: _qiblaCubit,
                        child: MobileQiblaScreen(
                          city: settings.selectedCity,
                          country: settings.selectedCountry,
                        ),
                      ),
                      BlocProvider.value(
                        value: _adhkarCubit,
                        child: const MobileAdhkarScreen(),
                      ),
                      MobileHomeScreen(
                        city: settings.selectedCity,
                        country: settings.selectedCountry,
                        is24HourFormat: settings.use24HourFormat,
                      ),
                    ],
                  ),
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: 0,
                    child: BlocBuilder<AdhkarReaderCubit, AdhkarReaderState>(
                      bloc: _adhkarCubit,
                      builder: (context, adhkarState) {
                        final isReading = _currentIndex == 2 &&
                            (adhkarState is AdhkarReaderReading ||
                                adhkarState is AdhkarReaderCompleted);
                        if (isReading) return const SizedBox.shrink();
                        return KeyedSubtree(
                          key: _tourKeys.bottomNav,
                          child: MobileBottomNav(
                            currentIndex: _currentIndex,
                            onTabChanged: _onTabChanged,
                          ),
                        );
                      },
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
