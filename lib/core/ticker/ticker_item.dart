/// A single ticker entry shown on the TV home ticker bar.
///
/// [text] is the sacred-text body (Qur'an verse, hadith or dhikr) shown
/// verbatim in Arabic; [source] is its attribution (sura + ayah, or takhrij).
library;

class TickerItem {
  final String text;
  final String source;

  const TickerItem({required this.text, required this.source});
}
