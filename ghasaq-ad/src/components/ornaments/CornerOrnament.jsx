import { G } from "../../constants/colors";

/**
 * CornerOrnament — Decorative arabesque corner element
 *
 * Place rotate(180deg) on bottom-right etc.
 */
export default function CornerOrnament({ size = 60, color = G, opacity = 0.4 }) {
  return (
    <svg width={size} height={size} viewBox="0 0 60 60" fill="none" style={{ opacity }}>
      {/* Outer arc */}
      <path d="M5,30 Q5,5 30,5" stroke={color} strokeWidth="0.8" fill="none" />

      {/* Inner arc (faded) */}
      <path d="M10,30 Q10,10 30,10" stroke={color} strokeWidth="0.5" fill="none" opacity="0.6" />

      {/* End points */}
      <circle cx="5" cy="30" r="1.5" fill={color} />
      <circle cx="30" cy="5" r="1.5" fill={color} />

      {/* Decorative cross marks */}
      <path
        d="M30,5 L33,2 M30,5 L27,2 M5,30 L2,33 M5,30 L2,27"
        stroke={color}
        strokeWidth="0.6"
      />
    </svg>
  );
}
