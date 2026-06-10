import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/online_geocoding_result.dart';
import '../../domain/i_online_geocoding_repository.dart';

enum OnlineGeocodingStatus { idle, loading, results, empty, error }

class OnlineGeocodingState {
  final OnlineGeocodingStatus status;
  final List<OnlineGeocodingResult> results;
  final String? error;
  final String query;

  const OnlineGeocodingState({
    this.status = OnlineGeocodingStatus.idle,
    this.results = const [],
    this.error,
    this.query = '',
  });

  static const idle = OnlineGeocodingState();

  OnlineGeocodingState copyWith({
    OnlineGeocodingStatus? status,
    List<OnlineGeocodingResult>? results,
    String? error,
    String? query,
  }) {
    return OnlineGeocodingState(
      status: status ?? this.status,
      results: results ?? this.results,
      error: error,
      query: query ?? this.query,
    );
  }
}

/// Debounced search against [IOnlineGeocodingRepository] (Nominatim).
/// Empties on short queries; respects Nominatim's 1 req/sec policy via
/// a 500ms debounce on input.
class OnlineGeocodingCubit extends Cubit<OnlineGeocodingState> {
  OnlineGeocodingCubit(this._repo) : super(OnlineGeocodingState.idle);

  final IOnlineGeocodingRepository _repo;
  Timer? _debounce;
  int _requestSeq = 0;

  void searchDebounced(String query, {String? countryCode}) {
    _debounce?.cancel();
    final trimmed = query.trim();
    if (trimmed.length < 2) {
      emit(OnlineGeocodingState.idle.copyWith(query: trimmed));
      return;
    }
    emit(state.copyWith(status: OnlineGeocodingStatus.loading, query: trimmed));
    _debounce = Timer(const Duration(milliseconds: 500), () {
      _runSearch(trimmed, countryCode: countryCode);
    });
  }

  Future<void> _runSearch(String query, {String? countryCode}) async {
    final seq = ++_requestSeq;
    final result = await _repo.search(query, countryCode: countryCode);
    if (isClosed || seq != _requestSeq) return;
    result.fold(
      (failure) => emit(
        state.copyWith(
          status: OnlineGeocodingStatus.error,
          error: failure.message,
        ),
      ),
      (results) => emit(
        state.copyWith(
          status: results.isEmpty
              ? OnlineGeocodingStatus.empty
              : OnlineGeocodingStatus.results,
          results: results,
        ),
      ),
    );
  }

  void clear() {
    _debounce?.cancel();
    _requestSeq++;
    emit(OnlineGeocodingState.idle);
  }

  @override
  Future<void> close() {
    _debounce?.cancel();
    return super.close();
  }
}
