import { G } from "../../constants/colors";

/**
 * IconBeads — Tasbih / prayer beads (athkar)
 */
export default function IconBeads({ size = 28, color = G }) {
  // Beads positioned along an arc
  const beads = [
    [6, 11], [10, 8.5], [14, 7.5],
    [18, 7.5], [22, 8.5], [26, 11]
  ];

  return (
    <svg width={size} height={size} viewBox="0 0 32 32" fill="none">
      {/* String / arc */}
      <path d="M5 10 Q 16 4, 27 10" stroke={color} strokeWidth="1" fill="none" opacity="0.4" />

      {/* Top beads */}
      {beads.map(([cx, cy], i) => (
        <circle
          key={i}
          cx={cx} cy={cy} r="1.6"
          fill={color}
          opacity={0.6 + (i === 2 || i === 3 ? 0.4 : 0)}
        />
      ))}

      {/* Main central tasbih bead */}
      <circle cx="16" cy="20" r="3.5" fill={color} />

      {/* Connecting lines */}
      <line x1="16" y1="11" x2="16" y2="16.5" stroke={color} strokeWidth="0.7" opacity="0.5" />
      <line x1="16" y1="23.5" x2="16" y2="25.7" stroke={color} strokeWidth="0.7" opacity="0.5" />

      {/* Bottom small bead */}
      <circle cx="16" cy="27" r="1.3" fill={color} opacity="0.6" />
    </svg>
  );
}
