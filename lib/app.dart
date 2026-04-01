import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ghasaq/l10n/app_localizations.dart';
import 'core/app_colors.dart';
import 'core/mobile_theme.dart';
import 'core/navigation/app_route_builder.dart';
import 'core/platform_config.dart';
import 'core/widgets/mobile/mobile_shell.dart';
import 'features/adhkar/presentation/screens/adhkar_screen.dart';
import 'features/prayer/presentation/screens/home_screen.dart';
import 'features/qibla/presentation/screens/qibla_screen.dart';
import 'features/settings/presentation/screens/mobile_settings_screen.dart';
import 'features/settings/presentation/settings_provider.dart';
import 'features/settings/presentation/settings_screen.dart';
import 'features/splash/presentation/splash_screen.dart';
import 'features/tasbih/domain/i_tasbih_repository.dart';
import 'features/tasbih/presentation/bloc/tasbih_bloc.dart';
import 'features/tasbih/presentation/bloc/tasbih_event.dart';
import 'features/tasbih/presentation/screens/mobile_tasbih_screen.dart';
import 'injection.dart';

class GhasaqApp extends StatelessWidget {
  const GhasaqApp({super.key});

  @override
  Widget build(BuildContext context) {
    final appSettings = context.watch<SettingsProvider>().settings;
    final palette = getThemePalette(appSettings.themeColorKey);
    final isDark = appSettings.isDarkMode;
    final tc = ThemeColors.of(isDark);
    final isTV = kIsTV;
    final effectiveFontFamily = appSettings.fontFamily;

    final schemePrimary = isTV ? palette.primary : MobileColors.primary;
    final schemeSecondary = isTV ? palette.secondary : MobileColors.secondary;

    return MaterialApp(
      onGenerateTitle: (context) => AppLocalizations.of(context).appTitle,
      debugShowCheckedModeBanner: false,
      locale: Locale(appSettings.locale),
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      theme: ThemeData(
        brightness: isDark ? Brightness.dark : Brightness.light,
        scaffoldBackgroundColor: tc.bgMain,
        primaryColor: schemePrimary,
        colorScheme: (isDark ? ColorScheme.dark() : ColorScheme.light())
            .copyWith(
              primary: schemePrimary,
              onPrimary: Colors.white,
              secondary: schemeSecondary,
              surface: tc.bgSurface,
            ),
        fontFamily: effectiveFontFamily,
        textTheme: (isDark ? ThemeData.dark() : ThemeData.light()).textTheme
            .apply(
              fontFamily: effectiveFontFamily,
              fontFamilyFallback: const ['Inter'],
              bodyColor: tc.textPrimary,
              displayColor: tc.textPrimary,
            ),
        splashFactory: NoSplash.splashFactory,
        highlightColor: Colors.transparent,
        focusColor: palette.primary.withValues(alpha: 0.3),
      ),
      builder: (_, child) {
        // TV layout is fixed LTR regardless of locale — only text direction
        // within individual widgets changes. Mobile follows the locale naturally.
        final content = child ?? const SizedBox.shrink();
        return ColoredBox(
          color: tc.bgMain,
          child: isTV
              ? Directionality(
                  textDirection: TextDirection.ltr,
                  child: content,
                )
              : content,
        );
      },
      onGenerateRoute: (routeSettings) {
        switch (routeSettings.name) {
          case '/splash':
            return buildAppRoute(
              settings: routeSettings,
              page: const SplashScreen(),
              isInstant: true,
            );
          case '/':
            return buildAppRoute(
              settings: routeSettings,
              page: isTV ? const HomeScreen() : const MobileShell(),
            );
          case '/settings':
            return buildAppRoute(
              settings: routeSettings,
              page: isTV
                  ? const SettingsScreen()
                  : const MobileSettingsScreen(),
            );
          case '/adhkar':
            return buildAppRoute(
              settings: routeSettings,
              page: const AdhkarScreen(),
            );
          case '/qibla':
            return buildAppRoute(
              settings: routeSettings,
              page: QiblaScreen(
                city: appSettings.selectedCity,
                country: appSettings.selectedCountry,
              ),
            );
          case '/tasbih':
            return buildAppRoute(
              settings: routeSettings,
              page: BlocProvider(
                create: (_) =>
                    TasbihBloc(getIt<ITasbihRepository>())
                      ..add(const TasbihStarted()),
                child: const MobileTasbihScreen(),
              ),
            );
          default:
            return buildAppRoute(
              settings: routeSettings,
              page: isTV ? const HomeScreen() : const MobileShell(),
            );
        }
      },
      initialRoute: '/splash',
    );
  }
}
