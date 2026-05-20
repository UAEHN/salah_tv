import { useEffect, useState } from "react";
import { G, GL } from "../../constants/colors";

/**
 * QiblaCompass — Live qibla finder, fully synchronized with phone tilt.
 *
 * Choreography (matches Phone's `motion="qibla"` keyframe):
 *   1. Phone enters tilted -22° on Z (user holding it casually).
 *   2. As phone slowly settles (rotateZ → 0), the bearing display
 *      counts down from 312° → 287° (the real qibla direction).
 *   3. Needle rotates in real time, locked to absolute Mecca.
 *   4. The instant phone reaches 0° AND bearing reaches 287°,
 *      a gold lock-flash bursts and the label switches to
 *      "محاذٍ القبلة" — the "you found it" beat.
 *
 * Both bearing and needle are driven from a single React state
 * (driven by requestAnimationFrame) so they never drift apart.
 */
export default function QiblaCompass() {
  const QIBLA = 287;
  const START = 312;

  const [bearing, setBearing] = useState(START);
  const [locked, setLocked] = useState(false);

  useEffect(() => {
    const startTime = performance.now();
    const delay = 1100;     // wait for phone to enter
    const duration = 2300;  // matches the Z-axis settle of phone-qibla-search
    let cancel = false;

    const tick = (now) => {
      if (cancel) return;
      const elapsed = now - startTime - delay;
      if (elapsed < 0) {
        requestAnimationFrame(tick);
        return;
      }
      const progress = Math.min(1, elapsed / duration);
      const eased = 1 - Math.pow(1 - progress, 3); // ease-out-cubic
      setBearing(START + (QIBLA - START) * eased);
      if (progress >= 1) {
        setLocked(true);
      } else {
        requestAnimationFrame(tick);
      }
    };
    requestAnimationFrame(tick);

    return () => { cancel = true; };
  }, []);

  const displayBearing = Math.round(bearing);

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
      {/* Header — switches text on lock */}
      <div
        className="font-body"
        style={{
          color: locked ? GL : "#a0adc0",
          fontSize: 11,
          letterSpacing: 1.5,
          transition: "color 0.4s ease",
        }}
      >
        {locked ? "محاذٍ القبلة" : "ابحث عن القبلة"}
      </div>

      {/* Bearing display — live ticking */}
      <div
        style={{
          marginTop: 8,
          display: "flex",
          alignItems: "baseline",
          gap: 4,
          direction: "ltr",
          transition: "filter 0.4s ease",
          filter: locked ? `drop-shadow(0 0 18px ${GL})` : "none",
        }}
      >
        <span
          style={{
            color: locked ? "#fff8d9" : GL,
            fontSize: 32,
            fontWeight: 600,
            fontFamily: "system-ui",
            fontVariantNumeric: "tabular-nums",
            textShadow: `0 0 18px ${G}80`,
            transition: "color 0.4s ease",
          }}
        >
          {displayBearing}
        </span>
        <span style={{ color: G, fontSize: 16, fontWeight: 500 }}>°</span>
      </div>

      {/* Compass body */}
      <div
        style={{
          position: "relative",
          width: 200,
          height: 200,
          marginTop: 18,
        }}
      >
        {/* Pulse rings — only after lock */}
        {locked &&
          [0, 0.5, 1].map((delay, i) => (
            <div
              key={i}
              style={{
                position: "absolute",
                inset: 18,
                borderRadius: "50%",
                border: `1px solid ${GL}80`,
                animation: `compass-pulse-ring 2.4s ${delay}s ease-out infinite`,
              }}
            />
          ))}

        {/* Outer rotating ring with cardinal marks */}
        <svg
          viewBox="0 0 200 200"
          style={{
            position: "absolute",
            inset: 0,
            animation: "compass-ring-rotate 60s linear infinite",
          }}
        >
          <circle cx="100" cy="100" r="92" fill="none" stroke={`${G}30`} strokeWidth="1" />
          <circle cx="100" cy="100" r="80" fill="none" stroke={`${G}20`} strokeWidth="1" />
          {Array.from({ length: 24 }).map((_, i) => {
            const isMajor = i % 6 === 0;
            return (
              <line
                key={i}
                x1="100" y1="8"
                x2="100" y2={isMajor ? 18 : 14}
                stroke={isMajor ? GL : `${G}80`}
                strokeWidth={isMajor ? 1.5 : 0.8}
                transform={`rotate(${i * 15} 100 100)`}
              />
            );
          })}
        </svg>

        {/* Cardinal letters */}
        {[
          { l: "ش", deg: 0 },
          { l: "ق", deg: 90 },
          { l: "ج", deg: 180 },
          { l: "غ", deg: 270 },
        ].map((c) => {
          const rad = (c.deg - 90) * (Math.PI / 180);
          return (
            <div
              key={c.l}
              className="font-body-bold"
              style={{
                position: "absolute",
                top: `calc(50% + ${Math.sin(rad) * 78}px)`,
                left: `calc(50% + ${Math.cos(rad) * 78}px)`,
                transform: "translate(-50%, -50%)",
                color: c.deg === 0 ? GL : "#7a8599",
                fontSize: 12,
                fontWeight: 700,
                textShadow: c.deg === 0 ? `0 0 10px ${G}` : "none",
              }}
            >
              {c.l}
            </div>
          );
        })}

        {/* Live needle — rotation tied directly to bearing state */}
        <div
          style={{
            position: "absolute",
            inset: 0,
            transform: `rotate(${bearing}deg)`,
            transformOrigin: "center",
            transition: "none",
          }}
        >
          {/* Needle line */}
          <div
            style={{
              position: "absolute",
              top: 26,
              left: "50%",
              width: 2,
              height: 74,
              marginLeft: -1,
              background: `linear-gradient(to bottom, transparent, ${G}, ${GL})`,
              boxShadow: `0 0 8px ${G}`,
            }}
          />
          {/* Kaaba pointer at needle tip */}
          <div
            style={{
              position: "absolute",
              top: 6,
              left: "50%",
              transform: "translateX(-50%)",
              width: 28,
              height: 28,
              filter: locked
                ? `drop-shadow(0 0 16px ${GL}) drop-shadow(0 0 32px ${G})`
                : `drop-shadow(0 0 10px ${GL}) drop-shadow(0 0 20px ${G})`,
              transition: "filter 0.4s ease",
            }}
          >
            <svg viewBox="0 0 24 24" width="28" height="28">
              <rect x="3" y="6" width="18" height="15" fill="#0a0a0a"
                stroke={GL} strokeWidth="0.4" rx="0.5" />
              <rect x="3" y="6" width="18" height="1.2" fill={GL} rx="0.5" />
              <rect x="3" y="9.5" width="18" height="2.4"
                fill="url(#kaabaBand)" />
              <rect x="14.5" y="12" width="4" height="7"
                fill={G} stroke={GL} strokeWidth="0.3" />
              <circle cx="17.5" cy="15.5" r="0.3" fill="#fff8d9" />
              <defs>
                <linearGradient id="kaabaBand" x1="0" y1="0" x2="0" y2="1">
                  <stop offset="0%" stopColor={GL} />
                  <stop offset="50%" stopColor="#fff8d9" />
                  <stop offset="100%" stopColor={G} />
                </linearGradient>
              </defs>
            </svg>
          </div>
          {/* Tail counter-balance */}
          <div
            style={{
              position: "absolute",
              bottom: 26,
              left: "50%",
              width: 2,
              height: 30,
              marginLeft: -1,
              background: `linear-gradient(to top, transparent, ${G}40)`,
            }}
          />
        </div>

        {/* Center hub */}
        <div
          style={{
            position: "absolute",
            top: "50%",
            left: "50%",
            width: 14,
            height: 14,
            marginLeft: -7,
            marginTop: -7,
            borderRadius: "50%",
            background: `radial-gradient(circle, ${GL} 0%, ${G} 100%)`,
            boxShadow: `0 0 12px ${G}`,
            border: "1.5px solid #fff8d9",
            zIndex: 2,
          }}
        />

        {/* Lock flash — bursts the moment alignment is achieved */}
        {locked && (
          <>
            <div
              style={{
                position: "absolute",
                top: "50%",
                left: "50%",
                width: 200,
                height: 200,
                marginLeft: -100,
                marginTop: -100,
                borderRadius: "50%",
                background: `radial-gradient(circle, ${GL}cc 0%, ${G}55 30%, transparent 65%)`,
                filter: "blur(4px)",
                animation: "qibla-lock-flash 0.9s cubic-bezier(.2,.7,.3,1) both",
                pointerEvents: "none",
              }}
            />
            <div
              style={{
                position: "absolute",
                inset: 18,
                borderRadius: "50%",
                border: `2px solid ${GL}`,
                animation: "qibla-lock-ring 1s ease-out both",
                pointerEvents: "none",
              }}
            />
          </>
        )}
      </div>

      {/* Footer info — distance to Kaaba */}
      <div
        style={{
          marginTop: 18,
          display: "flex",
          alignItems: "center",
          gap: 8,
          padding: "5px 12px",
          borderRadius: 999,
          border: `1px solid ${G}40`,
          background: `${G}10`,
          opacity: 0,
          animation: "degree-count 0.6s 2.4s cubic-bezier(.2,.7,.3,1) both",
        }}
      >
        <div
          style={{
            width: 5, height: 5, borderRadius: "50%", background: GL,
            boxShadow: `0 0 6px ${GL}`,
          }}
        />
        <span className="font-body" style={{ color: GL, fontSize: 10, letterSpacing: 1 }}>
          الكعبة · 1,247 كم
        </span>
      </div>
    </div>
  );
}
