import "./features/animations.css";

import { G, GL, NAVY, NAVY_L } from "../constants/colors";
import Phone from "../components/Phone";
import CornerOrnament from "../components/ornaments/CornerOrnament";

/**
 * ScenePhone — Reusable feature showcase template.
 *
 * Now renders a LIVE React component inside the phone frame
 * (not a static screenshot). Used by Prayer / Qibla / Adhkar.
 *
 * Props:
 *   - screen:       React element shown inside phone (live UI)
 *   - Icon:         icon component for the panel
 *   - sceneNum:     "01" / "02" / "03"
 *   - title:        Arabic feature title
 *   - subtitle:     short Arabic line under title
 *   - kineticWords: array of chip words
 *   - desc:         multi-line description (\n separated)
 *   - accentLine:   Latin uppercase accent
 */
export default function ScenePhone({
  screen,
  Icon,
  sceneNum,
  title,
  subtitle,
  kineticWords = [],
  desc,
  accentLine,
  motion,
}) {
  return (
    <div
      style={{
        display: "flex",
        alignItems: "center",
        gap: 60,
        position: "relative",
        direction: "ltr",
      }}
    >
      {/* Giant scene number floating in background */}
      <div
        className="font-mono"
        style={{
          position: "absolute",
          top: -60,
          left: -20,
          fontSize: 220,
          fontWeight: 200,
          color: G,
          animation: "scene-num-glow 4s ease-in-out infinite",
          opacity: 0.08,
          letterSpacing: "-0.05em",
          lineHeight: 1,
          userSelect: "none",
          pointerEvents: "none",
        }}
      >
        {sceneNum}
      </div>

      {/* Corner ornaments */}
      <div style={{ position: "absolute", top: -10, left: -10, animation: "fade-in 0.6s 1.2s both", opacity: 0 }}>
        <CornerOrnament size={50} />
      </div>
      <div style={{ position: "absolute", bottom: -10, right: -10, transform: "rotate(180deg)", animation: "fade-in 0.6s 1.4s both", opacity: 0 }}>
        <CornerOrnament size={50} />
      </div>

      {/* Phone with glow + LIVE UI inside */}
      <div style={{ position: "relative" }}>
        <div
          style={{
            position: "absolute",
            top: "-20%",
            left: "-30%",
            width: 320,
            height: 320,
            borderRadius: "50%",
            background: `radial-gradient(circle, ${G}25 0%, transparent 60%)`,
            filter: "blur(40px)",
            zIndex: -1,
            animation: "float-y 6s ease-in-out infinite",
          }}
        />
        <Phone motion={motion}>{screen}</Phone>
      </div>

      {/* Content panel */}
      <div style={{ direction: "rtl", maxWidth: 280, animation: "slide-in-right 0.9s 0.5s both" }}>
        {/* Scene number marker + line */}
        <div style={{ display: "flex", alignItems: "center", gap: 12, marginBottom: 24 }}>
          <span
            className="font-mono"
            style={{ color: G, fontSize: 13, fontWeight: 700, letterSpacing: 2 }}
          >
            {sceneNum}
          </span>
          <div style={{ flex: 1, height: 1, background: `linear-gradient(to left, ${G}60, transparent)` }} />
        </div>

        {/* Icon + accent label */}
        <div style={{ display: "flex", alignItems: "center", gap: 14, marginBottom: 18 }}>
          <div
            style={{
              width: 56,
              height: 56,
              borderRadius: 16,
              background: `linear-gradient(135deg, ${NAVY_L}, ${NAVY})`,
              border: `1px solid ${G}40`,
              display: "flex",
              alignItems: "center",
              justifyContent: "center",
              boxShadow: `0 8px 24px rgba(212,168,67,0.2), inset 0 0 20px rgba(212,168,67,0.08)`,
              animation: "pulse-soft 3s ease-in-out infinite",
              flexShrink: 0,
            }}
          >
            <Icon size={28} color={GL} />
          </div>
          <div className="font-light" style={{ color: G, fontSize: 12, letterSpacing: 4 }}>
            {accentLine}
          </div>
        </div>

        {/* Title */}
        <h2
          className="font-display"
          style={{ color: GL, fontSize: 38, fontWeight: 700, marginBottom: 6, lineHeight: 1.1, letterSpacing: "-0.02em" }}
        >
          {title}
        </h2>

        {/* Subtitle */}
        {subtitle && (
          <h3
            className="font-light"
            style={{ color: "#5a6680", fontSize: 16, marginBottom: 18, fontWeight: 300, letterSpacing: "0.02em" }}
          >
            {subtitle}
          </h3>
        )}

        {/* Kinetic word chips */}
        <div style={{ display: "flex", flexWrap: "wrap", gap: 8, marginBottom: 18, direction: "rtl" }}>
          {kineticWords.map((w, i) => (
            <span
              key={i}
              className="font-body"
              style={{
                padding: "6px 14px",
                fontSize: 12,
                fontWeight: 500,
                background: "linear-gradient(135deg, rgba(212,168,67,0.12), rgba(212,168,67,0.04))",
                border: `1px solid ${G}30`,
                borderRadius: 20,
                color: GL,
                animation:
                  `word-pop-stay 0.5s ${1 + i * 0.12}s both, ` +
                  `chip-breathe 3.5s ${2 + i * 0.12}s ease-in-out infinite`,
                opacity: 0,
                backdropFilter: "blur(4px)",
                letterSpacing: "0.02em",
              }}
            >
              {w}
            </span>
          ))}
        </div>

        {/* Description */}
        <p
          className="font-body"
          style={{
            color: "#a0adc0",
            fontSize: 14,
            lineHeight: 1.95,
            whiteSpace: "pre-line",
            fontWeight: 400,
            animation: "fade-up 0.7s 1.7s both",
            opacity: 0,
            letterSpacing: "0.01em",
          }}
        >
          {desc}
        </p>

        {/* Bottom gradient line + dot */}
        <div style={{ marginTop: 22, display: "flex", alignItems: "center", gap: 10, animation: "fade-in 0.6s 2.2s both", opacity: 0 }}>
          <div style={{ height: 1, flex: 1, background: `linear-gradient(to left, transparent, ${G})` }} />
          <div style={{ width: 6, height: 6, borderRadius: "50%", background: G, boxShadow: `0 0 8px ${G}` }} />
        </div>
      </div>
    </div>
  );
}
