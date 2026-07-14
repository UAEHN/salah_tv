import '../../injection.dart';
import 'classify/error_categorizer.dart';
import 'domain/error_severity.dart';
import 'domain/i_error_reporting_service.dart';

/// The single call main.dart's four global hooks (zone, FlutterError,
/// PlatformDispatcher, isolate) make into the error-reporting pipeline.
/// Safe before DI is ready and can never throw back into a crash handler.
void reportUncaught(
  String name,
  Object error,
  StackTrace stack, {
  bool isFatal = true,
  bool isLayout = false,
}) {
  try {
    if (!getIt.isRegistered<IErrorReportingService>()) return;
    getIt<IErrorReportingService>().reportError(
      name: name,
      error: error,
      stack: stack,
      severity: isLayout
          ? ErrorSeverity.warning
          : (isFatal ? ErrorSeverity.fatal : ErrorSeverity.error),
      categoryOverride: isLayout ? ErrorCategories.uiRendering : null,
    );
  } catch (_) {}
}
