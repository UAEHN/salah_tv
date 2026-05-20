import { T } from "./timing";

/**
 * SkyDusk — The literal "غسق" sky.
 *
 * A warm horizon band (sunset reds + ambers) blooms across
 * the middle of the frame as sun & moon approach, then
 * recedes into night as the name appears.
 *
 * This is what makes the metaphor LITERAL: the audience
 * sees actual dusk colors — the exact sky of Maghrib.
 */
export default function SkyDusk() {
  return (
    <>
      {/* Warm sunset band centered on the horizon line */}
      <div
        style={{
          position: "absolute",
          top: "30%",
          left: 0,
          right: 0,
          height: "40%",
          background: `linear-gradient(180deg,
            transparent 0%,
            rgba(74, 37, 64, 0.35) 25%,
            rgba(180, 70, 50, 0.55) 50%,
            rgba(74, 37, 64, 0.35) 75%,
            transparent 100%
          )`,
          filter: "blur(2px)",
          mixBlendMode: "screen",
          opacity: 0,
          animation: `sky-dusk-bloom 5s ${T.ambientStart}s ease-in-out both`,
          pointerEvents: "none",
        }}
      />

      {/* Deeper amber pulse right at the horizon */}
      <div
        style={{
          position: "absolute",
          top: "50%",
          left: "50%",
          width: "70%",
          height: 120,
          marginLeft: "-35%",
          marginTop: -60,
          background: `radial-gradient(ellipse at center,
            rgba(245, 160, 70, 0.45) 0%,
            rgba(180, 70, 50, 0.25) 40%,
            transparent 75%
          )`,
          filter: "blur(8px)",
          mixBlendMode: "screen",
          opacity: 0,
          animation: `dusk-band-pulse 4s ${T.ambientStart + 0.4}s ease-in-out both`,
          pointerEvents: "none",
        }}
      />
    </>
  );
}
