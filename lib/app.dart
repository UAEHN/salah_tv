import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/app_colors.dart';
import 'core/mobile_theme.dart';
import 'core/platform_config.dart';
import 'features/settings/presentation/settings_provider.dart';
import 'features/prayer/presentation/screens/home_screen.dart';
import 'features/settings/presentation/settings_screen.dart';
import 'features/qibla/presentation/screens/qibla_screen.dart';
import 'features/app_update/presentation/widgets/update_listener_widget.dart';
import 'features/splash/presentation/splash_screen.dart';

class SalahTvApp extends StatelessWidget {
  const SalahTvApp({super.key});

  static PageRoute<void> _buildRoute({
    required RouteSettings settings,
    required Widget page,
    bool isInstant = false,
  }) {
    return PageRouteBuilder<void>(
      settings: settings,
      transitionDuration: isInstant
          ? Duration.zero
          : const Duration(milliseconds: 220),
      reverseTransitionDuration: isInstant
          ? Duration.zero
          : const Duration(milliseconds: 180),
      pageBuilder: (_, _, _) => page,
      transitionsBuilder: (_, animation, _, child) {
        if (isInstant) return child;
        final curved = CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutCubic,
          reverseCurve: Curves.easeInCubic,
        );
        return FadeTransition(
          opacity: curved,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0.02, 0),
              end: Offset.zero,
            ).animate(curved),
            child: child,
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final appSettings = context.watch<SettingsProvider>().settings;
    final palette = getThemePalette(appSettings.themeColorKey);

    final isDark = appSettings.isDarkMode;
    final tc = ThemeColors.of(isDark);
    final isTV = kIsTV;
    final schemePrimary = isTV ? palette.primary : MobileColors.primary;
    final schemeSecondary = isTV ? palette.secondary : MobileColors.secondary;
    final schemeOnPrimary = Colors.white;

    return MaterialApp(
      title: 'مواقيت الصلاة',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: isDark ? Brightness.dark : Brightness.light,
        scaffoldBackgroundColor: tc.bgMain,
        primaryColor: schemePrimary,
        colorScheme: (isDark ? ColorScheme.dark() : ColorScheme.light())
            .copyWith(
              primary: schemePrimary,
              onPrimary: schemeOnPrimary,
              secondary: schemeSecondary,
              surface: tc.bgSurface,
            ),
        fontFamily: appSettings.fontFamily,
        textTheme: (isDark ? ThemeData.dark() : ThemeData.light()).textTheme
            .apply(
              fontFamily: appSettings.fontFamily,
              bodyColor: tc.textPrimary,
              displayColor: tc.textPrimary,
            ),
        splashFactory: NoSplash.splashFactory,
        highlightColor: Colors.transparent,
        focusColor: palette.primary.withValues(alpha: 0.3),
      ),
      builder: (_, child) {
        return ColoredBox(
          color: tc.bgMain,
          child: child ?? const SizedBox.shrink(),
        );
      },
      onGenerateRoute: (routeSettings) {
        switch (routeSettings.name) {
          case '/splash':
            return _buildRoute(
              settings: routeSettings,
              page: const SplashScreen(),
              isInstant: true,
            );
          case '/':
            return _buildRoute(
              settings: routeSettings,
              page: const UpdateListenerWidget(child: HomeScreen()),
            );
          case '/settings':
            return _buildRoute(
              settings: routeSettings,
              page: const SettingsScreen(),
            );
          case '/qibla':
            return _buildRoute(
              settings: routeSettings,
              page: QiblaScreen(
                city: appSettings.selectedCity,
                country: appSettings.selectedCountry,
              ),
            );
          default:
            return _buildRoute(
              settings: routeSettings,
              page: const UpdateListenerWidget(child: HomeScreen()),
            );
        }
      },
      initialRoute: '/splash',
    );
  }
}
