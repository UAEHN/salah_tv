/// Domain descriptor for a Quranic / Arabic font available to the user.
/// Pure Dart — pointers to font family names that Flutter resolves through
/// `pubspec.yaml`. Entries are vetted at build-time; no runtime download.
class QuranFontInfo {
  /// Family name as registered in `pubspec.yaml` (also persisted in
  /// `AppSettings.fontFamily`). Examples: `'Cairo'`, `'Kufi'`, `'Beiruti'`.
  final String id;

  /// Localization key for the human-readable label
  /// (e.g. `'fontKufi'`).
  final String labelKey;

  /// Localization key for a short usage hint shown under the sample
  /// (e.g. `'fontHintQuranic'`). Optional — empty string means no hint.
  final String hintKey;

  const QuranFontInfo({
    required this.id,
    required this.labelKey,
    this.hintKey = '',
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is QuranFontInfo &&
          other.id == id &&
          other.labelKey == labelKey &&
          other.hintKey == hintKey;

  @override
  int get hashCode => Object.hash(id, labelKey, hintKey);
}
