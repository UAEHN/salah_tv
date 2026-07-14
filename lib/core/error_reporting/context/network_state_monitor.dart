import 'package:connectivity_plus/connectivity_plus.dart';

/// Wraps connectivity_plus for the two things error reporting needs:
/// the network snapshot stored on each record, and the "back online"
/// signal that flushes the offline queue.
class NetworkStateMonitor {
  NetworkStateMonitor({Connectivity? connectivity})
    : _connectivity = connectivity ?? Connectivity();

  final Connectivity _connectivity;
  static const Duration _timeout = Duration(seconds: 2);

  /// `{connected: bool, type: 'wifi'|'ethernet'|'mobile'|'none'|'unknown'}`.
  /// On failure assumes connected so uploads still get attempted — a wrong
  /// "offline" would silently strand the queue.
  Future<Map<String, Object?>> snapshot() async {
    try {
      final results = await _connectivity.checkConnectivity().timeout(_timeout);
      final type = _primaryType(results);
      return {'connected': type != 'none', 'type': type};
    } catch (_) {
      return const {'connected': true, 'type': 'unknown'};
    }
  }

  /// Emits whenever connectivity comes back (any non-none transport).
  Stream<bool> get onOnline => _connectivity.onConnectivityChanged
      .map((results) => results.any((r) => r != ConnectivityResult.none))
      .where((isOnline) => isOnline);

  static String _primaryType(List<ConnectivityResult> results) {
    if (results.contains(ConnectivityResult.ethernet)) return 'ethernet';
    if (results.contains(ConnectivityResult.wifi)) return 'wifi';
    if (results.contains(ConnectivityResult.mobile)) return 'mobile';
    if (results.isEmpty || results.every((r) => r == ConnectivityResult.none)) {
      return 'none';
    }
    return 'unknown';
  }
}
