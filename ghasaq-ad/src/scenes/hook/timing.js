// ========================================================
// Hook Scene - Phase Timing (single source of truth)
// ========================================================
// All times in seconds. Edit here -> updates everywhere.
//
// Concept: a tight ~6s cinematic hook built around ONE
// metaphor — sun and moon arcing toward the same point,
// meeting at center, and birthing the brand name.
// "غسق" literally means the moment day meets night
// (i.e. Maghrib time) — so the meeting IS the brand.

export const T = {
  // PHASE 1 — Ambient (subtle starfield + horizon glow fade in)
  ambientStart:   0.0,

  // PHASE 2 — Celestial approach (sun + moon arc toward center, simultaneous)
  celestialStart: 0.35,
  arcDuration:    2.05,                // arrive at center together
  meetMoment:     2.4,                 // celestialStart + arcDuration

  // PHASE 3 — The meeting flash (golden bloom + ring)
  flashStart:     2.4,
  flashDuration:  0.55,

  // PHASE 4 — "غسق" name emerges from the flash
  nameStart:      2.7,
  nameSettled:    3.6,

  // PHASE 5 — Subtitle + tagline
  subtitleStart:  3.85,
  taglineStart:   4.35,

  // Total scene duration ≈ 6.5s
};

// Convenience helper for inline animation strings
export const at = (key) => `${T[key]}s`;
