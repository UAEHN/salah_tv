import { G, GL } from "../constants/colors";
import { SlotNumber, GoldGlyph } from "./features/SlotDigit";

/**
 * SceneStats — Real numbers, slot-rolled.
 *
 * Each digit rolls through 0-9 multiple times before settling
 * on its target — like a precision instrument calibrating.
 * Premium aesthetic that signals "this app was built carefully."
 */
const STATS = [
  { value: 190, suffix: "+", label: "دولة" },
  { value: 13,  suffix: "",  label: "طريقة حساب" },
  { value: 0,   suffix: "",  label: "إعلانات" },
  { value: "∞", suffix: "",  label: "صدقة جارية" },
];

export default function SceneStats() {
  return (
    <div
      style={{
        display: "flex",
        flexDirection: "column",
        alignItems: "center",
        gap: 38,
        textAlign: "center",
        direction: "rtl",
        maxWidth: 920,
        padding: "0 24px",
      }}
    >
      {/* Header */}
      <div style={{ animation: "fade-up 0.6s both" }}>
        <div
          className="font-light"
          style={{
            display: "inline-block",
            padding: "6px 18px",
            background: "rgba(212,168,67,0.08)",
            border: `1px solid ${G}30`,
            borderRadius: 999,
            marginBottom: 18,
            fontSize: 11,
            color: GL,
            letterSpacing: 4,
            fontWeight: 500,
          }}
        >
          الأرقام لا تكذب
        </div>
        <h2
          className="font-display"
          style={{
            fontSize: "clamp(34px, 5.4vw, 48px)",
            fontWeight: 700,
            color: "#dce5f0",
            letterSpacing: "-0.01em",
            lineHeight: 1.2,
          }}
        >
          صلاتك أوّلاً ·{" "}
          <span
            style={{
              background: `linear-gradient(135deg, ${GL}, ${G})`,
              WebkitBackgroundClip: "text",
              WebkitTextFillColor: "transparent",
              backgroundClip: "text",
            }}
          >
            بلا تشتيت
          </span>
        </h2>
      </div>

      {/* Stats cards */}
      <div
        style={{
          display: "grid",
          gridTemplateColumns: "repeat(4, minmax(150px, 1fr))",
          gap: 18,
          width: "100%",
        }}
      >
        {STATS.map((s, i) => {
          const cardDelay = 0.5 + i * 0.14;
          return (
            <div
              key={s.label}
              style={{
                padding: "30px 18px 22px",
                background:
                  "linear-gradient(135deg, rgba(22,34,68,0.7), rgba(10,18,40,0.45))",
                border: `1px solid ${G}30`,
                borderRadius: 22,
                backdropFilter: "blur(8px)",
                textAlign: "center",
                animation:
                  `count-up 0.7s ${cardDelay}s cubic-bezier(.2,.7,.3,1) both, ` +
                  `scale-in 0.7s ${cardDelay}s cubic-bezier(.16,1.2,.3,1) both`,
                opacity: 0,
                boxShadow: `inset 0 0 30px ${G}12, 0 12px 32px rgba(0,0,0,0.35)`,
                position: "relative",
                overflow: "hidden",
              }}
            >
              {/* Card light sweep */}
              <div
                style={{
                  position: "absolute",
                  inset: 0,
                  background: `linear-gradient(115deg, transparent 30%, ${G}30 50%, transparent 70%)`,
                  transform: "translateX(-100%)",
                  animation: `card-sheen 1.8s ${cardDelay + 0.6}s ease-out both`,
                  pointerEvents: "none",
                }}
              />

              {/* The big number — slot rolls */}
              <div
                className="font-mono"
                style={{
                  fontSize: "clamp(48px, 6vw, 68px)",
                  fontWeight: 800,
                  lineHeight: 1,
                  letterSpacing: "-0.03em",
                  filter: `drop-shadow(0 0 18px ${G}55)`,
                  fontVariantNumeric: "tabular-nums",
                  display: "inline-flex",
                  alignItems: "baseline",
                  direction: "ltr",
                }}
              >
                {typeof s.value === "number" ? (
                  <SlotNumber value={s.value} startDelay={cardDelay + 0.3} />
                ) : (
                  <GoldGlyph
                    style={{
                      animation: `count-up 0.6s ${cardDelay + 0.3}s cubic-bezier(.2,.7,.3,1) both`,
                      opacity: 0,
                    }}
                  >
                    {s.value}
                  </GoldGlyph>
                )}
                {s.suffix && (
                  <GoldGlyph
                    style={{
                      fontSize: "0.7em",
                      animation: `count-up 0.5s ${cardDelay + 1.7}s cubic-bezier(.2,.7,.3,1) both`,
                      opacity: 0,
                    }}
                  >
                    {s.suffix}
                  </GoldGlyph>
                )}
              </div>

              {/* Label */}
              <div
                className="font-body-bold"
                style={{
                  color: "#dce5f0",
                  fontSize: 13,
                  marginTop: 14,
                  letterSpacing: 0.5,
                }}
              >
                {s.label}
              </div>
            </div>
          );
        })}
      </div>
    </div>
  );
}
