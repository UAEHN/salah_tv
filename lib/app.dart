import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/app_colors.dart';
import 'features/settings/presentation/settings_provider.dart';
import 'features/prayer/presentation/screens/home_screen.dart';
import 'features/settings/presentation/settings_screen.dart';

class SalahTvApp extends StatelessWidget {
  const SalahTvApp({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>().settings;
    final palette = getThemePalette(settings.themeColorKey);

    final isDark = settings.isDarkMode;
    final tc = ThemeColors.of(isDark);

    return MaterialApp(
      title: 'مواقيت الصلاة',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: isDark ? Brightness.dark : Brightness.light,
        scaffoldBackgroundColor: tc.bgMain,
        primaryColor: palette.primary,
        colorScheme: (isDark ? ColorScheme.dark() : ColorScheme.light()).copyWith(
          primary: palette.primary,
          secondary: palette.secondary,
          surface: tc.bgSurface,
        ),
        fontFamily: settings.fontFamily,
        textTheme: (isDark ? ThemeData.dark() : ThemeData.light()).textTheme.apply(
          fontFamily: settings.fontFamily,
          bodyColor: tc.textPrimary,
          displayColor: tc.textPrimary,
        ),
        splashFactory: NoSplash.splashFactory,
        highlightColor: Colors.transparent,
        focusColor: palette.primary.withValues(alpha: 0.3),
      ),
      routes: {
        '/': (_) => const HomeScreen(),
        '/settings': (_) => const SettingsScreen(),
      },
      initialRoute: '/',
    );
  }
}
