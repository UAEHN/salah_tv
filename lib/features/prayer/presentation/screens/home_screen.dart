import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import '../../../../core/app_colors.dart';
import '../../../../core/platform_config.dart';
import '../../../../injection.dart';
import '../bloc/prayer_bloc.dart';
import '../bloc/prayer_event.dart';
import '../../../settings/domain/i_location_detector.dart';
import '../../../settings/domain/i_settings_repository.dart';
import '../../../settings/domain/usecases/detect_location_usecase.dart';
import '../../../settings/presentation/settings_provider.dart';
import '../../../settings/domain/entities/app_settings.dart';
import '../widgets/home_main_view.dart';
import '../../../audio/presentation/screens/adhan_screen.dart';
import '../../../audio/presentation/screens/dua_screen.dart';
import '../../../audio/presentation/screens/iqama_screen.dart';
import 'mobile_home_screen.dart';

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
    if (!kIsTV) _tryAutoDetectLocation();
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

  @override
  void dispose() {
    _focusNode.dispose();
    _quranFocusNode.dispose();
    super.dispose();
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

    final isAdhanPlaying =
        context.select((PrayerBloc b) => b.state.isAdhanPlaying);
    final isDuaPlaying =
        context.select((PrayerBloc b) => b.state.isDuaPlaying);
    final isIqamaPlaying =
        context.select((PrayerBloc b) => b.state.isIqamaPlaying);
    final isIqamaCountdown =
        context.select((PrayerBloc b) => b.state.isIqamaCountdown);
    final currentAdhanPrayerName =
        context.select((PrayerBloc b) => b.state.currentAdhanPrayerName);
    final iqamaPrayerName =
        context.select((PrayerBloc b) => b.state.iqamaPrayerName);

    return PopScope(
      canPop: false,
      child: Scaffold(
        body: Focus(
          focusNode: _focusNode,
          autofocus: true,
          onKeyEvent: (_, event) => _handleKey(
            event, context, settings, isAdhanPlaying, isDuaPlaying,
            isIqamaPlaying, isIqamaCountdown,
          ),
          child: isAdhanPlaying
              ? AdhanScreen(prayerName: currentAdhanPrayerName, palette: palette)
              : isDuaPlaying
              ? DuaScreen(palette: palette)
              : isIqamaPlaying
              ? IqamaScreen(prayerName: iqamaPrayerName, palette: palette)
              : HomeMainView(
                  palette: palette,
                  tc: tc,
                  isIqamaCountdown: isIqamaCountdown,
                  settings: settings,
                  screenW: screenW,
                  screenH: screenH,
                  quranFocusNode: _quranFocusNode,
                  mainFocusNode: _focusNode,
                ),
        ),
      ),
    );
  }

  KeyEventResult _handleKey(
    KeyEvent event,
    BuildContext context,
    AppSettings settings,
    bool isAdhanPlaying,
    bool isDuaPlaying,
    bool isIqamaPlaying,
    bool isIqamaCountdown,
  ) {
    if (event is! KeyDownEvent) return KeyEventResult.ignored;
    final key = event.logicalKey;
    if (key == LogicalKeyboardKey.mediaPlayPause ||
        key == LogicalKeyboardKey.mediaPlay ||
        key == LogicalKeyboardKey.mediaPause) {
      if (!isAdhanPlaying && !isDuaPlaying && !isIqamaPlaying) {
        context.read<PrayerBloc>().add(PrayerQuranToggled(settings.quranReciterServerUrl));
      }
      return KeyEventResult.handled;
    }
    if (key == LogicalKeyboardKey.arrowDown &&
        settings.isQuranEnabled &&
        settings.hasQuranReciter &&
        !isIqamaCountdown &&
        !isAdhanPlaying &&
        !isDuaPlaying &&
        !isIqamaPlaying) {
      _quranFocusNode.requestFocus();
      return KeyEventResult.handled;
    }
    if (key == LogicalKeyboardKey.select ||
        key == LogicalKeyboardKey.enter ||
        key == LogicalKeyboardKey.contextMenu) {
      if (isAdhanPlaying) {
        context.read<PrayerBloc>().add(const PrayerAdhanStopped());
      } else if (isDuaPlaying) {
        context.read<PrayerBloc>().add(const PrayerDuaStopped());
      } else if (isIqamaPlaying) {
        context.read<PrayerBloc>().add(const PrayerIqamaStopped());
      } else {
        Navigator.pushNamed(context, '/settings');
      }
      return KeyEventResult.handled;
    }
    return KeyEventResult.ignored;
  }
}
