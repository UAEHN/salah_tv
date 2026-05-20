import { G, GL } from "../constants/colors";
import { IMG } from "../constants/images";
import Phone from "../components/Phone";

/**
 * SceneNotification — Realistic iOS lock screen with a STACK of
 * Ghasaq notifications appearing in sequence, mirroring the
 * app's real notification flow:
 *
 *   1. Pre-adhan reminder (10 min before)
 *   2. Adhan time
 *   3. Iqama countdown
 *
 * Each notification slides down with a stagger. The stack
 * conveys "you'll be reminded at every step" without a single
 * line of text needing to say it.
 */
const NOTIFS = [
  {
    title: "غسق · تنبيه قبل الأذان",
    body: "بقي 10 دقائق على أذان المغرب",
    when: "الآن",
    delay: 0.6,
    accent: "#a0adc0",
  },
  {
    title: "غسق · المغرب",
    body: "حان الآن موعد أذان المغرب",
    when: "8:23",
    delay: 1.4,
    accent: GL,
    primary: true,
  },
  {
    title: "غسق · إقامة المغرب",
    body: "اقتربت إقامة الصلاة · 2 دقائق",
    when: "8:33",
    delay: 2.2,
    accent: "#e74c3c",
  },
];

export default function SceneNotification() {
  return (
    <div
      style={{
        display: "flex",
        flexDirection: "column",
        alignItems: "center",
        gap: 28,
      }}
    >
      {/* Section header */}
      <div style={{ animation: "fade-up 0.6s both", textAlign: "center" }}>
        <h2
          className="font-display"
          style={{
            color: GL,
            fontSize: "clamp(34px, 5vw, 42px)",
            fontWeight: 700,
            letterSpacing: "-0.01em",
            lineHeight: 1.15,
          }}
        >
          لن تفوّتك صلاة بعد اليوم
        </h2>
      </div>

      {/* Phone with lock screen — wrapped with adhan call waves */}
      <div style={{ position: "relative" }}>
        {/* Concentric gold waves emanating outward — visualizes the call to prayer */}
        {[0, 1, 2, 3].map((i) => (
          <div
            key={i}
            style={{
              position: "absolute",
              top: "50%",
              left: "50%",
              width: 240,
              height: 240,
              marginLeft: -120,
              marginTop: -120,
              borderRadius: "50%",
              border: `1.5px solid ${G}`,
              opacity: 0,
              animation: `adhan-wave 4s ${1.6 + i * 1}s ease-out infinite`,
              pointerEvents: "none",
              zIndex: 0,
            }}
          />
        ))}

      <Phone>
        <div
          style={{
            width: "100%",
            height: "100%",
            position: "relative",
            background: `
              radial-gradient(circle at 30% 20%, rgba(212,168,67,0.15) 0%, transparent 50%),
              radial-gradient(circle at 70% 80%, rgba(231,126,52,0.10) 0%, transparent 50%),
              linear-gradient(180deg, #0a1228 0%, #050811 100%)
            `,
          }}
        >
          {/* Vignette overlay */}
          <div
            style={{
              position: "absolute",
              inset: 0,
              opacity: 0.5,
              background:
                "radial-gradient(circle at 50% 50%, transparent 60%, rgba(0,0,0,0.4) 100%)",
            }}
          />

          {/* iOS status bar */}
          <div
            style={{
              position: "absolute",
              top: 16,
              left: 0,
              right: 0,
              display: "flex",
              justifyContent: "space-between",
              alignItems: "center",
              padding: "0 24px",
              color: "#fff",
              fontSize: 13,
              fontWeight: 600,
              fontFamily: "system-ui",
              zIndex: 5,
            }}
          >
            <span>8:13</span>
            <div style={{ display: "flex", gap: 5, alignItems: "center" }}>
              <svg width="16" height="10" viewBox="0 0 16 10">
                <rect x="0" y="6" width="2" height="4" rx="0.5" fill="#fff" />
                <rect x="4" y="4" width="2" height="6" rx="0.5" fill="#fff" />
                <rect x="8" y="2" width="2" height="8" rx="0.5" fill="#fff" />
                <rect x="12" y="0" width="2" height="10" rx="0.5" fill="#fff" />
              </svg>
              <svg width="22" height="10" viewBox="0 0 22 10">
                <rect x="0.5" y="0.5" width="18" height="9" rx="2" fill="none" stroke="#fff" strokeWidth="0.8" />
                <rect x="2" y="2" width="14" height="6" rx="1" fill="#fff" />
                <rect x="20" y="3" width="1.5" height="4" rx="0.5" fill="#fff" />
              </svg>
            </div>
          </div>

          {/* Hijri date + time */}
          <div
            style={{
              position: "absolute",
              top: 60,
              left: 0,
              right: 0,
              textAlign: "center",
              color: "#fff",
              animation: "fade-in 0.8s 0.2s both",
            }}
          >
            <div
              className="font-body"
              style={{ fontSize: 13, opacity: 0.85, marginBottom: 2 }}
            >
              السبت · 15 ذو القعدة
            </div>
            <div
              style={{
                fontSize: 60,
                fontWeight: 200,
                lineHeight: 1,
                fontFamily: "system-ui",
                letterSpacing: "-0.04em",
              }}
            >
              8:23
            </div>
          </div>

          {/* Stack of notifications */}
          <div style={{ position: "absolute", top: 168, left: 10, right: 10 }}>
            {NOTIFS.map((n, i) => (
              <NotifCard key={i} index={i} {...n} />
            ))}
          </div>

          {/* Bottom unlock indicator */}
          <div
            style={{
              position: "absolute",
              bottom: 10,
              left: "50%",
              transform: "translateX(-50%)",
              width: 80,
              height: 4,
              borderRadius: 2,
              background: "rgba(255,255,255,0.4)",
            }}
          />
        </div>
      </Phone>
      </div>
    </div>
  );
}

function NotifCard({ title, body, when, delay, accent, primary, index }) {
  return (
    <div
      style={{
        marginBottom: 7,
        animation: `notif-drop 0.7s ${delay}s cubic-bezier(.16,1,.3,1) both`,
        opacity: 0,
        position: "relative",
        zIndex: 10 - index,
      }}
    >
      <div
        style={{
          background: primary
            ? "linear-gradient(135deg, rgba(40,32,20,0.92), rgba(28,24,18,0.88))"
            : "rgba(28, 32, 44, 0.85)",
          backdropFilter: "blur(20px)",
          WebkitBackdropFilter: "blur(20px)",
          borderRadius: 14,
          padding: "9px 11px",
          border: primary
            ? `1px solid ${G}55`
            : "1px solid rgba(255,255,255,0.06)",
          boxShadow: primary
            ? `0 12px 30px rgba(0,0,0,0.5), 0 0 24px ${G}30, inset 0 1px 0 rgba(255,255,255,0.08)`
            : "0 8px 22px rgba(0,0,0,0.4), inset 0 1px 0 rgba(255,255,255,0.05)",
          display: "flex",
          alignItems: "center",
          gap: 9,
          direction: "rtl",
        }}
      >
        {/* App icon */}
        <div
          style={{
            width: 34,
            height: 34,
            borderRadius: 9,
            overflow: "hidden",
            flexShrink: 0,
            boxShadow: primary ? `0 0 14px ${G}66` : `0 0 8px ${G}30`,
            border: primary ? `1px solid ${G}50` : "none",
          }}
        >
          <img
            src={IMG.logo}
            alt=""
            style={{ width: "100%", height: "100%", objectFit: "cover" }}
          />
        </div>

        {/* Content */}
        <div style={{ flex: 1, minWidth: 0 }}>
          <div
            style={{
              display: "flex",
              justifyContent: "space-between",
              alignItems: "baseline",
              marginBottom: 2,
            }}
          >
            <span
              className="font-body-bold"
              style={{ color: accent, fontSize: 11, letterSpacing: 0.2 }}
            >
              {title}
            </span>
            <span
              style={{
                color: "rgba(255,255,255,0.5)",
                fontSize: 10,
                fontFamily: "system-ui",
              }}
            >
              {when}
            </span>
          </div>
          <div
            className="font-body"
            style={{
              color: "rgba(255,255,255,0.85)",
              fontSize: 11,
              lineHeight: 1.35,
            }}
          >
            {body}
          </div>
        </div>
      </div>
    </div>
  );
}
