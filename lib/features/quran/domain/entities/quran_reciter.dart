import 'quran_moshaf.dart';

/// Reciter model returned from mp3quran.net API.
class QuranApiReciter {
  final int id;
  final String nameAr;

  /// Default CDN server URL ending with '/', e.g.
  /// 'https://server8.mp3quran.net/maher/'. This is the recitation the app
  /// plays unless the user picks another طريقة — see [moshafs] and
  /// `QuranApiService.pickServerUrl` (prefers the plain Hafs murattal).
  /// Audio files are at: serverUrl + '001.mp3' … '114.mp3'
  final String serverUrl;

  /// Every complete (114-surah) recitation the reciter publishes, in API order.
  /// One entry for most reciters; several when the reciter offers multiple
  /// طرق (المرتّل/المجوّد/المعلّم) or riwayat. The user may pick any of these;
  /// [serverUrl] above is the default selection.
  final List<QuranMoshaf> moshafs;

  const QuranApiReciter({
    required this.id,
    required this.nameAr,
    required this.serverUrl,
    this.moshafs = const [],
  });

  /// True when the reciter offers more than one طريقة the user can choose from.
  bool get hasMultipleMoshafs => moshafs.length > 1;

  /// Whether [url] is this reciter's default or one of its طرق — used by the
  /// picker to highlight/auto-focus the reciter holding the active selection.
  bool containsServerUrl(String url) =>
      serverUrl == url || moshafs.any((m) => m.serverUrl == url);

  /// Full URL for a specific surah (1-based, zero-padded to 3 digits).
  String surahUrl(int surahNumber) {
    final padded = surahNumber.toString().padLeft(3, '0');
    return '$serverUrl$padded.mp3';
  }
}
