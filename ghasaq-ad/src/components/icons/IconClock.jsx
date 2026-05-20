import { G } from "../../constants/colors";

/**
 * IconClock — Clock face with crescent moon (prayer times)
 */
export default function IconClock({ size = 28, color = G }) {
  return (
    <svg width={size} height={size} viewBox="0 0 32 32" fill="none">
      {/* Outer ring */}
      <circle cx="16" cy="16" r="13" stroke={color} strokeWidth="1.5" />

      {/* Clock hands */}
      <path
        d="M16 7v9l5 3"
        stroke={color}
        strokeWidth="1.5"
        strokeLinecap="round"
      />

      {/* Crescent moon (top right) */}
      <path
        d="M22 5a3.5 3.5 0 1 0 0 7 4 4 0 0 1 0-7z"
        fill={color}
        opacity="0.85"
      />

      {/* Center dot */}
      <circle cx="16" cy="16" r="1.4" fill={color} />

      {/* 12/3/6/9 markers */}
      {[0, 90, 180, 270].map((a) => (
        <line
          key={a}
          x1="16" y1="4" x2="16" y2="6"
          stroke={color}
          strokeWidth="1.2"
          strokeLinecap="round"
          transform={`rotate(${a} 16 16)`}
        />
      ))}
    </svg>
  );
}
