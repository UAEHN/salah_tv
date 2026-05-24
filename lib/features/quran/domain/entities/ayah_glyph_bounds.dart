/// One word-shape bounding box on a Mushaf page, in image-pixel
/// coordinates relative to the 1024×1656 page PNG. Comes straight
/// from the quran_android `ayahinfo_1024.db` `glyphs` table.
class AyahGlyphBounds {
  final int sura;
  final int ayah;
  final int line;
  final int minX;
  final int maxX;
  final int minY;
  final int maxY;

  const AyahGlyphBounds({
    required this.sura,
    required this.ayah,
    required this.line,
    required this.minX,
    required this.maxX,
    required this.minY,
    required this.maxY,
  });

  bool contains(int x, int y) =>
      x >= minX && x <= maxX && y >= minY && y <= maxY;
}
