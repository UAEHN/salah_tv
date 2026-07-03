/// A single recitation "way" (مصحف/طريقة) published by a reciter on
/// mp3quran.net — e.g. «حفص عن عاصم - مرتل», «المصحف المجوّد», «المصحف المعلّم»,
/// or a different riwaya (ورش/قالون). One reciter may publish several complete
/// (114-surah) moshafs; each maps to its own CDN [serverUrl].
class QuranMoshaf {
  /// Display name as returned by the API (e.g. «حفص عن عاصم - مرتل»).
  final String name;

  /// CDN server URL ending with '/', e.g. 'https://server8.mp3quran.net/maher/'
  /// Audio files are at: serverUrl + '001.mp3' … '114.mp3'.
  final String serverUrl;

  const QuranMoshaf({required this.name, required this.serverUrl});
}
