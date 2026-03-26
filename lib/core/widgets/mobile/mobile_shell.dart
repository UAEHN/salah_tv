import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';

import '../../../features/adhkar/domain/i_adhkar_text_repository.dart';
import '../../../features/adhkar/presentation/bloc/adhkar_reader_cubit.dart';
import '../../../features/adhkar/presentation/bloc/adhkar_reader_state.dart';
import '../../../features/adhkar/presentation/screens/mobile/mobile_adhkar_screen.dart';
import '../../../features/prayer/presentation/screens/mobile_home_screen.dart';
import '../../../features/qibla/domain/i_qibla_repository.dart';
import '../../../features/qibla/presentation/bloc/qibla_cubit.dart';
import '../../../features/qibla/presentation/bloc/qibla_state.dart';
import '../../../features/qibla/presentation/screens/mobile/mobile_qibla_screen.dart';
import '../../../features/settings/domain/i_location_detector.dart';
import '../../../features/settings/domain/i_settings_repository.dart';
import '../../../features/settings/domain/usecases/detect_location_usecase.dart';
import '../../../features/settings/presentation/screens/mobile_settings_screen.dart';
import '../../../features/settings/presentation/settings_provider.dart';
import '../../../injection.dart';
import 'mobile_bottom_nav.dart';

/// Single-Scaffold shell for mobile: keeps all tabs alive via [IndexedStack].
/// Eliminates per-tab screen destruction/rebuild on every navigation.
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

  @override
  void initState() {
    super.initState();
    _adhkarCubit = AdhkarReaderCubit(GetIt.I<IAdhkarTextRepository>())
        ..loadCategories();
    _qiblaCubit = QiblaCubit(GetIt.I<IQiblaRepository>());
    _tryAutoDetectLocation();
  }

  Future<void> _tryAutoDetectLocation() async {
    final repo = getIt<ISettingsRepository>();
    final isFirst = await repo.isFirstLaunch();
    if (!isFirst) return;

    await repo.markLaunched();
    final useCase = DetectLocationUseCase(getIt<ILocationDetector>());
    final result = await useCase();
    if (!mounted) return;
    result.fold(
      (_) {},
      (loc) {
        final provider = context.read<SettingsProvider>();
        if (loc.isInDb) {
          provider.updateLocation(loc.dbCountryKey!, loc.dbCityKey!);
        } else {
          provider.updateWorldLocation(
            loc.countryName,
            loc.cityName,
            loc.latitude,
            loc.longitude,
            'muslim_world_league',
          );
        }
      },
    );
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

    return PopScope(
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
              child: MobileBottomNav(
                currentIndex: _currentIndex,
                onTabChanged: _onTabChanged,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
