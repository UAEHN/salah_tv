/// Convert a Latin-digit integer to Arabic-Indic digits — used for the
/// end-of-ayah marker and page/juz labels in the Mushaf reader.
String toArabicIndic(int n) {
  const digits = ['٠', '١', '٢', '٣', '٤', '٥', '٦', '٧', '٨', '٩'];
  if (n < 0) return n.toString();
  if (n == 0) return digits[0];
  final buf = StringBuffer();
  for (final ch in n.toString().split('')) {
    final d = int.tryParse(ch);
    buf.write(d == null ? ch : digits[d]);
  }
  return buf.toString();
}
