/**
 * Sun — Layered glowing sphere with halo and lens flare
 *
 * Used in PhaseCelestial. Self-contained SVG with gradients
 * for warm core, soft halo, and bright highlights.
 */
export default function Sun() {
  return (
    <svg width="80" height="80" viewBox="0 0 80 80">
      <defs>
        <radialGradient id="sunCore" cx="50%" cy="50%">
          <stop offset="0%" stopColor="#fff8d9" />
          <stop offset="40%" stopColor="#ffd97a" />
          <stop offset="100%" stopColor="#e8a830" />
        </radialGradient>
        <radialGradient id="sunHalo" cx="50%" cy="50%">
          <stop offset="0%" stopColor="#ffd97a" stopOpacity="0.8" />
          <stop offset="60%" stopColor="#e8a830" stopOpacity="0.3" />
          <stop offset="100%" stopColor="transparent" />
        </radialGradient>
      </defs>

      {/* Outer halo */}
      <circle cx="40" cy="40" r="38" fill="url(#sunHalo)" />

      {/* Mid glow */}
      <circle cx="40" cy="40" r="24" fill="url(#sunHalo)" opacity="0.7" />

      {/* Core */}
      <circle cx="40" cy="40" r="14" fill="url(#sunCore)" />

      {/* Lens flare highlights */}
      <circle cx="35" cy="35" r="3" fill="#fff" opacity="0.6" />
      <circle cx="38" cy="33" r="1.5" fill="#fff" opacity="0.9" />
    </svg>
  );
}
