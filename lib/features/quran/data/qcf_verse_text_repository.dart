import 'generated/qcf_verse_text.g.dart';

/// Lazy map from `'surah:verse'` to the verse's QCF v2 BSML codepoint
/// string (PUA characters). The underlying data is a 6236-entry list;
/// indexing it as a map turns lookups from `O(N)` to `O(1)` and lets
/// every page render stay free of accidental quadratic costs.
class QcfVerseTextRepository {
  static Map<String, String>? _cache;

  static Map<String, String> _build() {
    final m = <String, String>{};
    for (final e in kQcfVerseText) {
      final entry = e as Map;
      m['${entry['surah_number']}:${entry['verse_number']}'] =
          entry['qcfData'] as String;
    }
    return m;
  }

  /// Returns the QCF v2 BSML PUA string for [surah]:[verse], stripped
  /// of inter-word spaces so the page font flows them as one run — the
  /// same shape Skoon's `getVerseQCF(...).replaceAll(' ', '')` produces.
  static String getVerseQcf(int surah, int verse) {
    final map = _cache ??= _build();
    final raw = map['$surah:$verse'] ?? '';
    return raw.replaceAll(' ', '');
  }
}
