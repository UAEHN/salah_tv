import '../../../../core/error/failures.dart';
import '../../domain/entities/remote_city_result.dart';
import '../../domain/remote_search_cancel_token.dart';
import '../../domain/usecases/search_remote_cities_usecase.dart';

/// Mutable state holder driving the remote-search portion of the mobile
/// location dialog. Owns the in-flight cancel token and silently absorbs
/// network/cancel failures so the user never sees an error toast for a
/// keystroke that just happened to time out.
class RemoteCitySearchController {
  final SearchRemoteCitiesUseCase _useCase;

  RemoteCitySearchController(this._useCase);

  RemoteSearchCancelToken? _activeToken;
  String _latestQuery = '';
  List<RemoteCityResult> _results = const [];
  bool _loading = false;

  List<RemoteCityResult> get results => _results;
  bool get loading => _loading;
  String get latestQuery => _latestQuery;

  void Function()? onChanged;

  void _emit() => onChanged?.call();

  Future<void> search(String query) async {
    _activeToken?.cancel();
    final token = RemoteSearchCancelToken();
    _activeToken = token;
    _latestQuery = query;

    if (query.trim().length < 2) {
      _results = const [];
      _loading = false;
      _emit();
      return;
    }

    _loading = true;
    _emit();

    final outcome = await _useCase(query, cancelToken: token);
    // A newer search may have replaced us mid-flight. Drop the stale result.
    if (token.isCancelled || token != _activeToken) return;

    outcome.fold(
      (failure) {
        if (failure is CancelledFailure) return;
        // Network/server failures are silent — UI degrades to local-only.
        _results = const [];
        _loading = false;
        _emit();
      },
      (results) {
        _results = results;
        _loading = false;
        _emit();
      },
    );
  }

  void dispose() {
    _activeToken?.cancel();
    onChanged = null;
  }
}
