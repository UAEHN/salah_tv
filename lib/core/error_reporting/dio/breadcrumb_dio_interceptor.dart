import 'package:dio/dio.dart';

import '../breadcrumbs/breadcrumb_recorder.dart';
import '../domain/breadcrumb.dart';

/// Records one `api` breadcrumb per completed request (outcome + latency).
/// Only outcomes are recorded — a request+response pair would burn two of
/// the 20 trail slots per call for no extra signal. Query strings are
/// stripped (they can carry keys/tokens).
class BreadcrumbDioInterceptor extends Interceptor {
  BreadcrumbDioInterceptor(this._recorder);

  final BreadcrumbRecorder _recorder;
  static const _startedAtKey = 'error_reporting.started_at';

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    try {
      options.extra[_startedAtKey] = DateTime.now().millisecondsSinceEpoch;
    } catch (_) {}
    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    try {
      final options = response.requestOptions;
      _recorder.add(
        Breadcrumb(
          at: DateTime.now(),
          type: BreadcrumbType.api,
          name:
              '${options.method} ${_slimUrl(options.uri)} '
              '→ ${response.statusCode ?? '?'}${_latencySuffix(options)}',
        ),
      );
    } catch (_) {}
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    try {
      final options = err.requestOptions;
      _recorder.add(
        Breadcrumb(
          at: DateTime.now(),
          type: BreadcrumbType.api,
          name:
              '${options.method} ${_slimUrl(options.uri)} '
              '→ ${err.type.name}${_latencySuffix(options)}',
        ),
      );
    } catch (_) {}
    handler.next(err);
  }

  static String _slimUrl(Uri uri) => '${uri.host}${uri.path}';

  static String _latencySuffix(RequestOptions options) {
    final startedAt = options.extra[_startedAtKey] as int?;
    if (startedAt == null) return '';
    final ms = DateTime.now().millisecondsSinceEpoch - startedAt;
    return ' (${ms}ms)';
  }
}
