import { G, GL } from "../constants/colors";
import { IMG } from "../constants/images";
import Arabesque from "../components/ornaments/Arabesque";

/**
 * SceneProblem — Emotional question → dramatic answer.
 *
 * Beats:
 *   1. Soft intro line ("نسأل أنفسنا أحياناً")
 *   2. The question — heavy, weighted, second line dimmer
 *   3. Pause / breath
 *   4. Golden swipe of light across screen
 *   5. The answer — app icon + name burst into view
 *   6. Tagline below
 */
export default function SceneProblem() {
  return (
    <div
      style={{
        display: "flex",
        flexDirection: "column",
        alignItems: "center",
        gap: 26,
        textAlign: "center",
        direction: "rtl",
        position: "relative",
        width: "100%",
      }}
    >
      {/* The introspective question */}
      <div style={{ animation: "fade-up 0.7s cubic-bezier(.2,.7,.3,1) both" }}>
        <div
          className="font-light"
          style={{
            color: "#7a8599",
            fontSize: 13,
            marginBottom: 16,
            opacity: 0.7,
            letterSpacing: "0.2em",
          }}
        >
          ⏤  نسأل أنفسنا أحياناً  ⏤
        </div>
        <div
          className="font-display"
          style={{
            fontSize: "clamp(36px, 5.6vw, 56px)",
            color: "#dce5f0",
            fontWeight: 700,
            lineHeight: 1.3,
            letterSpacing: "-0.01em",
          }}
        >
          كم صلاةٍ فاتت
          <br />
          <span
            style={{
              color: "#5a6680",
              fontWeight: 500,
              animation: "fade-up 0.6s 0.6s both",
              display: "inline-block",
              opacity: 0,
            }}
          >
            دون أن نشعر؟
          </span>
        </div>
      </div>

      {/* Light sweep across — the "answer arrives" beat */}
      <div
        style={{
          position: "absolute",
          top: "55%",
          left: 0,
          right: 0,
          height: 80,
          background: `linear-gradient(90deg, transparent, ${G}55, ${GL}88, ${G}55, transparent)`,
          filter: "blur(20px)",
          transform: "translateX(-100%)",
          animation: "answer-sweep 1.2s 2s cubic-bezier(.2,.7,.3,1) both",
          pointerEvents: "none",
          zIndex: 1,
        }}
      />

      {/* Decorative divider */}
      <div
        style={{
          animation: "ornament-grow 0.7s 2.2s cubic-bezier(.2,.7,.3,1) both",
          opacity: 0,
          transformOrigin: "center",
        }}
      >
        <Arabesque width={160} opacity={0.6} />
      </div>

      {/* The solution — app card bursts in */}
      <div
        style={{
          animation: "answer-burst 0.9s 2.6s cubic-bezier(.16,1.2,.3,1) both",
          opacity: 0,
          position: "relative",
        }}
      >
        {/* Glow halo behind card */}
        <div
          style={{
            position: "absolute",
            inset: -30,
            borderRadius: 60,
            background: `radial-gradient(ellipse, ${G}45 0%, ${G}15 40%, transparent 70%)`,
            filter: "blur(24px)",
            zIndex: -1,
            animation: "halo-breathe 3s 3.5s ease-in-out infinite",
          }}
        />

        <div
          style={{
            display: "inline-flex",
            alignItems: "center",
            gap: 18,
            padding: "20px 34px",
            background:
              "linear-gradient(135deg, rgba(212,168,67,0.18), rgba(212,168,67,0.05))",
            border: `1px solid ${G}55`,
            borderRadius: 50,
            backdropFilter: "blur(12px)",
            boxShadow: `0 16px 40px rgba(212,168,67,0.25), inset 0 0 24px ${G}15`,
          }}
        >
          {/* App icon */}
          <div
            style={{
              width: 56,
              height: 56,
              borderRadius: 16,
              overflow: "hidden",
              border: `1.5px solid ${G}80`,
              boxShadow: `0 0 28px ${G}80, 0 0 56px ${G}40`,
              flexShrink: 0,
            }}
          >
            <img
              src={IMG.logo}
              alt=""
              style={{ width: "100%", height: "100%", objectFit: "cover" }}
            />
          </div>

          {/* Brand name and tagline */}
          <div style={{ direction: "rtl", textAlign: "right" }}>
            <div
              className="font-luxury"
              style={{
                background: `linear-gradient(180deg, ${GL} 0%, #fff8d9 45%, ${G} 100%)`,
                WebkitBackgroundClip: "text",
                backgroundClip: "text",
                color: "transparent",
                fontSize: 38,
                lineHeight: 0.95,
                letterSpacing: "-0.04em",
              }}
            >
              غسق
            </div>
            <div
              className="font-body"
              style={{
                color: "#a0adc0",
                fontSize: 12,
                marginTop: 6,
                letterSpacing: "0.08em",
              }}
            >
              الجواب · بين يديك
            </div>
          </div>
        </div>
      </div>
    </div>
  );
}
