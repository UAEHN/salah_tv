import { G } from "../../constants/colors";

/**
 * IconBell — Notification bell
 */
export default function IconBell({ size = 28, color = G }) {
  return (
    <svg width={size} height={size} viewBox="0 0 32 32" fill="none">
      {/* Bell body */}
      <path
        d="M16 4 C 11 4, 9 8, 9 13 V 19 L 7 22 H 25 L 23 19 V 13 C 23 8, 21 4, 16 4 Z"
        fill={color}
        opacity="0.15"
        stroke={color}
        strokeWidth="1.4"
        strokeLinejoin="round"
      />

      {/* Clapper */}
      <path
        d="M14 25 a 2 2 0 0 0 4 0"
        stroke={color}
        strokeWidth="1.4"
        strokeLinecap="round"
      />

      {/* Top stud */}
      <circle cx="16" cy="3" r="1.2" fill={color} />
    </svg>
  );
}
