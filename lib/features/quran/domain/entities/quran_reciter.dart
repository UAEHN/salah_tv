/// Reciter model returned from mp3quran.net API.
class QuranApiReciter {
  final int id;
  final String nameAr;

  /// CDN server URL ending with '/', e.g. 'https://server8.mp3quran.net/maher/'
  /// Audio files are at: serverUrl + '001.mp3' … '114.mp3'
  final String serverUrl;

  const QuranApiReciter({
    required this.id,
    required this.nameAr,
    required this.serverUrl,
  });

  /// Full URL for a specific surah (1-based, zero-padded to 3 digits).
  String surahUrl(int surahNumber) {
    final padded = surahNumber.toString().padLeft(3, '0');
    return '$serverUrl$padded.mp3';
  }
}
