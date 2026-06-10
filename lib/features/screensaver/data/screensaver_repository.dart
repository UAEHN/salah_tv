import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import '../../../core/ticker_content.dart';
import '../domain/i_screensaver_repository.dart';

/// Builds the screensaver rotation from the bundled content asset (أسماء الله
/// الحسنى + extra verses & du'as) merged with the curated [kTickerItems].
/// Loaded once at startup via [initialize]; [getSlides] then returns the cached
/// list synchronously. Falls back to [kTickerItems] if the asset fails to load.
class ScreensaverRepository implements IScreensaverRepository {
  List<TickerItem> _slides = kTickerItems;

  Future<void> initialize() async {
    try {
      final raw = await rootBundle.loadString(
        'assets/screensaver/screensaver_content.json',
      );
      final data = jsonDecode(raw) as Map<String, dynamic>;
      final asma = (data['asma'] as List).cast<Map<String, dynamic>>().map(
        (e) => TickerItem(
          text: e['name'] as String,
          source: e['meaning'] as String,
        ),
      );
      final extra = (data['extra'] as List).cast<Map<String, dynamic>>().map(
        (e) => TickerItem(
          text: e['text'] as String,
          source: e['source'] as String,
        ),
      );
      _slides = List.unmodifiable([...asma, ...extra, ...kTickerItems]);
      debugPrint('[ScreensaverRepo] loaded ${_slides.length} slides');
    } catch (e) {
      debugPrint('[ScreensaverRepo] load failed: $e');
      _slides = kTickerItems;
    }
  }

  @override
  List<TickerItem> getSlides() => _slides;
}
