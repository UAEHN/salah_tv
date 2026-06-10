import '../../../core/ticker_content.dart';

/// Read-only source of the ambient screensaver rotation (verses, hadith,
/// adhkar). Slides are sacred-text [TickerItem]s — content data, not UI chrome.
abstract class IScreensaverRepository {
  /// The ordered list of slides cycled by the screensaver.
  List<TickerItem> getSlides();
}
