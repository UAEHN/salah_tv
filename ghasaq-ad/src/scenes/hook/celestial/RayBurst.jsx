import { GL } from "../../../constants/colors";

/**
 * RayBurst — 12 light rays emanating from a center point
 *
 * Used at the twilight moment when sun and moon meet,
 * representing the spiritual significance of "غسق".
 */
export default function RayBurst() {
  return (
    <svg
      width="200"
      height="200"
      viewBox="0 0 200 200"
      style={{
        position: "absolute",
        top: -100,
        left: -100,
      }}
    >
      <defs>
        <linearGradient id="rayGrad" x1="0" y1="0" x2="0" y2="1">
          <stop offset="0%" stopColor={GL} stopOpacity="0.9" />
          <stop offset="100%" stopColor={GL} stopOpacity="0" />
        </linearGradient>
      </defs>

      {Array.from({ length: 12 }).map((_, i) => (
        <rect
          key={i}
          x="98"
          y="20"
          width="4"
          height="80"
          fill="url(#rayGrad)"
          transform={`rotate(${i * 30} 100 100)`}
          rx="2"
        />
      ))}
    </svg>
  );
}
