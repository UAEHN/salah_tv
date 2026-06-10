String normalizeLocationText(String value) {
  return value
      .trim()
      .toLowerCase()
      .replaceAll('&', ' and ')
      .replaceAll(RegExp(r"[^a-z0-9؀-ۿ]+"), ' ')
      .replaceAll(RegExp(r'\s+'), ' ')
      .trim();
}

/// Stricter form used to match Arabic city names across spelling variants
/// (e.g. "خور فكان" with a space vs "خورفكان" as one word, "القاهرة" with
/// tah marbuta vs "القاهره"). Strips ALL whitespace inside the value,
/// removes Arabic diacritics, folds hamza/alef/tah-marbuta variants — so
/// any of those forms collapses to a single canonical key.
String normalizeLocationTextStrict(String value) {
  return value
      .trim()
      .toLowerCase()
      .replaceAll(RegExp('[ً-ٰٟ]'), '') // Arabic diacritics
      .replaceAll(RegExp('[إأآٱ]'), 'ا') // hamzated alef → ا
      .replaceAll('ى', 'ي') // alef maksura → ي
      .replaceAll('ة', 'ه') // tah marbuta → ه
      .replaceAll(
        RegExp(r"[^a-z0-9؀-ۿ]+"),
        '',
      ) // strip everything else incl. spaces
      .trim();
}
