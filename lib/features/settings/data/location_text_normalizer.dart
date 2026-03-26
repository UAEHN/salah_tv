String normalizeLocationText(String value) {
  return value
      .trim()
      .toLowerCase()
      .replaceAll('&', ' and ')
      .replaceAll(RegExp(r"[^a-z0-9\u0600-\u06FF]+"), ' ')
      .replaceAll(RegExp(r'\s+'), ' ')
      .trim();
}
