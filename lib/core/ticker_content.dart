/// Public aggregator for the home ticker bar content (TV mosque-display style).
///
/// These are sacred-text items (Qur'an verses, hadith, adhkar) shown verbatim
/// in Arabic — they are *content data*, not translatable UI chrome, so they
/// intentionally live as constants rather than in `l10n/*.arb` (mirrors the
/// bundled adhkar text). Split by category into the `ticker/` files to keep
/// each file under the 150-line cap (§4).
///
/// Eviction rule: fixed, bounded const lists — no runtime growth.
library;

import 'ticker/ticker_adhkar.dart';
import 'ticker/ticker_ayat.dart';
import 'ticker/ticker_hadith.dart';
import 'ticker/ticker_item.dart';

export 'ticker/ticker_item.dart';

/// Curated rotation of verses, hadith and adhkar centered on prayer & dhikr.
/// Order: ayat → hadith → adhkar, cycled one-by-one by [HomeTickerBar].
const List<TickerItem> kTickerItems = [
  ...kTickerAyat,
  ...kTickerHadith,
  ...kTickerAdhkar,
];
