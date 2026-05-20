import { G } from "../constants/colors";

// Pre-computed dot positions (deterministic, no re-render flicker)
const DOTS = Array.from({ length: 50 }, (_, i) => ({
  x: (i * 73) % 100,
  y: (i * 41) % 100,
  size: 0.5 + ((i % 7) * 0.3),
  delay: (i * 0.17) % 6,
  dur: 4 + (i % 5),
  o: 0.05 + ((i % 4) * 0.04),
}));

/**
 * StarDots — Fine glittering gold dots scattered across viewport
 *
 * Uses CSS `drift` animation. Each dot pulses slightly on its own.
 */
export default function StarDots() {
  return (
    <div
      style={{
        position: "absolute",
        inset: 0,
        overflow: "hidden",
        zIndex: 0,
      }}
    >
      {DOTS.map((d) => (
        <div
          key={`${d.x}-${d.y}`}
          style={{
            position: "absolute",
            left: `${d.x}%`,
            top: `${d.y}%`,
            width: d.size,
            height: d.size,
            borderRadius: "50%",
            background: G,
            opacity: d.o,
            animation: `drift ${d.dur}s ${d.delay}s ease-in-out infinite`,
            boxShadow: `0 0 ${d.size * 4}px ${G}`,
          }}
        />
      ))}
    </div>
  );
}
