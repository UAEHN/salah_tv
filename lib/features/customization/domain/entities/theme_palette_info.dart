/// Domain-layer descriptor for a selectable theme palette in the mobile
/// build. Pure Dart — no Flutter imports — so it stays inside the domain
/// boundary. The presentation layer maps [primaryArgb]/[secondaryArgb] to
/// `Color` objects for rendering.
class ThemePaletteInfo {
  /// Stable identifier persisted in `AppSettings.themeColorKey`.
  final String id;

  /// Localization key for the human-readable label. The presentation layer
  /// resolves it against `AppLocalizations` (e.g. `'themeGreen'`).
  final String labelKey;

  /// 0xAARRGGBB ARGB int for the primary accent.
  final int primaryArgb;

  /// 0xAARRGGBB ARGB int for the secondary accent.
  final int secondaryArgb;

  /// True for the original five palettes shared with the TV build. Used to
  /// group/sort the picker (legacy first, then Islamic palettes).
  final bool isLegacy;

  const ThemePaletteInfo({
    required this.id,
    required this.labelKey,
    required this.primaryArgb,
    required this.secondaryArgb,
    required this.isLegacy,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ThemePaletteInfo &&
          other.id == id &&
          other.primaryArgb == primaryArgb &&
          other.secondaryArgb == secondaryArgb &&
          other.isLegacy == isLegacy;

  @override
  int get hashCode =>
      Object.hash(id, primaryArgb, secondaryArgb, isLegacy);
}
