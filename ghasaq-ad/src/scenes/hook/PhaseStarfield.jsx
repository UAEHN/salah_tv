import { T } from "./timing";

// Calm starfield — two layers, no shooting stars (they would
// distract from the central sun/moon meeting moment).
const LAYER_FAR = Array.from({ length: 60 }, (_, i) => ({
  id: `f-${i}`,
  x: (i * 71.3) % 100,
  y: (i * 43.7) % 100,
  size: 0.8 + (i % 3) * 0.25,
  delay: (i * 0.13) % 4,
  o: 0.18 + (i % 4) * 0.08,
}));

const LAYER_NEAR = Array.from({ length: 18 }, (_, i) => ({
  id: `n-${i}`,
  x: ((i * 191.3) + 7) % 100,
  y: ((i * 87.1) + 23) % 100,
  size: 1.6 + (i % 2) * 0.8,
  delay: (i * 0.31) % 3,
  o: 0.45 + (i % 2) * 0.2,
}));

const STARS = [...LAYER_FAR, ...LAYER_NEAR];

export default function PhaseStarfield() {
  return (
    <div
      style={{
        position: "absolute",
        inset: 0,
        animation: `sky-fade 2.2s ${T.ambientStart}s ease-out both`,
        opacity: 0,
        pointerEvents: "none",
      }}
    >
      {STARS.map((s) => (
        <div
          key={s.id}
          style={{
            position: "absolute",
            left: `${s.x}%`,
            top: `${s.y}%`,
            width: s.size,
            height: s.size,
            borderRadius: "50%",
            background: "#fff8d9",
            boxShadow: `0 0 ${s.size * 3}px #f5d27a`,
            "--base-o": s.o,
            opacity: s.o,
            animation: `star-twinkle ${3 + (s.size % 2)}s ${s.delay}s ease-in-out infinite`,
          }}
        />
      ))}
    </div>
  );
}
