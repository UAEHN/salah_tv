import { G, GL } from "../../constants/colors";
import { T } from "./timing";

// 8 sparkles fly outward from the key word
const SPARKLES = Array.from({ length: 8 }, (_, i) => {
  const angle = (i / 8) * Math.PI * 2;
  const dist = 60 + (i % 3) * 18;
  return {
    id: i,
    sx: Math.cos(angle) * dist + "px",
    sy: Math.sin(angle) * dist + "px",
    delay: (i % 4) * 0.05,
    size: 3 + (i % 2),
  };
});

/**
 * KeyWord — The dramatic peak of the verse.
 *
 * Wraps the highlighted Quranic word ("غَسَقِ") in:
 *   - a golden halo disc (callback to Scene 1's meeting flash)
 *   - a single bright burst ring
 *   - 8 sparkles flying outward
 *   - the word itself with a bloom + sustained glow pulse
 *
 * This is the moment the audience connects "غسق" the word
 * to "غسق" the brand — the entire ad pivots on this beat.
 */
export default function KeyWord({ text }) {
  return (
    <span
      style={{
        position: "relative",
        display: "inline-block",
        padding: "0 0.05em",
      }}
    >
      {/* Halo disc behind */}
      <span
        style={{
          position: "absolute",
          top: "50%",
          left: "50%",
          width: "220%",
          height: "180%",
          transform: "translate(-50%, -50%)",
          background: `radial-gradient(ellipse at center,
            ${G}99 0%,
            ${G}44 35%,
            transparent 70%)`,
          filter: "blur(18px)",
          opacity: 0,
          animation: `key-halo 1.2s ${T.keyWordStart}s cubic-bezier(.2,.7,.3,1) both`,
          zIndex: -2,
          pointerEvents: "none",
        }}
      />

      {/* Burst ring */}
      <span
        style={{
          position: "absolute",
          top: "50%",
          left: "50%",
          width: 80,
          height: 80,
          marginLeft: -40,
          marginTop: -40,
          borderRadius: "50%",
          border: `2px solid ${GL}`,
          boxShadow: `0 0 18px ${G}`,
          opacity: 0,
          animation: `key-burst 1.3s ${T.keyBurstStart}s ease-out both`,
          zIndex: -1,
          pointerEvents: "none",
        }}
      />

      {/* Sparkles flying outward */}
      {SPARKLES.map((s) => (
        <span
          key={s.id}
          style={{
            position: "absolute",
            top: "50%",
            left: "50%",
            width: s.size,
            height: s.size,
            marginLeft: -s.size / 2,
            marginTop: -s.size / 2,
            borderRadius: "50%",
            background: "#fff8d9",
            boxShadow: `0 0 6px ${GL}, 0 0 12px ${G}`,
            "--sx": s.sx,
            "--sy": s.sy,
            opacity: 0,
            animation: `sparkle-burst 1.4s ${T.keyBurstStart + 0.05 + s.delay}s ease-out both`,
            zIndex: 2,
            pointerEvents: "none",
          }}
        />
      ))}

      {/* The word itself */}
      <span
        style={{
          position: "relative",
          display: "inline-block",
          background: `linear-gradient(135deg, #fff8d9 0%, ${GL} 45%, ${G} 100%)`,
          WebkitBackgroundClip: "text",
          backgroundClip: "text",
          WebkitTextFillColor: "transparent",
          fontWeight: 700,
          opacity: 0,
          animation: `
            key-word-bloom 1.0s ${T.keyWordStart}s cubic-bezier(.2,.7,.3,1) both,
            key-pulse 3s ${T.keyWordStart + 1.0}s ease-in-out infinite
          `,
        }}
      >
        {text}
      </span>
    </span>
  );
}
