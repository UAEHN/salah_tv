import { useEffect, useState } from "react";
import { G, GL, NAVY, NAVY_L } from "../../constants/colors";

/**
 * PrayerHeroCard — Live animated prayer countdown.
 *
 * Reproduces the app's signature mobile_hero_card:
 *   - Floating gold/sunset orbs in background
 *   - Hijri date row at top
 *   - Big circular arc countdown (the signature visual)
 *   - Next prayer name + live ticking timer inside the arc
 *   - 5 prayer rows below with the next one highlighted
 *
 * The countdown is REAL — it ticks every second.
 */

const PRAYERS = [
  { name: "الفجر",   time: "04:42", passed: true },
  { name: "الظهر",   time: "12:17", passed: true },
  { name: "العصر",   time: "15:34", passed: true },
  { name: "المغرب",  time: "18:23", next: true },
  { name: "العشاء",  time: "19:51", passed: false },
];

export default function PrayerHeroCard() {
  // Countdown starts at 23m 45s, ticks down live
  const [seconds, setSeconds] = useState(23 * 60 + 45);
  useEffect(() => {
    const id = setInterval(() => setSeconds((s) => Math.max(0, s - 1)), 1000);
    return () => clearInterval(id);
  }, []);

  const h = String(Math.floor(seconds / 3600)).padStart(2, "0");
  const m = String(Math.floor((seconds % 3600) / 60)).padStart(2, "0");
  const s = String(seconds % 60).padStart(2, "0");

  return (
    <div
      style={{
        width: "100%",
        height: "100%",
        position: "relative",
        background: `linear-gradient(180deg, #0e1530 0%, #0a1228 45%, #050a18 100%)`,
        overflow: "hidden",
        direction: "rtl",
        paddingTop: 40,
      }}
    >
      {/* Floating background orbs (signature) */}
      <Orb top={-30} right={-40} size={180} color={`${G}40`} animA />
      <Orb bottom={120} left={-40} size={140} color="rgba(230, 126, 34, 0.28)" animB />

      {/* Top mini bar — Hijri date */}
      <div style={{ position: "relative", textAlign: "center", zIndex: 2 }}>
        <div
          className="font-body"
          style={{ color: "#a0adc0", fontSize: 10, letterSpacing: 1.2 }}
        >
          السبت  ·  15 ذو القعدة 1447
        </div>
      </div>

      {/* Big circular countdown */}
      <div
        style={{
          position: "relative",
          width: 200,
          height: 200,
          margin: "20px auto 0",
        }}
      >
        <svg width="200" height="200" viewBox="0 0 200 200">
          <defs>
            <linearGradient id="arcGrad" x1="0" y1="0" x2="1" y2="1">
              <stop offset="0%" stopColor={GL} />
              <stop offset="60%" stopColor={G} />
              <stop offset="100%" stopColor="#e67e22" />
            </linearGradient>
          </defs>
          {/* Background ring */}
          <circle cx="100" cy="100" r="90" fill="none"
            stroke={`${G}25`} strokeWidth="3" />
          {/* Animated progress arc */}
          <circle cx="100" cy="100" r="90" fill="none"
            stroke="url(#arcGrad)" strokeWidth="5" strokeLinecap="round"
            strokeDasharray="565"
            transform="rotate(-90 100 100)"
            style={{
              animation: "hero-arc-fill 2.5s 0.6s cubic-bezier(.4,0,.2,1) both",
              filter: `drop-shadow(0 0 6px ${G}80)`,
            }}
          />
        </svg>

        {/* Glowing orbiting tip */}
        <div
          style={{
            position: "absolute",
            top: "50%",
            left: "50%",
            width: 10,
            height: 10,
            marginLeft: -5,
            marginTop: -5,
            borderRadius: "50%",
            background: "#fff8d9",
            boxShadow: `0 0 12px ${GL}, 0 0 24px ${G}`,
            animation: "hero-tip-orbit 2.5s 0.6s cubic-bezier(.4,0,.2,1) both",
          }}
        />

        {/* Center content */}
        <div
          style={{
            position: "absolute",
            inset: 0,
            display: "flex",
            flexDirection: "column",
            alignItems: "center",
            justifyContent: "center",
          }}
        >
          <div
            className="font-display"
            style={{
              color: GL,
              fontSize: 22,
              fontWeight: 700,
              marginBottom: 4,
              textShadow: `0 0 16px ${G}80`,
            }}
          >
            المغرب
          </div>
          <div
            style={{
              color: "#fff",
              fontSize: 28,
              fontWeight: 300,
              fontFamily: "system-ui, sans-serif",
              fontVariantNumeric: "tabular-nums",
              letterSpacing: "-0.03em",
              lineHeight: 1,
            }}
          >
            {h}:{m}:{s}
          </div>
          <div
            className="font-body"
            style={{ color: "#7a8599", fontSize: 10, marginTop: 6, letterSpacing: 2 }}
          >
            متبقي
          </div>
        </div>
      </div>

      {/* Prayer rows */}
      <div style={{ marginTop: 24, padding: "0 14px" }}>
        {PRAYERS.map((p, i) => (
          <div
            key={p.name}
            style={{
              display: "flex",
              justifyContent: "space-between",
              alignItems: "center",
              padding: "7px 12px",
              marginBottom: 4,
              borderRadius: 10,
              background: p.next
                ? `linear-gradient(90deg, ${G}25, ${G}08)`
                : "transparent",
              border: p.next ? `1px solid ${G}40` : "1px solid transparent",
              opacity: 0,
              animation: `prayer-row-stagger 0.5s ${1.4 + i * 0.08}s cubic-bezier(.2,.7,.3,1) both`,
            }}
          >
            <span
              className="font-body"
              style={{
                color: p.next ? GL : p.passed ? "#5a6680" : "#a0adc0",
                fontSize: 12,
                fontWeight: p.next ? 700 : 500,
              }}
            >
              {p.name}
            </span>
            <span
              style={{
                color: p.next ? "#fff" : p.passed ? "#5a6680" : "#a0adc0",
                fontSize: 12,
                fontFamily: "system-ui",
                fontVariantNumeric: "tabular-nums",
                fontWeight: p.next ? 600 : 400,
              }}
            >
              {p.time}
            </span>
          </div>
        ))}
      </div>
    </div>
  );
}

function Orb({ top, right, bottom, left, size, color, animA, animB }) {
  return (
    <div
      style={{
        position: "absolute",
        top, right, bottom, left,
        width: size,
        height: size,
        borderRadius: "50%",
        background: `radial-gradient(circle, ${color} 0%, transparent 70%)`,
        filter: "blur(20px)",
        animation: `${animA ? "orb-float-a" : "orb-float-b"} ${animA ? 7 : 9}s ease-in-out infinite`,
        pointerEvents: "none",
      }}
    />
  );
}
