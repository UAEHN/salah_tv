import { useState, useEffect } from "react";
import "./styles/animations.css";

import { G, GL, NAVY, BG } from "./constants/colors";
import { SCENE_TIMELINE, FEATURES } from "./constants/scenes";

// Background layers
import PatternLayer from "./components/PatternLayer";
import MeshGradient from "./components/MeshGradient";
import StarDots from "./components/StarDots";

// Scenes
import SceneHook from "./scenes/SceneHook";
import SceneVerse from "./scenes/SceneVerse";
import SceneProblem from "./scenes/SceneProblem";
import ScenePhone from "./scenes/ScenePhone";
import SceneNotification from "./scenes/SceneNotification";
import SceneStats from "./scenes/SceneStats";
import SceneCTA from "./scenes/SceneCTA";

// Live UI components rendered inside the phone frame
import PrayerHeroCard from "./scenes/features/PrayerHeroCard";
import QiblaCompass from "./scenes/features/QiblaCompass";
import DhikrCounter from "./scenes/features/DhikrCounter";

const TRANSITION_MS = 600;

export default function App() {
  const [idx, setIdx] = useState(0);
  const [fading, setFading] = useState(false);
  const [veilKey, setVeilKey] = useState(0); // forces veil re-animation

  // Auto-advance through scenes on a timer
  useEffect(() => {
    const t = setTimeout(() => {
      setFading(true);
      setVeilKey((k) => k + 1);
      const t2 = setTimeout(() => {
        setIdx((i) => (i + 1) % SCENE_TIMELINE.length);
        setFading(false);
      }, TRANSITION_MS);
      return () => clearTimeout(t2);
    }, SCENE_TIMELINE[idx].dur);
    return () => clearTimeout(t);
  }, [idx]);

  const sceneId = SCENE_TIMELINE[idx].id;

  const jumpTo = (i) => {
    setFading(true);
    setVeilKey((k) => k + 1);
    setTimeout(() => {
      setIdx(i);
      setFading(false);
    }, TRANSITION_MS / 2);
  };

  // Scene progress (0 → 1) used for the slim top bar
  const sceneProgress = (idx + 1) / SCENE_TIMELINE.length;

  return (
    <div
      style={{
        width: "100vw",
        height: "100vh",
        background: `radial-gradient(ellipse at 50% 50%, ${NAVY} 0%, ${BG} 70%)`,
        display: "flex",
        alignItems: "center",
        justifyContent: "center",
        overflow: "hidden",
        position: "relative",
        fontFamily: "Tajawal, sans-serif",
      }}
    >
      {/* Background layers (always present) */}
      <PatternLayer />
      <MeshGradient />
      <StarDots />

      {/* Vignette */}
      <div
        style={{
          position: "absolute",
          inset: 0,
          background:
            "radial-gradient(ellipse, transparent 40%, rgba(0,0,0,0.6) 100%)",
          pointerEvents: "none",
          zIndex: 1,
        }}
      />

      {/* Scene content — depth zoom + opacity */}
      <div
        style={{
          opacity: fading ? 0 : 1,
          transform: fading ? "scale(1.06)" : "scale(1)",
          filter: fading ? "blur(8px)" : "blur(0)",
          transition: `opacity ${TRANSITION_MS}ms cubic-bezier(.4,0,.2,1), transform ${TRANSITION_MS}ms cubic-bezier(.4,0,.2,1), filter ${TRANSITION_MS}ms ease`,
          zIndex: 10,
          padding: "0 24px",
          width: "100%",
          height: "100%",
          display: "flex",
          alignItems: "center",
          justifyContent: "center",
        }}
      >
        {sceneId === "hook"    && <SceneHook />}
        {sceneId === "verse"   && <SceneVerse />}
        {sceneId === "problem" && <SceneProblem />}
        {sceneId === "prayer"  && <ScenePhone {...FEATURES.prayer} screen={<PrayerHeroCard />} />}
        {sceneId === "qibla"   && <ScenePhone {...FEATURES.qibla}  screen={<QiblaCompass />} motion="qibla" />}
        {sceneId === "athkar"  && <ScenePhone {...FEATURES.athkar} screen={<DhikrCounter />} />}
        {sceneId === "notif"   && <SceneNotification />}
        {sceneId === "stats"   && <SceneStats />}
        {sceneId === "cta"     && <SceneCTA />}
      </div>

      {/* Golden veil that sweeps across during transition */}
      <div
        key={veilKey}
        style={{
          position: "absolute",
          inset: 0,
          background: `linear-gradient(115deg,
            transparent 0%,
            transparent 30%,
            rgba(245,210,122,0.25) 48%,
            rgba(212,168,67,0.4) 50%,
            rgba(245,210,122,0.25) 52%,
            transparent 70%,
            transparent 100%)`,
          transform: "translateX(-100%)",
          animation: fading
            ? `scene-veil-sweep ${TRANSITION_MS}ms cubic-bezier(.4,0,.2,1) both`
            : "none",
          pointerEvents: "none",
          zIndex: 25,
          mixBlendMode: "screen",
        }}
      />

      {/* Slim top progress bar */}
      <div
        style={{
          position: "absolute",
          top: 0,
          left: 0,
          right: 0,
          height: 2,
          background: "rgba(212,168,67,0.08)",
          zIndex: 30,
          pointerEvents: "none",
        }}
      >
        <div
          style={{
            height: "100%",
            width: `${sceneProgress * 100}%`,
            background: `linear-gradient(to right, ${G}, ${GL}, ${G})`,
            boxShadow: `0 0 8px ${G}`,
            transition: "width 0.6s cubic-bezier(.2,.7,.3,1)",
          }}
        />
      </div>

      {/* Progress dots */}
      <div
        style={{
          position: "absolute",
          bottom: 24,
          left: "50%",
          transform: "translateX(-50%)",
          display: "flex",
          gap: 5,
          zIndex: 30,
        }}
      >
        {SCENE_TIMELINE.map((_, i) => (
          <div
            key={i}
            onClick={() => jumpTo(i)}
            style={{
              width: i === idx ? 24 : 5,
              height: 5,
              borderRadius: 3,
              cursor: "pointer",
              background: i === idx ? G : "rgba(212,168,67,0.25)",
              transition: "all 0.4s cubic-bezier(.16,1,.3,1)",
            }}
          />
        ))}
      </div>

      {/* Scene counter (top-right) */}
      <div
        className="font-mono"
        style={{
          position: "absolute",
          top: 18,
          right: 24,
          zIndex: 30,
          color: "#3a4860",
          fontSize: 9,
          letterSpacing: 3,
          fontWeight: 500,
          opacity: 0.5,
        }}
      >
        GHASAQ · {String(idx + 1).padStart(2, "0")} /{" "}
        {String(SCENE_TIMELINE.length).padStart(2, "0")}
      </div>
    </div>
  );
}
