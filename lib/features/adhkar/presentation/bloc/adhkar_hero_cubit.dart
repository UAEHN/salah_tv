import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/adhkar_session.dart';
import '../../domain/entities/dhikr.dart';
import '../../domain/i_adhkar_audio_port.dart';
import '../../domain/i_adhkar_state_repository.dart';

/// Manages the TV adhkar hero audio playback and session lifecycle.
///
/// Separated from [AdhkarHeroContent] so the widget is display-only.
class AdhkarHeroCubit extends Cubit<AdhkarHeroState> {
  final IAdhkarAudioPort _audio;
  final IAdhkarStateRepository _repo;
  StreamSubscription<void>? _completeSub;
  Timer? _fallbackTimer;

  AdhkarHeroCubit(this._audio, this._repo)
      : super(const AdhkarHeroState(index: 0, adhkar: []));

  void start(AdhkarSession session) {
    final adhkar = _repo.forSession(session);
    if (adhkar.isEmpty) return;
    if (session == AdhkarSession.morning) {
      _repo.startMorningSession();
    } else if (session == AdhkarSession.evening) {
      _repo.startEveningSession();
    }
    _completeSub = _audio.onComplete.listen((_) => advance());
    emit(AdhkarHeroState(index: 0, adhkar: adhkar, session: session));
    _playOrTimer(adhkar, 0, isQuranPlaying: false);
  }

  void switchSession(AdhkarSession session) {
    _fallbackTimer?.cancel();
    _audio.stop();
    final adhkar = _repo.forSession(session);
    emit(AdhkarHeroState(index: 0, adhkar: adhkar, session: session));
    if (adhkar.isNotEmpty) _playOrTimer(adhkar, 0, isQuranPlaying: false);
  }

  void advance({bool isQuranPlaying = false}) {
    if (isClosed) return;
    final next = state.index + 1;
    if (next >= state.adhkar.length) {
      _fallbackTimer?.cancel();
      _endSession();
      emit(state.copyWith(isCompleted: true));
      return;
    }
    emit(state.copyWith(index: next));
    _playOrTimer(state.adhkar, next, isQuranPlaying: isQuranPlaying);
  }

  void _playOrTimer(
    List<Dhikr> adhkar,
    int index, {
    required bool isQuranPlaying,
  }) {
    _fallbackTimer?.cancel();
    if (adhkar.isEmpty) return;
    final url = adhkar[index].audioUrl;
    if (url != null && !isQuranPlaying) {
      _audio.play(url);
      _fallbackTimer = Timer(const Duration(minutes: 2), () => advance());
    } else {
      _fallbackTimer = Timer(const Duration(seconds: 20), () => advance());
    }
  }

  void _endSession() {
    final s = state.session;
    if (s == AdhkarSession.morning) {
      _repo.endMorningSession();
    } else if (s == AdhkarSession.evening) {
      _repo.endEveningSession();
    }
  }

  @override
  Future<void> close() {
    _fallbackTimer?.cancel();
    _completeSub?.cancel();
    _audio.stop();
    _endSession();
    return super.close();
  }
}

class AdhkarHeroState {
  final int index;
  final List<Dhikr> adhkar;
  final AdhkarSession? session;
  final bool isCompleted;

  const AdhkarHeroState({
    required this.index,
    required this.adhkar,
    this.session,
    this.isCompleted = false,
  });

  Dhikr? get currentDhikr =>
      adhkar.isNotEmpty && index < adhkar.length ? adhkar[index] : null;

  AdhkarHeroState copyWith({int? index, bool? isCompleted}) =>
      AdhkarHeroState(
        index: index ?? this.index,
        adhkar: adhkar,
        session: session,
        isCompleted: isCompleted ?? this.isCompleted,
      );
}
