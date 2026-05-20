import { G, GL } from "../../constants/colors";
import { T } from "./timing";

// 18 floating dust motes — randomized but deterministic
const MOTES = Array.from({ length: 18 }, (_, i) => ({
  id: i,
  left: ((i * 53.7) + 8) % 100,
  size: 1.5 + (i % 3) * 0.8,
  delay: (i * 0.27) % 4,
  duration: 5 + (i % 4),
  o: 0.35 + (i % 3) * 0.2,
}));

/**
 * SpotlightBackdrop — Soft golden spotlight + floating motes.
 * Evokes light streaming through a mosque window — a reverent
 * atmosphere for the verse to land in.
 */
export default function SpotlightBackdrop() {
  return (
    <>
      {/* Soft golden spotlight (breathing) */}
      <div
        style={{
          position: "absolute",
          top: "50%",
          left: "50%",
          width: 900,
          height: 600,
          marginLeft: -450,
          marginTop: -300,
          background: `radial-gradient(ellipse at center,
            ${G}38 0%,
            ${G}18 30%,
            transparent 65%)`,
          filter: "blur(40px)",
          opacity: 0,
          animation: `
            spotlight-in 1.6s ${T.spotlightStart}s ease-out both,
            spotlight-breath 5s ${T.spotlightStart + 1.6}s ease-in-out infinite
          `,
          pointerEvents: "none",
          zIndex: 0,
        }}
      />

      {/* Floating dust motes rising upward */}
      <div
        style={{
          position: "absolute",
          inset: 0,
          pointerEvents: "none",
          zIndex: 1,
        }}
      >
        {MOTES.map((m) => (
          <div
            key={m.id}
            style={{
              position: "absolute",
              left: `${m.left}%`,
              bottom: "10%",
              width: m.size,
              height: m.size,
              borderRadius: "50%",
              background: GL,
              boxShadow: `0 0 ${m.size * 4}px ${GL}, 0 0 ${m.size * 8}px ${G}80`,
              "--mote-o": m.o,
              opacity: 0,
              animation: `mote-rise ${m.duration}s ${T.particlesStart + m.delay}s ease-out infinite`,
            }}
          />
        ))}
      </div>
    </>
  );
}
