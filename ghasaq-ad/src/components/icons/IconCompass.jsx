import { G } from "../../constants/colors";

/**
 * IconCompass — Compass with needle (qibla direction)
 */
export default function IconCompass({ size = 28, color = G }) {
  return (
    <svg width={size} height={size} viewBox="0 0 32 32" fill="none">
      {/* Outer ring */}
      <circle cx="16" cy="16" r="13" stroke={color} strokeWidth="1.5" />

      {/* Inner ring */}
      <circle cx="16" cy="16" r="9" stroke={color} strokeWidth="0.8" opacity="0.4" />

      {/* North needle (filled) */}
      <path d="M16 6 L19 16 L16 14 L13 16 Z" fill={color} />

      {/* South needle (faded) */}
      <path d="M16 26 L13 16 L16 18 L19 16 Z" fill={color} opacity="0.4" />

      {/* Center dot */}
      <circle cx="16" cy="16" r="1.5" fill="#fff" />
    </svg>
  );
}
