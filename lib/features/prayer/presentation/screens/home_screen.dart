import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import '../../../../core/app_colors.dart';
import '../../../../core/localization/prayer_name_localizer.dart';
import '../../../../core/platform_config.dart';
import '../bloc/prayer_bloc.dart';
import '../../../settings/presentation/settings_provider.dart';
import '../widgets/home_main_view.dart';
import '../../../audio/presentation/screens/adhan_screen.dart';
import '../../../audio/presentation/screens/dua_screen.dart';
import '../../../audio/presentation/screens/iqama_screen.dart';
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

    return PopScope(
      canPop: false,
      child: Scaffold(
        body: Focus(
          focusNode: _focusNode,
          autofocus: true,
          onKeyEvent: (_, event) => handleHomeKey(
            event,
            context,
            settings,
            isAdhanPlaying: isAdhanPlaying,
            isDuaPlaying: isDuaPlaying,
            isIqamaPlaying: isIqamaPlaying,
            isIqamaCountdown: isIqamaCountdown,
            quranFocusNode: _quranFocusNode,
          ),
          child: isAdhanPlaying
              ? AdhanScreen(
                  prayerName: localizedPrayerName(
                    context,
                    currentAdhanPrayerKey,
                  ),
                  palette: palette,
                )
              : isDuaPlaying
              ? DuaScreen(palette: palette)
              : isIqamaPlaying
              ? IqamaScreen(
                  prayerName: localizedPrayerName(context, iqamaPrayerKey),
                  palette: palette,
                )
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
}
