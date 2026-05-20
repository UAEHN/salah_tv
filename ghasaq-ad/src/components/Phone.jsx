import { BG } from "../constants/colors";

/* Aura particles drifting around the phone perimeter */
const AURA = [
  { x: -28, y: 60,  size: 3, dur: 7,   delay: 0 },
  { x: -22, y: 220, size: 2, dur: 8.5, delay: 1.5 },
  { x: -16, y: 380, size: 2, dur: 9,   delay: 0.6 },
  { x: 252, y: 90,  size: 3, dur: 6.5, delay: 0.8 },
  { x: 258, y: 250, size: 2, dur: 8,   delay: 2.2 },
  { x: 244, y: 420, size: 3, dur: 7.5, delay: 1.2 },
  { x: 100, y: -18, size: 2, dur: 9,   delay: 2.6 },
  { x: 140, y: 510, size: 2, dur: 7,   delay: 0.4 },
];

/**
 * Phone — 3D iPhone-style mockup with depth, shadow, and aura.
 *
 * Visual upgrades:
 *   - Floor shadow (blurred, breathes with phone)
 *   - Idle 3D breathing tilt (continuous after entrance)
 *   - 8 floating golden aura particles drifting around perimeter
 *   - Glass reflection that catches light
 *   - Notch with sensor dot
 *
 * The phone now feels alive — never static — which is what
 * separates premium app ads from generic mockup screenshots.
 */
export default function Phone({ children, hasNotch = true, idle = true, motion }) {
  // Pick the idle animation based on motion variant.
  // "qibla" = slow Z-axis rotation simulating a user turning their phone
  // (default) = gentle breathing tilt
  const idleAnim = !idle
    ? null
    : motion === "qibla"
      ? "phone-qibla-search 3.4s 1.1s cubic-bezier(.4,0,.2,1) forwards"
      : "phone-breathe 7s 1.1s ease-in-out infinite";

  const phoneAnimation = `phone-rise-3d 1.1s cubic-bezier(.2,.7,.3,1) forwards${idleAnim ? ", " + idleAnim : ""}`;

  return (
    <div style={{ position: "relative", width: 240, height: 500 }}>
      {/* Floating aura particles around the phone */}
      {idle &&
        AURA.map((p, i) => (
          <div
            key={i}
            style={{
              position: "absolute",
              top: p.y,
              left: p.x,
              width: p.size,
              height: p.size,
              borderRadius: "50%",
              background: "#fff8d9",
              boxShadow: "0 0 8px #f5d27a, 0 0 16px #d4a843",
              animation: `phone-aura-drift ${p.dur}s ${p.delay}s ease-in-out infinite`,
              opacity: 0,
              pointerEvents: "none",
              zIndex: -1,
            }}
          />
        ))}

      {/* The phone body */}
      <div
        style={{
          width: 240,
          height: 500,
          position: "relative",
          borderRadius: 42,
          padding: 4,
          background: "linear-gradient(145deg, #2a2f3e 0%, #0e1320 50%, #2a2f3e 100%)",
          boxShadow: `
            0 0 0 1px rgba(212,168,67,0.2),
            0 30px 80px rgba(0,0,0,0.6),
            0 60px 120px rgba(0,0,0,0.4),
            inset 0 0 0 1px rgba(255,255,255,0.06)
          `,
          animation: phoneAnimation,
          transformStyle: "preserve-3d",
          flexShrink: 0,
        }}
      >
        {/* Glass reflection overlay (catches edge light) */}
        <div
          style={{
            position: "absolute",
            inset: 4,
            borderRadius: 38,
            background:
              "linear-gradient(135deg, rgba(255,255,255,0.10) 0%, transparent 28%, transparent 72%, rgba(255,255,255,0.05) 100%)",
            pointerEvents: "none",
            zIndex: 20,
          }}
        />

        {/* Subtle moving sheen */}
        <div
          style={{
            position: "absolute",
            inset: 4,
            borderRadius: 38,
            background:
              "linear-gradient(115deg, transparent 30%, rgba(255,255,255,0.08) 50%, transparent 70%)",
            pointerEvents: "none",
            zIndex: 21,
            animation: idle ? "phone-sheen 6s 2s ease-in-out infinite" : "none",
            opacity: 0,
          }}
        />

        {/* Inner screen */}
        <div
          style={{
            width: "100%",
            height: "100%",
            borderRadius: 38,
            background: BG,
            overflow: "hidden",
            position: "relative",
          }}
        >
          {hasNotch && (
            <div
              style={{
                position: "absolute",
                top: 8,
                left: "50%",
                transform: "translateX(-50%)",
                width: 80,
                height: 22,
                background: "#000",
                borderRadius: 12,
                zIndex: 15,
              }}
            >
              <div
                style={{
                  position: "absolute",
                  right: 12,
                  top: "50%",
                  transform: "translateY(-50%)",
                  width: 6,
                  height: 6,
                  borderRadius: "50%",
                  background: "#222",
                  border: "1px solid #333",
                }}
              />
            </div>
          )}

          {children}
        </div>
      </div>
    </div>
  );
}
