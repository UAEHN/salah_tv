import { G, GL, GD } from "../../constants/colors";
import { T } from "./timing";

/**
 * PhaseGhasaqName — "غسق" emerges from the meeting flash.
 *
 * Typography: Amiri 700 — the gold-standard Arabic naskh
 * used in luxury publications. Tightened tracking, gold
 * gradient fill, and twin geometric ornaments above and
 * below for that "premium book-jacket calligraphy" feel.
 */
export default function PhaseGhasaqName() {
  return (
    <div
      style={{
        position: "absolute",
        top: "50%",
        left: 0,
        right: 0,
        textAlign: "center",
        transform: "translateY(-50%)",
        pointerEvents: "none",
        zIndex: 5,
      }}
    >
      {/* Soft golden halo disc behind the name */}
      <div
        style={{
          position: "absolute",
          top: "50%",
          left: "50%",
          width: 540,
          height: 260,
          marginLeft: -270,
          marginTop: -130,
          background: `radial-gradient(ellipse at center, ${G}66 0%, ${G}22 35%, transparent 72%)`,
          filter: "blur(32px)",
          animation: `name-halo 1.1s ${T.nameStart}s cubic-bezier(.2,.7,.3,1) both`,
          opacity: 0,
          zIndex: -1,
        }}
      />

      {/* Top ornament — small geometric Islamic flourish */}
      <Ornament direction="top" />

      {/* The brand name in Amiri 700 (luxury Arabic naskh) */}
      <div
        className="font-luxury"
        style={{
          fontSize: "clamp(110px, 18vw, 240px)",
          lineHeight: 1.05,
          background: `linear-gradient(180deg, ${GL} 0%, #fff8d9 38%, ${G} 70%, ${GD} 100%)`,
          WebkitBackgroundClip: "text",
          backgroundClip: "text",
          color: "transparent",
          letterSpacing: "-0.04em",
          textShadow: `0 2px 0 rgba(0,0,0,0.25)`,
          animation: `
            name-emerge 1.05s ${T.nameStart}s cubic-bezier(.2,.7,.3,1) both,
            name-breath 3.5s ${T.nameSettled}s ease-in-out infinite
          `,
          opacity: 0,
        }}
      >
        غسق
      </div>

      {/* Bottom ornament — mirrored */}
      <Ornament direction="bottom" />
    </div>
  );
}

/* Small geometric ornament: a thin gold line with a diamond
   center and two flanking dots. Matches Ottoman manuscript
   title-page flourishes. */
function Ornament({ direction }) {
  const isTop = direction === "top";
  return (
    <div
      style={{
        display: "flex",
        alignItems: "center",
        justifyContent: "center",
        gap: 10,
        margin: isTop ? "0 auto 14px" : "14px auto 0",
        opacity: 0,
        animation: `name-halo 1.2s ${T.nameStart + 0.25}s cubic-bezier(.2,.7,.3,1) both`,
      }}
    >
      <Line />
      <Dot size={4} />
      <Diamond />
      <Dot size={4} />
      <Line />
    </div>
  );
}

function Line() {
  return (
    <div
      style={{
        width: 90,
        height: 1,
        background: `linear-gradient(to right, transparent, ${G}, transparent)`,
        boxShadow: `0 0 6px ${G}80`,
      }}
    />
  );
}

function Dot({ size = 4 }) {
  return (
    <div
      style={{
        width: size,
        height: size,
        borderRadius: "50%",
        background: GL,
        boxShadow: `0 0 6px ${GL}`,
      }}
    />
  );
}

function Diamond() {
  return (
    <div
      style={{
        width: 8,
        height: 8,
        background: GL,
        transform: "rotate(45deg)",
        boxShadow: `0 0 8px ${GL}, 0 0 16px ${G}80`,
      }}
    />
  );
}
