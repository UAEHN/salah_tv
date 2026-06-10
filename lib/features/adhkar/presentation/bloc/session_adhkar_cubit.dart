import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/dhikr.dart';
import '../../domain/i_adhkar_audio_port.dart';

/// Drives the TV morning/evening session-adhkar takeover: plays each dhikr's
/// audio and advances when it finishes (with a fallback timer so a missing or
/// failed file never stalls the list). Emits [isCompleted] once the whole list
/// has played one pass — the screen relays that so the prayer engine resumes
/// Quran. Owns audio only; the engine decides when the takeover appears.
class SessionAdhkarCubit extends Cubit<SessionAdhkarState> {
  final IAdhkarAudioPort _audio;
  StreamSubscription<void>? _completeSub; // cancelled in close()
  Timer? _fallbackTimer; // cancelled in close()

  SessionAdhkarCubit(this._audio)
    : super(const SessionAdhkarState(index: 0, adhkar: []));

  void start(List<Dhikr> adhkar) {
    if (adhkar.isEmpty) {
      emit(const SessionAdhkarState(index: 0, adhkar: [], isCompleted: true));
      return;
    }
    _completeSub = _audio.onComplete.listen((_) => advance());
    emit(SessionAdhkarState(index: 0, adhkar: adhkar));
    _playOrTimer(0);
  }

  void advance() {
    if (isClosed) return;
    final next = state.index + 1;
    if (next >= state.adhkar.length) {
      _fallbackTimer?.cancel();
      emit(state.copyWith(isCompleted: true));
      return;
    }
    emit(state.copyWith(index: next));
    _playOrTimer(next);
  }

  void _playOrTimer(int index) {
    _fallbackTimer?.cancel();
    final url = state.adhkar[index].audioUrl;
    if (url != null && url.isNotEmpty) {
      _audio.play(url);
      // Safety net if onComplete never fires (decode error / unsupported file).
      _fallbackTimer = Timer(const Duration(minutes: 2), advance);
    } else {
      // No audio for this dhikr — dwell briefly, then move on.
      _fallbackTimer = Timer(const Duration(seconds: 20), advance);
    }
  }

  @override
  Future<void> close() {
    _fallbackTimer?.cancel();
    _completeSub?.cancel();
    _audio.stop();
    return super.close();
  }
}

class SessionAdhkarState {
  final int index;
  final List<Dhikr> adhkar;
  final bool isCompleted;

  const SessionAdhkarState({
    required this.index,
    required this.adhkar,
    this.isCompleted = false,
  });

  Dhikr? get current =>
      adhkar.isNotEmpty && index < adhkar.length ? adhkar[index] : null;

  SessionAdhkarState copyWith({int? index, bool? isCompleted}) =>
      SessionAdhkarState(
        index: index ?? this.index,
        adhkar: adhkar,
        isCompleted: isCompleted ?? this.isCompleted,
      );
}
