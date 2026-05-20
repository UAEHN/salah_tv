import { G } from "../../constants/colors";

/**
 * IslamicTile — 8-pointed star geometric pattern
 *
 * Used as a tiling background pattern (very low opacity)
 */
export default function IslamicTile({ size = 80, opacity = 0.04, color = G }) {
  return (
    <svg width={size} height={size} viewBox="0 0 80 80" style={{ opacity }}>
      <g stroke={color} strokeWidth="0.7" fill="none">
        {/* Outer 8-pointed star */}
        <polygon points="40,10 48,32 70,40 48,48 40,70 32,48 10,40 32,32" />

        {/* Inner 8-pointed star */}
        <polygon points="40,18 45,35 62,40 45,45 40,62 35,45 18,40 35,35" />

        {/* Central circle */}
        <circle cx="40" cy="40" r="8" />
      </g>
    </svg>
  );
}
