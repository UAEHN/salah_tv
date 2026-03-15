import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../settings/domain/entities/app_settings.dart';
import '../../domain/i_prayer_audio_port.dart';
import '../../domain/i_prayer_times_repository.dart';
import '../../domain/prayer_cycle_engine.dart';
import 'prayer_event.dart';
import 'prayer_state.dart';

/// BLoC that wraps [PrayerCycleEngine] and exposes its state as [PrayerState].
/// Implements [WidgetsBindingObserver] to forward app-lifecycle events to the engine.
class PrayerBloc extends Bloc<PrayerEvent, PrayerState>
    with WidgetsBindingObserver {
  final IPrayerTimesRepository _repo;
  late final PrayerCycleEngine _engine;

  PrayerBloc(
    IPrayerTimesRepository repo,
    IPrayerAudioPort audio,
    AppSettings initialSettings,
  ) : _repo = repo,
      super(PrayerState.initial()) {
    _engine = PrayerCycleEngine(repo, audio, initialSettings, _onEngineChanged);
    on<PrayerEngineRefreshed>(_onRefreshed);
    on<PrayerStarted>(_onStarted);
    on<PrayerResumed>(_onResumed);
    on<PrayerSettingsUpdated>(_onSettingsUpdated);
    on<PrayerAdhanStopped>(_onAdhanStopped);
    on<PrayerDuaStopped>(_onDuaStopped);
    on<PrayerIqamaStopped>(_onIqamaStopped);
    on<PrayerQuranToggled>(_onQuranToggled);
    on<PrayerMakkahStreamAudioChanged>(_onMakkahAudio);
    on<PrayerReloaded>(_onReloaded);
    WidgetsBinding.instance.addObserver(this);
  }

  void _onEngineChanged() {
    if (!isClosed) add(const PrayerEngineRefreshed());
  }

  void _onRefreshed(PrayerEngineRefreshed _, Emitter<PrayerState> emit) =>
      emit(PrayerState.fromEngine(_engine));

  void _onStarted(PrayerStarted _, Emitter<PrayerState> emit) {
    _engine.start();
    emit(PrayerState.fromEngine(_engine));
  }

  void _onResumed(PrayerResumed _, Emitter<PrayerState> emit) {
    _engine.onResumed();
    emit(PrayerState.fromEngine(_engine));
  }

  Future<void> _onSettingsUpdated(
    PrayerSettingsUpdated event,
    Emitter<PrayerState> emit,
  ) async {
    final prev = _engine.settings;
    final next = event.settings;
    if (next.selectedCountry != prev.selectedCountry) {
      await _repo.loadCountry(next.selectedCountry);
    }
    await _engine.updateSettings(next);
    emit(PrayerState.fromEngine(_engine));
  }

  Future<void> _onAdhanStopped(
    PrayerAdhanStopped _,
    Emitter<PrayerState> emit,
  ) async {
    await _engine.stopAdhan();
    emit(PrayerState.fromEngine(_engine));
  }

  Future<void> _onDuaStopped(
    PrayerDuaStopped _,
    Emitter<PrayerState> emit,
  ) async {
    await _engine.stopDua();
    emit(PrayerState.fromEngine(_engine));
  }

  Future<void> _onIqamaStopped(
    PrayerIqamaStopped _,
    Emitter<PrayerState> emit,
  ) async {
    await _engine.stopIqama();
    emit(PrayerState.fromEngine(_engine));
  }

  void _onQuranToggled(PrayerQuranToggled event, Emitter<PrayerState> emit) {
    _engine.toggleQuran(event.serverUrl);
    emit(PrayerState.fromEngine(_engine));
  }

  void _onMakkahAudio(
    PrayerMakkahStreamAudioChanged event,
    Emitter<PrayerState> emit,
  ) {
    _engine.setMakkahStreamAudioActive(event.isActive);
    emit(PrayerState.fromEngine(_engine));
  }

  void _onReloaded(PrayerReloaded _, Emitter<PrayerState> emit) {
    _engine.reload();
    emit(PrayerState.fromEngine(_engine));
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) add(const PrayerResumed());
  }

  @override
  Future<void> close() async {
    WidgetsBinding.instance.removeObserver(this);
    _engine.dispose();
    return super.close();
  }
}
