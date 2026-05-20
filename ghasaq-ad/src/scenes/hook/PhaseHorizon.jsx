import { G, GL } from "../../constants/colors";
import { T } from "./timing";

/**
 * PhaseHorizon — A single luminous horizon line + warm haze.
 * No mountains: a prayer app's visual world is sky/celestial,
 * not earthly silhouettes.
 *
 * The horizon line is exactly where sun & moon will meet,
 * subliminally directing the eye to the climax point.
 */
export default function PhaseHorizon() {
  return (
    <>
      {/* Warm haze halo at the meeting point */}
      <div
        style={{
          position: "absolute",
          top: "50%",
          left: "50%",
          width: 520,
          height: 220,
          marginLeft: -260,
          marginTop: -110,
          background: `radial-gradient(ellipse at center, ${G}22 0%, transparent 70%)`,
          filter: "blur(6px)",
          animation: `sky-fade 2s ${T.ambientStart}s ease-out both`,
          opacity: 0,
          pointerEvents: "none",
        }}
      />

      {/* The horizon line — draws across, settles where sun & moon will meet */}
      <div
        style={{
          position: "absolute",
          top: "50%",
          left: 0,
          right: 0,
          height: 1,
          background: `linear-gradient(to right, transparent, ${GL}, ${G}, ${GL}, transparent)`,
          boxShadow: `0 0 8px ${G}, 0 0 16px ${G}50`,
          transformOrigin: "center",
          animation: `horizon-grow 1.4s ${T.ambientStart + 0.15}s cubic-bezier(.4,0,.2,1) both`,
          pointerEvents: "none",
        }}
      />
    </>
  );
}
