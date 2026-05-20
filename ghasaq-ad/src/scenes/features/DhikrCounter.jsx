import { useEffect, useState } from "react";
import { G, GL } from "../../constants/colors";

/**
 * DhikrCounter — Live circular counter (simulates user tapping).
 *
 * Reproduces the app's adhkar/tasbih reader visual:
 *   - Dhikr text at top (سُبْحَانَ اللَّهِ)
 *   - Big circular counter that "ticks" every ~1s as if tapped
 *   - Progress arc fills as count rises
 *   - Soft golden ripple on each tap
 *   - Category chip + total target shown below
 *
 * Auto-counts from 0 → 33 over the scene duration (5.5s).
 */
export default function DhikrCounter() {
  const TARGET = 33;
  const [count, setCount] = useState(0);
  const [pulseKey, setPulseKey] = useState(0);
  const [done, setDone] = useState(false);

  useEffect(() => {
    let cancel = false;
    const tick = () => {
      if (cancel) return;
      setCount((c) => {
        if (c >= TARGET) {
          setDone(true);
          return c;
        }
        setPulseKey((k) => k + 1);
        return c + 1;
      });
    };
    const id = setInterval(tick, 130);
    return () => { cancel = true; clearInterval(id); };
  }, []);

  const progress = count / TARGET;
  const dashOffset = 314 * (1 - progress);

  // 16 sparkles flying outward when complete
  const SPARKS = Array.from({ length: 16 }, (_, i) => {
    const angle = (i / 16) * Math.PI * 2;
    const dist = 90 + (i % 3) * 20;
    return {
      id: i,
      sx: Math.cos(angle) * dist + "px",
      sy: Math.sin(angle) * dist + "px",
      delay: (i % 5) * 0.04,
    };
  });

  return (
    <div
      style={{
        width: "100%",
        height: "100%",
        position: "relative",
        background: `linear-gradient(180deg, #0e1530 0%, #0a1228 50%, #050a18 100%)`,
        overflow: "hidden",
        direction: "rtl",
        paddingTop: 36,
        display: "flex",
        flexDirection: "column",
        alignItems: "center",
      }}
    >
      {/* Category pill */}
      <div
        style={{
          padding: "5px 14px",
          borderRadius: 999,
          background: `${G}15`,
          border: `1px solid ${G}40`,
        }}
      >
        <span className="font-body" style={{ color: GL, fontSize: 10, letterSpacing: 1.5 }}>
          أذكار الصباح
        </span>
      </div>

      {/* Dhikr text */}
      <div
        className="font-quran"
        style={{
          marginTop: 22,
          color: "#e8eef5",
          fontSize: 22,
          fontWeight: 400,
          letterSpacing: "0.02em",
          textAlign: "center",
          padding: "0 18px",
          lineHeight: 1.5,
          textShadow: `0 0 18px ${G}30`,
        }}
      >
        سُبْحَانَ اللَّهِ
        <br />
        <span style={{ fontSize: 14, color: "#a0adc0", fontWeight: 400 }}>
          وَبِحَمْدِهِ
        </span>
      </div>

      {/* Big circular counter */}
      <div
        style={{
          position: "relative",
          width: 160,
          height: 160,
          marginTop: 26,
        }}
      >
        {/* Ripple on tap */}
        <div
          key={pulseKey}
          style={{
            position: "absolute",
            inset: 0,
            borderRadius: "50%",
            border: `2px solid ${GL}`,
            animation: "ripple-out 0.7s ease-out forwards",
            pointerEvents: "none",
          }}
        />

        <svg width="160" height="160" viewBox="0 0 160 160">
          <defs>
            <linearGradient id="dhikrArc" x1="0" y1="0" x2="1" y2="1">
              <stop offset="0%" stopColor={GL} />
              <stop offset="100%" stopColor={G} />
            </linearGradient>
          </defs>
          {/* Background ring */}
          <circle cx="80" cy="80" r="50" fill="none"
            stroke={`${G}25`} strokeWidth="3" />
          {/* Live progress arc */}
          <circle cx="80" cy="80" r="50" fill="none"
            stroke="url(#dhikrArc)" strokeWidth="5" strokeLinecap="round"
            strokeDasharray="314"
            strokeDashoffset={dashOffset}
            transform="rotate(-90 80 80)"
            style={{
              transition: "stroke-dashoffset 0.25s cubic-bezier(.2,.7,.3,1)",
              filter: `drop-shadow(0 0 6px ${G})`,
            }}
          />
        </svg>

        {/* Inner counter circle (tap target) */}
        <div
          key={`p-${pulseKey}`}
          style={{
            position: "absolute",
            top: "50%",
            left: "50%",
            width: 86,
            height: 86,
            marginLeft: -43,
            marginTop: -43,
            borderRadius: "50%",
            background: done
              ? `radial-gradient(circle, ${G}55 0%, #1a1428 100%)`
              : `radial-gradient(circle, #162244 0%, #0a1228 100%)`,
            border: done ? `2px solid ${GL}` : `1.5px solid ${G}60`,
            display: "flex",
            flexDirection: "column",
            alignItems: "center",
            justifyContent: "center",
            animation: done
              ? "dhikr-complete 0.8s cubic-bezier(.16,1.3,.3,1) both"
              : "counter-tap-pulse 0.7s ease-out, counter-glow-tap 0.7s ease-out",
            boxShadow: done ? `0 0 40px ${GL}, 0 0 80px ${G}80` : "none",
          }}
        >
          <span
            style={{
              color: "#fff",
              fontSize: done ? 26 : 30,
              fontWeight: 600,
              fontFamily: "system-ui",
              fontVariantNumeric: "tabular-nums",
              lineHeight: 1,
              textShadow: `0 0 14px ${G}`,
              transition: "font-size 0.3s",
            }}
          >
            {done ? "✓" : count}
          </span>
          <span style={{ color: done ? GL : "#7a8599", fontSize: 9, marginTop: 2, letterSpacing: 1 }}>
            {done ? "تمّ" : `من ${TARGET}`}
          </span>
        </div>

        {/* Celebration sparks fly outward when complete */}
        {done &&
          SPARKS.map((s) => (
            <div
              key={s.id}
              style={{
                position: "absolute",
                top: "50%",
                left: "50%",
                width: 4,
                height: 4,
                marginLeft: -2,
                marginTop: -2,
                borderRadius: "50%",
                background: "#fff8d9",
                boxShadow: `0 0 8px ${GL}, 0 0 16px ${G}`,
                "--sx": s.sx,
                "--sy": s.sy,
                opacity: 0,
                animation: `dhikr-spark 1.4s ${s.delay}s ease-out both`,
              }}
            />
          ))}

        {/* Celebratory ring */}
        {done && (
          <div
            style={{
              position: "absolute",
              inset: -10,
              borderRadius: "50%",
              border: `2px solid ${GL}`,
              animation: "ripple-out 1.2s ease-out forwards",
              pointerEvents: "none",
            }}
          />
        )}
      </div>

      {/* "Ma sha Allah" praise that appears on completion */}
      {done && (
        <div
          className="font-display"
          style={{
            position: "absolute",
            bottom: 70,
            left: 0,
            right: 0,
            textAlign: "center",
            fontSize: 18,
            color: GL,
            fontWeight: 700,
            letterSpacing: "0.05em",
            animation: "dhikr-praise 0.9s cubic-bezier(.16,1.3,.3,1) both",
            opacity: 0,
            textShadow: `0 0 20px ${G}`,
          }}
        >
          ما شاء الله · تبارك الله
        </div>
      )}

      {/* Mini chips of other dhikrs */}
      <div
        style={{
          marginTop: 22,
          display: "flex",
          gap: 6,
          flexWrap: "wrap",
          justifyContent: "center",
          padding: "0 16px",
        }}
      >
        {["الحمد لله", "الله أكبر", "لا إله إلا الله"].map((d) => (
          <span
            key={d}
            className="font-body"
            style={{
              fontSize: 9,
              padding: "4px 9px",
              borderRadius: 999,
              background: "rgba(212,168,67,0.06)",
              border: `1px solid ${G}25`,
              color: "#a0adc0",
              letterSpacing: 0.3,
            }}
          >
            {d}
          </span>
        ))}
      </div>
    </div>
  );
}
