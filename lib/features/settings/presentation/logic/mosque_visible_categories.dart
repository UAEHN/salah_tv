/// Pure selection rule: which settings categories are visible in the
/// settings rail given the current mosque-mode flag.
///
/// Indices are canonical category ids (not display order) used by
/// [SettingsContentPanel]'s IndexedStack and the nav focus nodes:
///   0 Location, 1 Quran, 2 Adhan, 3 Adhan Offsets, 4 Iqama,
///   5 Mosque, 6 Appearance, 7 Adhkar, 8 Feedback, 9 Features.
///
/// Mosque mode hides categories with no behavioural effect once the muezzin
/// handles audio live: Quran (1), Adhan sounds (2), and Adhkar (7) — whose only
/// content (morning/evening adhkar) is itself mosque-hidden. The Features (9)
/// category stays visible because it hosts the verses-banner toggle; its
/// screensaver option is hidden inside the panel instead.
const int kSettingsCategoryCount = 10;

const List<int> _kHiddenInMosqueMode = [1, 2, 7];

List<int> visibleSettingsCategoryIndices({required bool isMosqueMode}) {
  if (!isMosqueMode) {
    return List<int>.unmodifiable(
      List<int>.generate(kSettingsCategoryCount, (i) => i),
    );
  }
  return List<int>.unmodifiable([
    for (int i = 0; i < kSettingsCategoryCount; i++)
      if (!_kHiddenInMosqueMode.contains(i)) i,
  ]);
}

/// Returns [requested] if it is still visible, otherwise the first visible
/// index. Used to keep the rail focus on a valid card when mosque mode
/// hides the previously selected category.
int resolveVisibleIndex(int requested, List<int> visible) {
  return visible.contains(requested) ? requested : visible.first;
}
