import 'dart:async';
import 'dart:isolate';
import 'dart:ui';

import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';

import 'app.dart';
import 'core/app_startup.dart';
import 'core/diagnostics/app_diagnostics.dart';
import 'core/diagnostics/diagnostic_level.dart' as diag;
import 'core/error_reporting/domain/i_error_reporting_service.dart';
import 'core/error_reporting/global_error_hooks.dart';
import 'core/error_reporting/widgets/graceful_error_widget.dart';
import 'core/health/heartbeat_service.dart';
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
import 'features/prayer/domain/i_session_adhkar_log_port.dart';
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
      FlutterError.onError = (details) {
        _recordFlutterError(details);
      };
      // Never leave a weak device on a blank/grey box when a screen fails to
      // render — paint a calm fallback AND record that it happened.
      ErrorWidget.builder = (details) => GracefulErrorWidget(details: details);
      PlatformDispatcher.instance.onError = (error, stack) {
        FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
        _recordFatal('platform_dispatcher_error', error, stack);
        return true;
      };
      Isolate.current.addErrorListener(
        RawReceivePort((pair) {
          final data = pair as List<dynamic>;
          final error = data.first;
          final stack = StackTrace.fromString(data.last.toString());
          _recordFatal('isolate_uncaught_error', error, stack);
        }).sendPort,
      );
      runApp(_buildApp(settings, isFirstLaunch));
    },
    (error, stack) {
      // Defensive: pre-init errors must not themselves crash the guard.
      try {
        FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
      } catch (_) {}
      _recordFatal('zone_uncaught_error', error, stack);
    },
  );
}

void _recordFlutterError(FlutterErrorDetails details) {
  final error = details.exception;
  final stack = details.stack ?? StackTrace.current;
  if (_isNonFatalFlutterLayoutError(details)) {
    try {
      unawaited(
        FirebaseCrashlytics.instance.recordFlutterError(details, fatal: false),
      );
    } catch (_) {}
    _recordDiagnostic(
      diag.DiagnosticLevel.error,
      'flutter_non_fatal_layout_error',
      error,
      stack,
    );
    reportUncaught(
      'flutter_non_fatal_layout_error',
      error,
      stack,
      isFatal: false,
      isLayout: true,
    );
    return;
  }

  FirebaseCrashlytics.instance.recordFlutterFatalError(details);
  _recordFatal('flutter_error', error, stack);
}

bool _isNonFatalFlutterLayoutError(FlutterErrorDetails details) {
  final text = details.exceptionAsString();
  return text.contains('RenderBox was not laid out') ||
      text.contains('RenderFlex overflowed') ||
      details.library == 'rendering library';
}

void _recordFatal(String name, Object error, StackTrace stack) {
  _recordDiagnostic(diag.DiagnosticLevel.fatal, name, error, stack);
  // Full-context error record (fingerprint, breadcrumbs, device state) —
  // covers the zone / platform-dispatcher / isolate / flutter-fatal hooks.
  reportUncaught(name, error, stack);
}

void _recordDiagnostic(
  diag.DiagnosticLevel level,
  String name,
  Object error,
  StackTrace stack,
) {
  try {
    if (!getIt.isRegistered<AppDiagnostics>()) return;
    unawaited(
      getIt<AppDiagnostics>().record(
        level,
        name,
        error: error,
        stack: stack,
        forceUpload: true,
      ),
    );
  } catch (_) {}
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
            sessionAdhkarLog: getIt.isRegistered<ISessionAdhkarLogPort>()
                ? getIt<ISessionAdhkarLogPort>()
                : null,
            analytics: getIt<IAnalyticsService>(),
            diagnostics: getIt.isRegistered<AppDiagnostics>()
                ? getIt<AppDiagnostics>()
                : null,
            onCurrentSurahChanged: (surah) {
              final sp = context.read<SettingsProvider>();
              if (sp.settings.quranPlaybackMode ==
                  QuranPlaybackMode.continuous) {
                sp.updateLastPlayedSurah(surah);
              }
            },
          );
          if (getIt.isRegistered<HeartbeatService>()) {
            getIt<HeartbeatService>().snapshotProvider = () {
              final s = bloc.state;
              final liveSettings = context.read<SettingsProvider>().settings;
              return {
                'selected_city': liveSettings.selectedCity,
                'selected_country': liveSettings.selectedCountry,
                'next_prayer_key': s.nextPrayerKey,
                'countdown_seconds': s.countdown.inSeconds,
                'has_prayer_data': s.todayPrayers != null,
                'is_cycle_active': s.isCycleActive,
                'is_adhan_playing': s.isAdhanPlaying,
                'is_iqama_countdown': s.isIqamaCountdown,
                'is_iqama_playing': s.isIqamaPlaying,
                'is_dua_playing': s.isDuaPlaying,
                'active_cycle_prayer': s.activeCyclePrayerKey,
                if (s.lastTickError != null) 'last_tick_error': s.lastTickError,
                // Settings profile — lets the dashboard answer "how is this
                // device configured?" for support without contacting the user.
                'adhan_mode': liveSettings.adhanMode.name,
                'iqama_mode': liveSettings.iqamaMode.name,
                'is_mosque_mode': liveSettings.isMosqueMode,
                'is_quran_enabled': liveSettings.isQuranEnabled,
                'reciter': liveSettings.quranReciterName,
                'adhan_sound': liveSettings.adhanSound,
                'iqama_sound': liveSettings.iqamaSound,
                'calc_method': liveSettings.calculationMethod,
                'madhab': liveSettings.madhab,
                'data_source': liveSettings.isCalculatedLocation
                    ? 'calculated'
                    : 'downloaded',
                'layout': liveSettings.layoutStyle,
                'locale': liveSettings.locale,
                // The device's own wall clock at beat time — lets the dashboard
                // show "the user's clock" and spot clock drift.
                'device_time': DateTime.now().toIso8601String(),
              };
            };
            // Beat now that the snapshot (city/country) is wired, so the
            // dashboard shows the device's location on launch instead of waiting
            // for the 15-min periodic beat (a device reopened before then would
            // otherwise stay "unknown").
            getIt<HeartbeatService>().beatNow();
          }
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
    if (getIt.isRegistered<AppDiagnostics>()) {
      unawaited(
        getIt<AppDiagnostics>().setContext({
          'selected_country': next.selectedCountry,
          'selected_city': next.selectedCity,
          'adhan_mode': next.adhanMode.name,
          'iqama_mode': next.iqamaMode.name,
          'is_mosque_mode': next.isMosqueMode,
        }),
      );
    }
    if (getIt.isRegistered<IErrorReportingService>()) {
      getIt<IErrorReportingService>().setContext({
        'selected_country': next.selectedCountry,
        'selected_city': next.selectedCity,
        'adhan_mode': next.adhanMode.name,
        'iqama_mode': next.iqamaMode.name,
        'is_mosque_mode': next.isMosqueMode,
      });
    }
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
