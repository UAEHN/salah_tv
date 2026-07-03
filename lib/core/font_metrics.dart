/// Per-font visual-size compensation.
///
/// Cairo and Beiruti render noticeably smaller than Kufi (Noto Kufi Arabic) and
/// Rubik at the same point size — fine on a phone held close, but too small for
/// across-the-room TV reading. These factors scale those fonts up so every
/// option reads at a comparable size on TV. `1.0` = no change (the default for
/// any font not listed). Tune the values here to taste — one source of truth.
const Map<String, double> kTvFontSizeScale = {'Cairo': 1.18, 'Beiruti': 1.18};

/// The TV size-compensation factor for [fontFamily]; `1.0` when none applies.
double tvFontSizeScaleFor(String fontFamily) =>
    kTvFontSizeScale[fontFamily] ?? 1.0;
