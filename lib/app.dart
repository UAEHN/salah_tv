import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ghasaq/l10n/app_localizations.dart';
import 'core/app_colors.dart';
import 'core/navigation/app_navigator_key.dart';
import 'core/navigation/app_route_builder.dart';
import 'core/platform_config.dart';
import 'core/widgets/mobile/mobile_shell.dart';
import 'features/analytics/domain/i_analytics_service.dart';
import 'features/push_notifications/domain/i_install_id_provider.dart';
import 'features/adhkar/domain/entities/adhkar_session.dart';
import 'features/adhkar/presentation/screens/adhkar_screen.dart';
import 'features/screensaver/presentation/screens/tv/screensaver_screen.dart';
import 'features/feedback/domain/i_feedback_diagnostics_collector.dart';
import 'features/feedback/domain/usecases/submit_feedback_usecase.dart';
import 'features/customization/data/mobile_theme_palettes.dart';
import 'features/customization/domain/usecases/apply_quran_font.dart';
import 'features/customization/domain/usecases/apply_theme_palette.dart';
import 'features/customization/domain/usecases/get_all_quran_fonts.dart';
import 'features/customization/domain/usecases/get_all_theme_palettes.dart';
import 'features/customization/presentation/bloc/font_picker_cubit.dart';
import 'features/customization/presentation/bloc/settings_appearance_adapter.dart';
import 'features/customization/presentation/bloc/theme_picker_cubit.dart';
import 'features/customization/presentation/screens/mobile_font_picker_screen.dart';
import 'features/customization/presentation/screens/mobile_theme_picker_screen.dart';
import 'features/feedback/presentation/cubit/feedback_cubit.dart';
import 'features/feedback/presentation/screens/mobile_feedback_screen.dart';
import 'features/home_widget/presentation/bridge/home_widget_bridge.dart';
import 'features/prayer/presentation/screens/home_screen.dart';
import 'features/rating/domain/i_rating_service.dart';
import 'features/qibla/presentation/screens/qibla_screen.dart';
import 'features/prayer/data/composite_prayer_repository.dart';
import 'features/prayer/domain/usecases/download_city_use_case.dart';
import 'features/settings/domain/i_settings_repository.dart';
import 'features/settings/domain/i_world_city_repository.dart';
import 'features/settings/presentation/screens/mobile_settings_screen.dart';
import 'features/settings/presentation/settings_provider.dart';
import 'features/settings/presentation/settings_screen.dart';
import 'features/announcements/presentation/announcement_trigger.dart';
import 'features/app_update/presentation/app_update_trigger.dart';
import 'features/onboarding/presentation/onboarding_cubit_factory.dart';
import 'features/onboarding/presentation/onboarding_screen.dart';
import 'features/onboarding/presentation/tv_onboarding_screen.dart';
import 'features/notifications/presentation/cubit/notification_health_cubit.dart';
import 'features/notifications/presentation/onboarding/notification_onboarding_gate.dart';
import 'features/notifications/presentation/screens/notification_health_screen.dart';
import 'features/splash/presentation/splash_screen.dart';
import 'features/takbeerat/presentation/cubit/takbeerat_visibility_cubit.dart';
import 'features/tasbih/presentation/bloc/tasbih_bloc.dart';
import 'features/tasbih/presentation/screens/mobile_tasbih_screen.dart';
import 'injection.dart';

class GhasaqApp extends StatelessWidget {
  const GhasaqApp({super.key});

  @override
  Widget build(BuildContext context) {
    final appSettings = context.watch<SettingsProvider>().settings;
    final isTV = kIsTV;
    // TV exposes only the 5 legacy palettes from `kThemePalettes`. Mobile
    // additionally surfaces the extra palettes from `kMobileExtraPalettes` —
    // keep TV/mobile palette resolution split so a mobile-only theme key
    // never leaks into the TV theme picker.
    final palette = isTV
        ? getThemePalette(appSettings.themeColorKey)
        : getMobileThemePalette(appSettings.themeColorKey);
    // Resolve effective brightness: 'system' follows the device, otherwise
    // the user's explicit pref drives it. Drives ThemeData.brightness so
    // every `Theme.of(context).brightness` reader stays correct.
    final platformDark =
        MediaQuery.platformBrightnessOf(context) == Brightness.dark;
    final isDark = switch (appSettings.themeMode) {
      'system' => platformDark,
      'dark' => true,
      _ => appSettings.isDarkMode,
    };
    final tc = ThemeColors.of(isDark);
    final effectiveFontFamily = appSettings.fontFamily;

    // Both TV and mobile drive their `ColorScheme` from the active palette so
    // theme switches propagate everywhere `Theme.of(context).colorScheme` is
    // consumed (Material widgets + `MobileColors.activePrimary(context)`
    // helpers). Components that still reference `MobileColors.primary`
    // statically retain the legacy Ghasaq Gold identity.
    final schemePrimary = palette.primary;
    final schemeSecondary = palette.secondary;

    if (!isTV) {
      SystemChrome.setSystemUIOverlayStyle(
        SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
          systemNavigationBarColor: Colors.transparent,
          systemNavigationBarIconBrightness: isDark
              ? Brightness.light
              : Brightness.dark,
        ),
      );
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    }

    final observer = getIt<IAnalyticsService>().navigatorObserver;

    return MaterialApp(
      navigatorKey: appNavigatorKey,
      navigatorObservers: [observer as NavigatorObserver],
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
              ? Directionality(textDirection: TextDirection.ltr, child: content)
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
              page: BlocProvider<TakbeeratVisibilityCubit>(
                create: (_) => getIt<TakbeeratVisibilityCubit>()..load(),
                child: isTV
                    ? const AppUpdateTrigger(
                        child: AnnouncementTrigger(child: HomeScreen()),
                      )
                    : const AnnouncementTrigger(
                        child: NotificationOnboardingGate(
                          child: HomeWidgetBridge(child: MobileShell()),
                        ),
                      ),
              ),
            );
          case '/settings':
            return buildAppRoute(
              settings: routeSettings,
              page: isTV
                  ? const SettingsScreen()
                  : const MobileSettingsScreen(),
            );
          case '/adhkar':
            final session = routeSettings.arguments is AdhkarSession
                ? routeSettings.arguments as AdhkarSession
                : null;
            return buildAppRoute(
              settings: routeSettings,
              page: AdhkarScreen(initialSession: session),
            );
          case '/screensaver_preview':
            // Temporary preview route for the ambient screensaver so it can be
            // reviewed from TV settings before the idle-trigger wiring lands.
            return buildAppRoute(
              settings: routeSettings,
              page: Scaffold(body: ScreensaverScreen(palette: palette)),
            );
          case '/qibla':
            return buildAppRoute(
              settings: routeSettings,
              page: QiblaScreen(
                city: appSettings.selectedCity,
                country: appSettings.selectedCountry,
              ),
            );
          case '/notification_health':
            return buildAppRoute(
              settings: routeSettings,
              page: BlocProvider<NotificationHealthCubit>(
                create: (_) => getIt<NotificationHealthCubit>(),
                child: const NotificationHealthScreen(),
              ),
            );
          case '/tasbih':
            return buildAppRoute(
              settings: routeSettings,
              page: BlocProvider(
                create: (_) =>
                    TasbihBloc(analytics: getIt<IAnalyticsService>()),
                child: const MobileTasbihScreen(),
              ),
            );
          case '/onboarding':
            return buildAppRoute(
              settings: routeSettings,
              isInstant: true,
              page: BlocProvider(
                create: (ctx) => createOnboardingCubit(
                  settingsProvider: ctx.read<SettingsProvider>(),
                  worldRepo: getIt<IWorldCityRepository>(),
                  settingsRepository: getIt<ISettingsRepository>(),
                  downloadCityUseCase: getIt<DownloadCityUseCase>(),
                  compositeRepo: getIt<CompositePrayerRepository>(),
                  analytics: getIt<IAnalyticsService>(),
                ),
                child: const OnboardingScreen(),
              ),
            );
          case '/tv_onboarding':
            return buildAppRoute(
              settings: routeSettings,
              isInstant: true,
              page: BlocProvider(
                create: (ctx) => createOnboardingCubit(
                  settingsProvider: ctx.read<SettingsProvider>(),
                  worldRepo: getIt<IWorldCityRepository>(),
                  settingsRepository: getIt<ISettingsRepository>(),
                  downloadCityUseCase: getIt<DownloadCityUseCase>(),
                  compositeRepo: getIt<CompositePrayerRepository>(),
                  analytics: getIt<IAnalyticsService>(),
                ),
                child: const TvOnboardingScreen(),
              ),
            );
          case '/feedback':
            return buildAppRoute(
              settings: routeSettings,
              page: BlocProvider(
                create: (ctx) => FeedbackCubit(
                  ctx.read<SubmitFeedbackUseCase>(),
                  getIt<IFeedbackDiagnosticsCollector>(),
                  analytics: getIt<IAnalyticsService>(),
                  rating: getIt<IRatingService>(),
                  installIdProvider: getIt<IInstallIdProvider>(),
                ),
                child: const MobileFeedbackScreen(),
              ),
            );
          case '/theme_picker':
            return buildAppRoute(
              settings: routeSettings,
              page: BlocProvider<ThemePickerCubit>(
                create: (ctx) {
                  final adapter = SettingsAppearanceAdapter(
                    ctx.read<SettingsProvider>(),
                  );
                  final cubit = ThemePickerCubit(
                    getAll: getIt<GetAllThemePalettesUseCase>(),
                    apply: getIt<ApplyThemePaletteUseCase>(param1: adapter),
                    analytics: getIt<IAnalyticsService>(),
                  );
                  cubit.load(
                    ctx.read<SettingsProvider>().settings.themeColorKey,
                  );
                  return cubit;
                },
                child: const MobileThemePickerScreen(),
              ),
            );
          case '/font_picker':
            return buildAppRoute(
              settings: routeSettings,
              page: BlocProvider<FontPickerCubit>(
                create: (ctx) {
                  final adapter = SettingsAppearanceAdapter(
                    ctx.read<SettingsProvider>(),
                  );
                  final cubit = FontPickerCubit(
                    getAll: getIt<GetAllQuranFontsUseCase>(),
                    apply: getIt<ApplyQuranFontUseCase>(param1: adapter),
                    analytics: getIt<IAnalyticsService>(),
                  );
                  cubit.load(ctx.read<SettingsProvider>().settings.fontFamily);
                  return cubit;
                },
                child: const MobileFontPickerScreen(),
              ),
            );
          default:
            return buildAppRoute(
              settings: routeSettings,
              page: BlocProvider<TakbeeratVisibilityCubit>(
                create: (_) => getIt<TakbeeratVisibilityCubit>()..load(),
                child: isTV
                    ? const AppUpdateTrigger(
                        child: AnnouncementTrigger(child: HomeScreen()),
                      )
                    : const AnnouncementTrigger(
                        child: NotificationOnboardingGate(
                          child: HomeWidgetBridge(child: MobileShell()),
                        ),
                      ),
              ),
            );
        }
      },
      initialRoute: '/splash',
    );
  }
}
