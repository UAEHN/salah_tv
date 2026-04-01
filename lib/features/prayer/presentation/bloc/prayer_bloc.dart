import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../settings/domain/entities/app_settings.dart';
import '../../domain/i_prayer_audio_port.dart';
import '../../../notifications/domain/i_prayer_notification_port.dart';
import '../../domain/i_prayer_times_repository.dart';
import '../../domain/prayer_cycle_engine.dart';
import 'prayer_displayed_date_controller.dart';
import 'prayer_event.dart';
import 'prayer_settings_sync.dart';
import 'prayer_state.dart';

class PrayerBloc extends Bloc<PrayerEvent, PrayerState>
    with WidgetsBindingObserver {
  late final PrayerCycleEngine _engine;
  late final PrayerDisplayedDateController _dateController;

  PrayerBloc(
    IPrayerTimesRepository repo,
    IPrayerAudioPort audio,
    AppSettings initialSettings, {
    IPrayerNotificationPort? notifications,
  }) : super(PrayerState.initial()) {
    _dateController = PrayerDisplayedDateController.fromRepository(repo);
    _engine = PrayerCycleEngine(
      repo,
      audio,
      initialSettings,
      _onEngineChanged,
      notifications: notifications,
    );
    on<PrayerEngineRefreshed>(_onRefreshed);
    on<PrayerStarted>(_onStarted);
    on<PrayerResumed>(_onResumed);
    on<PrayerPaused>(_onPaused);
    on<PrayerSettingsUpdated>(_onSettingsUpdated);
    on<PrayerAdhanStopped>(_onAdhanStopped);
    on<PrayerDuaStopped>(_onDuaStopped);
    on<PrayerIqamaStopped>(_onIqamaStopped);
    on<PrayerQuranToggled>(_onQuranToggled);
    on<PrayerReloaded>(_onReloaded);
    on<PrayerDateChanged>(_onDateChanged);
    on<PrayerDateReset>(_onDateReset);
    WidgetsBinding.instance.addObserver(this);
  }

  void _onEngineChanged() {
    if (!isClosed) add(const PrayerEngineRefreshed());
  }

  void _emitCurrent(Emitter<PrayerState> emit) {
    _dateController.resetIfViewingToday(_engine.now);
    emit(_dateController.buildState(_engine));
  }

  void _onRefreshed(PrayerEngineRefreshed _, Emitter<PrayerState> emit) =>
      _emitCurrent(emit);

  void _onStarted(PrayerStarted _, Emitter<PrayerState> emit) =>
      _runSync(_engine.start, emit);

  void _onPaused(PrayerPaused _, Emitter<PrayerState> emit) =>
      _runSync(_engine.onPaused, emit);

  void _onResumed(PrayerResumed _, Emitter<PrayerState> emit) =>
      _runSync(_engine.onResumed, emit);

  void _runSync(void Function() action, Emitter<PrayerState> emit) {
    action();
    _emitCurrent(emit);
  }

  Future<void> _onSettingsUpdated(
    PrayerSettingsUpdated event,
    Emitter<PrayerState> emit,
  ) async {
    final prev = _engine.settings;
    final next = event.settings;
    await syncPrayerRepositoryMode(_engine.repo, prev, next);
    await _engine.updateSettings(next);
    if (_dateController.shouldRefreshSelectedDate(prev, next)) {
      await _dateController.refreshSelectedDate();
    }
    _emitCurrent(emit);
  }

  Future<void> _onAdhanStopped(
    PrayerAdhanStopped _,
    Emitter<PrayerState> emit,
  ) => _runAsync(_engine.stopAdhan, emit);

  Future<void> _onDuaStopped(PrayerDuaStopped _, Emitter<PrayerState> emit) =>
      _runAsync(_engine.stopDua, emit);

  Future<void> _onIqamaStopped(
    PrayerIqamaStopped _,
    Emitter<PrayerState> emit,
  ) => _runAsync(_engine.stopIqama, emit);

  Future<void> _runAsync(
    Future<void> Function() action,
    Emitter<PrayerState> emit,
  ) async {
    await action();
    _emitCurrent(emit);
  }

  void _onQuranToggled(PrayerQuranToggled event, Emitter<PrayerState> emit) =>
      _runSync(() => _engine.toggleQuran(event.serverUrl), emit);

  Future<void> _onReloaded(PrayerReloaded _, Emitter<PrayerState> emit) async {
    _engine.reload();
    await _dateController.refreshSelectedDate();
    _emitCurrent(emit);
  }

  Future<void> _onDateChanged(
    PrayerDateChanged event,
    Emitter<PrayerState> emit,
  ) async {
    if (_dateController.isBusy) return;
    final changeFuture = _dateController.changeDate(
      _engine.now,
      event.dayOffset,
    );
    _emitCurrent(emit);
    await changeFuture;
    _emitCurrent(emit);
  }

  void _onDateReset(PrayerDateReset _, Emitter<PrayerState> emit) =>
      _runSync(_dateController.clear, emit);

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) add(const PrayerResumed());
    if (state == AppLifecycleState.paused) add(const PrayerPaused());
    if (state == AppLifecycleState.detached) add(const PrayerPaused());
  }

  @override
  Future<void> close() async {
    WidgetsBinding.instance.removeObserver(this);
    _engine.dispose();
    return super.close();
  }
}
