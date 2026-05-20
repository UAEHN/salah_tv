import { GL } from "../../../constants/colors";

/**
 * Moon — Crescent with crater details and soft halo
 *
 * Used in PhaseCelestial. Self-contained SVG with gradient
 * for surface, halo glow, and small crater highlights.
 */
export default function Moon() {
  return (
    <svg width="70" height="70" viewBox="0 0 70 70">
      <defs>
        <radialGradient id="moonSurface" cx="40%" cy="40%">
          <stop offset="0%" stopColor="#fff8d9" />
          <stop offset="50%" stopColor="#f5d27a" />
          <stop offset="100%" stopColor="#8b6f1c" />
        </radialGradient>
        <radialGradient id="moonHalo" cx="50%" cy="50%">
          <stop offset="0%" stopColor={GL} stopOpacity="0.3" />
          <stop offset="100%" stopColor="transparent" />
        </radialGradient>
      </defs>

      {/* Soft halo */}
      <circle cx="35" cy="35" r="33" fill="url(#moonHalo)" />

      {/* Crescent shape */}
      <path
        d="M 42 12 a 23 23 0 1 0 0 46 a 18 18 0 1 1 0 -46z"
        fill="url(#moonSurface)"
      />

      {/* Surface details (craters) */}
      <circle cx="32" cy="22" r="1.2" fill="#fff" opacity="0.5" />
      <circle cx="38" cy="32" r="0.8" fill="#fff" opacity="0.4" />
      <circle cx="29" cy="38" r="1" fill="#fff" opacity="0.4" />
      <circle cx="35" cy="46" r="0.7" fill="#fff" opacity="0.3" />
    </svg>
  );
}
