import { G, GL, GD } from "../constants/colors";
import { IMG } from "../constants/images";
import Phone from "../components/Phone";
import PrayerHeroCard from "./features/PrayerHeroCard";

/**
 * SceneCTA — Final composition (the closing climax).
 *
 * Two-column hero composition that summarizes the whole ad:
 *
 *   LEFT  → the live phone (PrayerHeroCard inside) — the product.
 *   RIGHT → the brand identity + download buttons — the action.
 *
 * Behind it all: a colossal "غسق" watermark in luxury Amiri,
 * a slow-rotating gold conic-gradient halo, and a breathing
 * radial bloom. Bookends the Hook scene visually & typographically.
 */
export default function SceneCTA() {
  return (
    <div
      style={{
        position: "relative",
        width: "100%",
        height: "100%",
        display: "flex",
        alignItems: "center",
        justifyContent: "center",
        direction: "rtl",
        overflow: "hidden",
      }}
    >
      {/* ═══ BACKDROP LAYERS ═══ */}

      {/* Colossal "غسق" watermark — Amiri, ultra-faint, anchors the frame */}
      <div
        className="font-luxury"
        style={{
          position: "absolute",
          top: "50%",
          left: "50%",
          transform: "translate(-50%, -50%)",
          fontSize: "clamp(280px, 42vw, 540px)",
          color: G,
          opacity: 0.05,
          letterSpacing: "-0.08em",
          lineHeight: 0.85,
          pointerEvents: "none",
          zIndex: 0,
          animation: "cta-watermark-pulse 8s ease-in-out infinite",
          userSelect: "none",
        }}
      >
        غسق
      </div>

      {/* Massive radial bloom behind everything */}
      <div
        style={{
          position: "absolute",
          top: "50%",
          left: "50%",
          width: "120%",
          height: "120%",
          transform: "translate(-50%, -50%)",
          background: `radial-gradient(ellipse at center, ${G}33 0%, ${G}12 28%, transparent 60%)`,
          filter: "blur(50px)",
          animation: "cta-halo-bloom 1.6s 0.2s cubic-bezier(.2,.7,.3,1) both, halo-breathe 6s 2s ease-in-out infinite",
          opacity: 0,
          pointerEvents: "none",
          zIndex: 1,
        }}
      />

      {/* Slow-rotating conic gold ring around the phone area */}
      <div
        style={{
          position: "absolute",
          top: "50%",
          left: "calc(50% - 200px)",
          width: 540,
          height: 540,
          marginLeft: -270,
          marginTop: -270,
          borderRadius: "50%",
          background: `conic-gradient(from 0deg, ${G}00, ${G}66, ${G}00, ${GL}66, ${G}00, ${G}55, ${G}00)`,
          opacity: 0,
          animation:
            "cta-rotor-fade 1.4s 0.6s ease-out forwards, " +
            "spin-slow 24s 0.6s linear infinite",
          pointerEvents: "none",
          zIndex: 1,
          filter: "blur(30px)",
        }}
      />

      {/* ═══ MAIN CONTENT ═══ */}

      <div
        style={{
          display: "flex",
          alignItems: "center",
          gap: 70,
          position: "relative",
          zIndex: 5,
        }}
      >
        {/* ─── LEFT: Live phone showing PrayerHeroCard ─── */}
        <div style={{ position: "relative" }}>
          {/* Pulse echo rings emanating from the phone */}
          {[0, 1.2, 2.4].map((d, i) => (
            <div
              key={i}
              style={{
                position: "absolute",
                top: "50%",
                left: "50%",
                width: 320,
                height: 320,
                marginLeft: -160,
                marginTop: -160,
                borderRadius: "50%",
                border: `1px solid ${G}50`,
                opacity: 0,
                animation: `cta-phone-echo 3.6s ${1.2 + d}s ease-out infinite`,
                pointerEvents: "none",
                zIndex: -1,
              }}
            />
          ))}
          <Phone>
            <PrayerHeroCard />
          </Phone>
        </div>

        {/* ─── RIGHT: Brand + tagline + buttons ─── */}
        <div
          style={{
            display: "flex",
            flexDirection: "column",
            gap: 18,
            maxWidth: 360,
            direction: "rtl",
          }}
        >
          {/* Logo + small "official app" pill */}
          <div
            style={{
              display: "flex",
              alignItems: "center",
              gap: 14,
              animation: "cta-logo-bounce 1s 0.3s cubic-bezier(.16,1.3,.3,1) both",
              opacity: 0,
            }}
          >
            <div
              style={{
                width: 64,
                height: 64,
                borderRadius: 18,
                overflow: "hidden",
                border: `2px solid ${G}`,
                boxShadow: `0 0 32px ${G}80, 0 0 64px ${G}40, inset 0 0 12px ${GL}30`,
              }}
            >
              <img
                src={IMG.logo}
                alt=""
                style={{ width: "100%", height: "100%", objectFit: "cover" }}
              />
            </div>
            <div
              className="font-light"
              style={{
                padding: "5px 12px",
                borderRadius: 999,
                background: `${G}12`,
                border: `1px solid ${G}40`,
                color: GL,
                fontSize: 10,
                letterSpacing: 3,
                fontWeight: 500,
              }}
            >
              التطبيق الرسمي
            </div>
          </div>

          {/* Brand wordmark — luxury Amiri (matches Hook scene) */}
          <h1
            className="font-luxury"
            style={{
              fontSize: "clamp(72px, 10vw, 120px)",
              background: `linear-gradient(180deg, ${GL} 0%, #fff8d9 38%, ${G} 70%, ${GD} 100%)`,
              backgroundSize: "200% 200%",
              WebkitBackgroundClip: "text",
              WebkitTextFillColor: "transparent",
              backgroundClip: "text",
              animation:
                "letter-cascade 1s 0.7s cubic-bezier(.16,1,.3,1) both, " +
                "gradient-shift 5s 1.7s ease-in-out infinite",
              lineHeight: 0.95,
              letterSpacing: "-0.04em",
              margin: 0,
              textShadow: `0 2px 0 rgba(0,0,0,0.25)`,
            }}
          >
            غسق
          </h1>

          {/* Divider with diamond */}
          <div
            style={{
              display: "flex",
              alignItems: "center",
              gap: 10,
              marginBottom: 4,
              opacity: 0,
              animation: "fade-in 0.7s 1s cubic-bezier(.2,.7,.3,1) both",
            }}
          >
            <div
              style={{
                width: 40,
                height: 1,
                background: `linear-gradient(to right, transparent, ${G})`,
              }}
            />
            <div
              style={{
                width: 6,
                height: 6,
                background: GL,
                transform: "rotate(45deg)",
                boxShadow: `0 0 8px ${GL}`,
              }}
            />
            <div
              style={{
                width: 40,
                height: 1,
                background: `linear-gradient(to left, transparent, ${G})`,
              }}
            />
          </div>

          {/* Tagline */}
          <div
            className="font-headline"
            style={{
              color: "#dce5f0",
              fontSize: 18,
              fontWeight: 500,
              animation:
                "tagline-rise-cta 0.9s 1.2s cubic-bezier(.2,.7,.3,1) both",
              opacity: 0,
              letterSpacing: "0.02em",
              lineHeight: 1.5,
              textShadow: `0 0 20px ${G}40`,
            }}
          >
            رفيقك من الفجر إلى الغسق
          </div>

          {/* Download buttons */}
          <div
            style={{
              display: "flex",
              gap: 12,
              marginTop: 8,
            }}
          >
            <DownloadButton
              delay={1.6}
              icon={
                <svg width="22" height="22" viewBox="0 0 24 24" fill="#fff">
                  <path d="M17.05 20.28c-.98.95-2.05.8-3.08.35-1.09-.46-2.09-.48-3.24 0-1.44.62-2.2.44-3.06-.35C2.79 15.25 3.51 7.59 9.05 7.31c1.35.07 2.29.74 3.08.8 1.18-.24 2.31-.93 3.57-.84 1.51.12 2.65.72 3.4 1.8-3.12 1.87-2.38 5.98.48 7.13-.57 1.5-1.31 2.99-2.54 4.09zM12.03 7.25c-.15-2.23 1.66-4.07 3.74-4.25.29 2.58-2.34 4.5-3.74 4.25z" />
                </svg>
              }
              smallText="Download on the"
              bigText="App Store"
            />
            <DownloadButton
              delay={1.75}
              icon={
                <svg width="22" height="22" viewBox="0 0 24 24">
                  <path d="M3.6 2.65 14 12 3.6 21.35a1.5 1.5 0 0 1-.6-1.2V3.85c0-.5.24-.94.6-1.2z" fill="#00A4FF" />
                  <path d="M14 12 3.6 2.65A1.5 1.5 0 0 1 4.5 2.5l13.4 7.5L14 12z" fill="#00C46B" />
                  <path d="M14 12 3.6 21.35a1.5 1.5 0 0 0 .9.15L17.9 14 14 12z" fill="#FF3D44" />
                  <path d="M17.9 10 14 12l3.9 2 4.1-2.3a1.4 1.4 0 0 0 0-2.4L17.9 10z" fill="#FFC400" />
                </svg>
              }
              smallText="GET IT ON"
              bigText="Google Play"
            />
          </div>

          {/* Sadaqah footer */}
          <div
            style={{
              marginTop: 14,
              display: "flex",
              alignItems: "center",
              gap: 12,
              animation: "fade-up 0.7s 2.2s both",
              opacity: 0,
            }}
          >
            <div style={{ width: 22, height: 1, background: `${G}50` }} />
            <div
              className="font-headline"
              style={{
                color: "#7a8599",
                fontSize: 12,
                letterSpacing: 1,
                fontWeight: 500,
              }}
            >
              صدقة جارية لمن طوّره وساهم به
            </div>
            <div style={{ width: 22, height: 1, background: `${G}50` }} />
          </div>
        </div>
      </div>
    </div>
  );
}

function DownloadButton({ icon, smallText, bigText, delay }) {
  return (
    <div
      style={{
        display: "flex",
        alignItems: "center",
        gap: 9,
        padding: "11px 18px",
        background: "#000",
        borderRadius: 13,
        border: `1px solid ${G}30`,
        cursor: "pointer",
        boxShadow: `0 12px 28px rgba(0,0,0,0.5), inset 0 1px 0 rgba(255,255,255,0.06)`,
        animation: `cta-button-rise 0.7s ${delay}s cubic-bezier(.16,1.2,.3,1) both`,
        opacity: 0,
      }}
    >
      {icon}
      <div style={{ textAlign: "left", direction: "ltr" }}>
        <div
          style={{
            color: "#aaa",
            fontSize: 9,
            fontFamily: "system-ui",
            lineHeight: 1,
          }}
        >
          {smallText}
        </div>
        <div
          style={{
            color: "#fff",
            fontSize: 13,
            fontFamily: "system-ui",
            fontWeight: 600,
            lineHeight: 1.2,
          }}
        >
          {bigText}
        </div>
      </div>
    </div>
  );
}
