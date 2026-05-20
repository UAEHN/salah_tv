// Verse Scene — phase timing (single source of truth)
// Total duration ≈ 7s (set in scenes.js)

export const T = {
  // Backdrop + atmosphere
  spotlightStart: 0.0,
  particlesStart: 0.2,

  // Top header
  ornamentTop:    0.35,
  chipStart:      0.7,

  // Verse — word-by-word reveal (rhythmic, like recitation)
  w1: 1.10,   // أَقِمِ
  w2: 1.40,   // الصَّلَاةَ
  w3: 1.75,   // لِدُلُوكِ
  w4: 2.05,   // الشَّمْسِ
  w5: 2.40,   // إِلَىٰ

  // KEY moment — "غَسَقِ" climax (held breath before, dramatic bloom)
  keyWordStart:   2.95,
  keyBurstStart:  2.95,

  // Tail
  w7:             3.85,   // اللَّيْلِ

  // Footer
  ornamentBottom: 4.45,
  surahName:      4.7,
  tagline:        5.2,
};
