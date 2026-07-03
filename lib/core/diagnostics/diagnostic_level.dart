enum DiagnosticLevel {
  debug,
  info,
  warning,
  error,
  fatal;

  String get wireName => name.toUpperCase();

  bool get shouldUpload =>
      this == DiagnosticLevel.warning ||
      this == DiagnosticLevel.error ||
      this == DiagnosticLevel.fatal;
}
