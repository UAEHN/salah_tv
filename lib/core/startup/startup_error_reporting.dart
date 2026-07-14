import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart' show kDebugMode;

import '../../features/settings/domain/entities/app_settings.dart';
import '../../injection.dart';
import '../error_reporting/breadcrumbs/breadcrumb_persistence.dart';
import '../error_reporting/breadcrumbs/breadcrumb_recorder.dart';
import '../error_reporting/breadcrumbs/focus_breadcrumber.dart';
import '../error_reporting/breadcrumbs/key_event_breadcrumber.dart';
import '../error_reporting/bus/telemetry_bus.dart';
import '../error_reporting/context/device_context_channel.dart';
import '../error_reporting/context/error_context_collector.dart';
import '../error_reporting/context/network_state_monitor.dart';
import '../error_reporting/context/route_tracker.dart';
import '../error_reporting/dio/breadcrumb_dio_interceptor.dart';
import '../error_reporting/domain/i_error_reporting_service.dart';
import '../error_reporting/error_record_builder.dart';
import '../error_reporting/error_record_sink.dart';
import '../error_reporting/error_reporting_service.dart';
import '../error_reporting/health/countdown_stall_detector.dart';
import '../error_reporting/health/flow_run_recorder.dart';
import '../error_reporting/health/functional_health_monitor.dart';
import '../error_reporting/health/health_state_store.dart';
import '../error_reporting/health/sequence_integrity_checker.dart';
import '../error_reporting/native/native_crash_bridge.dart';
import '../error_reporting/native/native_crash_record_builder.dart';
import '../error_reporting/policy/error_rate_limiter.dart';
import '../error_reporting/queue/error_queue_db_initializer.dart';
import '../error_reporting/queue/error_upload_flusher.dart';
import '../error_reporting/queue/sqflite_error_queue.dart';
import '../error_reporting/upload/firestore_error_uploader.dart';

/// Registers the error-observability pipeline (Layer 1). Runs right after
/// [initializeFirebase] and BEFORE diagnostics/analytics so both existing
/// sinks can tap the [TelemetryBus]. Fully fail-soft: the app must boot
/// even if this entire layer fails to come up.
Future<void> registerErrorReporting({
  required bool isTV,
  required AppSettings settings,
}) async {
  try {
    final bus = TelemetryBus();
    getIt.registerSingleton<TelemetryBus>(bus);

    final recorder = BreadcrumbRecorder()..attachTo(bus);
    getIt.registerSingleton<BreadcrumbRecorder>(recorder);

    final routeTracker = RouteTracker(recorder: recorder)..attachTo(bus);
    getIt.registerSingleton<RouteTracker>(routeTracker);

    // Global input observers — D-pad keys + focus traversal breadcrumbs.
    // App-lifetime: never detached outside tests.
    KeyEventBreadcrumber(recorder).attach();
    FocusBreadcrumber(recorder).attach();

    final networkMonitor = NetworkStateMonitor();
    final collector = ErrorContextCollector(
      routeTracker: routeTracker,
      deviceChannel: DeviceContextChannel(),
      networkMonitor: networkMonitor,
      isTV: isTV,
    );
    await collector.initialize();
    // Same keys the settings bridge pushes on every change (main.dart).
    collector.setSettingsContext({
      'selected_country': settings.selectedCountry,
      'selected_city': settings.selectedCity,
      'adhan_mode': settings.adhanMode.name,
      'iqama_mode': settings.iqamaMode.name,
      'is_mosque_mode': settings.isMosqueMode,
    });

    final db = await ErrorQueueDbInitializer().openOrCreate();
    final queue = SqfliteErrorQueue(db);
    final flusher = ErrorUploadFlusher(
      queue: queue,
      uploader: FirestoreErrorUploader(),
      networkMonitor: networkMonitor,
    );
    final sink = ErrorRecordSink(
      queue: queue,
      flusher: flusher,
      rateLimiter: ErrorRateLimiter(),
      bus: bus,
    );
    final service = ErrorReportingService(
      builder: ErrorRecordBuilder(collector: collector, breadcrumbs: recorder),
      nativeCrashBuilder: NativeCrashRecordBuilder(collector: collector),
      sink: sink,
      collector: collector,
    );
    await service.initialize();
    getIt.registerSingleton<IErrorReportingService>(service);

    // API breadcrumbs on the shared Dio. The four private per-repo Dio
    // instances are deliberately untouched (Safe-Change Protocol) — their
    // failures still reach the trail via the network_failure bus event.
    getIt<Dio>().interceptors.add(BreadcrumbDioInterceptor(recorder));

    flusher.start();

    // Breadcrumb persistence + native-crash recovery (both platforms — a JVM
    // crash matters on mobile too). Read the previous session's trail BEFORE
    // this session starts overwriting it, then file any marker the previous
    // session's native handler left behind.
    final persistence = BreadcrumbPersistence();
    final previousTrail = await persistence.loadPrevious();
    persistence.start(recorder);
    getIt.registerSingleton<BreadcrumbPersistence>(persistence);
    await NativeCrashBridge(service: service).consumeOnBoot(previousTrail);

    // Layer 3 — functional health. Same TV-first gate as the heartbeat:
    // always on TV, and on any debug build so it's verifiable on a phone.
    if (isTV || kDebugMode) {
      await _startFunctionalHealth(bus, service, collector);
    }
  } catch (_) {
    // Fail-soft: observability must never block app boot.
  }
}

Future<void> _startFunctionalHealth(
  TelemetryBus bus,
  IErrorReportingService service,
  ErrorContextCollector collector,
) async {
  final monitor = FunctionalHealthMonitor(
    reporter: service,
    sequenceChecker: SequenceIntegrityChecker(
      reporter: service,
      store: HealthStateStore(),
      sessionId: collector.sessionId,
      clock: DateTime.now,
    ),
    stallDetector: CountdownStallDetector(reporter: service),
    flowRunSink: FlowRunRecorder(
      appContextProvider: collector.appContext,
      settingsContextProvider: collector.settingsContext,
      clock: DateTime.now,
    ),
  );
  getIt.registerSingleton<FunctionalHealthMonitor>(monitor);
  await monitor.start(bus);
}
