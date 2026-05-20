import { G } from "../../constants/colors";

/**
 * Arabesque — Horizontal Islamic ornamental divider
 *
 * Used between sections (e.g., above and below Quranic verse)
 */
export default function Arabesque({ width = 200, color = G, opacity = 0.7 }) {
  return (
    <svg width={width} height="20" viewBox="0 0 200 20" fill="none" style={{ opacity }}>
      {/* Left line */}
      <line x1="0" y1="10" x2="80" y2="10" stroke={color} strokeWidth="0.6" />

      {/* Right line */}
      <line x1="120" y1="10" x2="200" y2="10" stroke={color} strokeWidth="0.6" />

      {/* Central decorative motif */}
      <g transform="translate(100, 10)">
        {/* Vesica piscis shape */}
        <path
          d="M-12,0 Q-6,-6 0,0 Q6,-6 12,0 Q6,6 0,0 Q-6,6 -12,0 Z"
          fill="none"
          stroke={color}
          strokeWidth="0.8"
        />
        {/* Center dot */}
        <circle cx="0" cy="0" r="1.5" fill={color} />
        {/* Side dots */}
        <circle cx="-18" cy="0" r="1" fill={color} opacity="0.6" />
        <circle cx="18" cy="0" r="1" fill={color} opacity="0.6" />
      </g>
    </svg>
  );
}
