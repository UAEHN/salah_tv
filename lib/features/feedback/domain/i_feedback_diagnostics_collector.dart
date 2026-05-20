/// Collects device-level diagnostic data (independent of app settings).
/// Implementation lives in `data/` and may use platform/package plugins.
abstract class IFeedbackDiagnosticsCollector {
  Future<Map<String, String>> collect();
}
