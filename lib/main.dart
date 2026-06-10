import 'dart:async';
import 'dart:ui';

import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';

import 'app.dart';
import 'core/app_startup.dart';
import 'features/analytics/domain/i_analytics_service.dart';
import 'features/feedback/domain/i_feedback_repository.dart';
import 'features/feedback/domain/usecases/submit_feedback_usecase.dart';
import 'features/home_widget/domain/i_home_widget_repository.dart';
import 'features/home_widget/domain/usecases/get_upcoming_schedule.dart';
import 'features/home_widget/domain/usecases/publish_widget_payload.dart';
import 'features/prayer/domain/i_prayer_audio_port.dart';
import 'features/prayer/domain/i_takbeerat_audio_port.dart';
import 'features/notifications/domain/i_prayer_notification_port.dart';
import 'features/prayer/domain/i_prayer_times_repository.dart';
import 'features/prayer/presentation/bloc/prayer_bloc.dart';
import 'features/prayer/presentation/bloc/prayer_event.dart';
import 'features/quran/domain/entities/quran_playback_mode.dart';
import 'features/settings/domain/entities/app_settings.dart';
import 'features/settings/domain/entities/app_settings_copy_with.dart';
import 'features/settings/domain/i_location_detector.dart';
import 'features/settings/domain/i_settings_repository.dart';
import 'features/settings/presentation/bloc/first_launch_location_cubit.dart';
import 'features/settings/presentation/settings_provider.dart';
import 'injection.dart';

void main() async {
  // Global crash guard: every uncaught Flutter / Dart / platform error
  // is forwarded to Crashlytics so the TV never silently swallows a fault.
  // Required by §8 of CLAUDE.md (zero-tolerance crash policy).
  runZonedGuarded(
    () async {
      WidgetsFlutterBinding.ensureInitialized();
      // initDependencies() calls initializeFirebase() — Crashlytics is not
      // safe to reference before this completes, so register the handlers
      // only after Firebase is initialized.
      final settings = await initDependencies();
      // Same flag the splash uses to route to onboarding. Keeps the prayer
      // engine dormant until onboarding commits a real city.
      final isFirstLaunch = await getIt<ISettingsRepository>().isFirstLaunch();
      FlutterError.onError =
          FirebaseCrashlytics.instance.recordFlutterFatalError;
      PlatformDispatcher.instance.onError = (error, stack) {
        FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
        return true;
      };
      runApp(_buildApp(settings, isFirstLaunch));
    },
    (error, stack) {
      // Defensive: pre-init errors must not themselves crash the guard.
      try {
        FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
      } catch (_) {}
    },
  );
}

Widget _buildApp(AppSettings settings, bool isFirstLaunch) {
  return MultiProvider(
    providers: [
      Provider<ISettingsRepository>.value(value: getIt<ISettingsRepository>()),
      if (getIt.isRegistered<IFeedbackRepository>())
        Provider<SubmitFeedbackUseCase>(
          create: (_) => SubmitFeedbackUseCase(getIt<IFeedbackRepository>()),
        ),
      if (getIt.isRegistered<ILocationDetector>())
        Provider<ILocationDetector>.value(value: getIt<ILocationDetector>()),
      if (getIt.isRegistered<IHomeWidgetRepository>()) ...[
        Provider<PublishWidgetPayloadUseCase>(
          create: (_) => getIt<PublishWidgetPayloadUseCase>(),
        ),
        Provider<GetUpcomingScheduleUseCase>(
          create: (_) => getIt<GetUpcomingScheduleUseCase>(),
        ),
      ],
      ChangeNotifierProvider(
        create: (_) => SettingsProvider(
          getIt<ISettingsRepository>(),
          settings,
          analytics: getIt<IAnalyticsService>(),
        ),
      ),
      if (getIt.isRegistered<ILocationDetector>())
        BlocProvider(
          create: (context) => FirstLaunchLocationCubit(
            context.read<SettingsProvider>(),
            context.read<ISettingsRepository>(),
            context.read<ILocationDetector>(),
          )..runOnce(),
        ),
      BlocProvider(
        create: (context) {
          final bloc = PrayerBloc(
            getIt<IPrayerTimesRepository>(),
            getIt<IPrayerAudioPort>(),
            getIt<ITakbeeratAudioPort>(),
            settings,
            notifications: getIt.isRegistered<IPrayerNotificationPort>()
                ? getIt<IPrayerNotificationPort>()
                : null,
            analytics: getIt<IAnalyticsService>(),
            onCurrentSurahChanged: (surah) {
              final sp = context.read<SettingsProvider>();
              if (sp.settings.quranPlaybackMode ==
                  QuranPlaybackMode.continuous) {
                sp.updateLastPlayedSurah(surah);
              }
            },
          );
          // Don't start the 1Hz tick / audio engine on first launch. The
          // bundled default city ('Dubai') is non-empty, so an isEmpty check
          // alone is NOT enough — gate on the first-launch flag so the
          // adhan/quran/takbeerat cycle never fires with default state during
          // onboarding. Onboarding dispatches PrayerStarted on completion.
          if (!isFirstLaunch &&
              settings.selectedCity.isNotEmpty &&
              settings.selectedCountry.isNotEmpty) {
            bloc.add(const PrayerStarted());
          }
          return bloc;
        },
      ),
    ],
    child: const _SettingsBridgeWrapper(),
  );
}

/// Bridges [SettingsProvider] → [PrayerBloc]: listens for settings changes and
/// dispatches [PrayerSettingsUpdated] only when settings actually change,
/// never on unrelated widget rebuilds.
class _SettingsBridgeWrapper extends StatefulWidget {
  const _SettingsBridgeWrapper();

  @override
  State<_SettingsBridgeWrapper> createState() => _SettingsBridgeWrapperState();
}

class _SettingsBridgeWrapperState extends State<_SettingsBridgeWrapper> {
  late final SettingsProvider _sp;
  late AppSettings _prev;

  @override
  void initState() {
    super.initState();
    _sp = context.read<SettingsProvider>();
    _prev = _sp.settings;
    _sp.addListener(_onSettingsChanged);
  }

  void _onSettingsChanged() {
    final next = _sp.settings;
    if (_prev.prayerFieldsEqual(next)) {
      _prev = next;
      return;
    }
    _prev = next;
    context.read<PrayerBloc>().add(PrayerSettingsUpdated(next));
  }

  @override
  void dispose() {
    _sp.removeListener(_onSettingsChanged);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => const GhasaqApp();
}
