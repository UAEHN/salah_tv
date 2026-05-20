import "./verse/animations.css";

import { G, GL } from "../constants/colors";
import Arabesque from "../components/ornaments/Arabesque";
import { T } from "./verse/timing";
import SpotlightBackdrop from "./verse/SpotlightBackdrop";
import KeyWord from "./verse/KeyWord";

const WORDS = [
  { t: "أَقِمِ",        d: T.w1 },
  { t: "الصَّلَاةَ",     d: T.w2 },
  { t: "لِدُلُوكِ",      d: T.w3 },
  { t: "الشَّمْسِ",      d: T.w4 },
  { t: "إِلَىٰ",         d: T.w5 },
  { t: "غَسَقِ",         d: T.keyWordStart, key: true },
  { t: "اللَّيْلِ",      d: T.w7 },
];

/**
 * SceneVerse — Cinematic verse moment.
 * Word-by-word reveal with a dramatic climax on "غَسَقِ"
 * (which IS the brand name — earning the entire ad's premise).
 */
export default function SceneVerse() {
  return (
    <div
      style={{
        position: "relative",
        width: "100%",
        height: "100%",
        display: "flex",
        flexDirection: "column",
        alignItems: "center",
        justifyContent: "center",
        gap: 22,
        padding: "0 40px",
        direction: "rtl",
        overflow: "hidden",
      }}
    >
      <SpotlightBackdrop />

      {/* Top ornament */}
      <div
        style={{
          animation: `ornament-draw 0.9s ${T.ornamentTop}s cubic-bezier(.2,.7,.3,1) both`,
          opacity: 0,
          transformOrigin: "center",
          zIndex: 5,
        }}
      >
        <Arabesque width={260} />
      </div>

      {/* Verse reference chip */}
      <div
        style={{
          display: "inline-flex",
          alignItems: "center",
          gap: 12,
          padding: "6px 16px",
          borderRadius: 999,
          border: `1px solid ${G}55`,
          background: "rgba(212,168,67,0.06)",
          boxShadow: `0 0 24px ${G}22 inset`,
          animation: `chip-pop 0.7s ${T.chipStart}s cubic-bezier(.2,.7,.3,1) both`,
          opacity: 0,
          zIndex: 5,
        }}
      >
        <span style={{ width: 6, height: 6, borderRadius: "50%", background: GL, boxShadow: `0 0 8px ${GL}` }} />
        <span
          className="font-mono"
          style={{ color: G, fontSize: 11, letterSpacing: 4, fontWeight: 500 }}
        >
          القرآن الكريم · الإسراء 17 : 78
        </span>
        <span style={{ width: 6, height: 6, borderRadius: "50%", background: GL, boxShadow: `0 0 8px ${GL}` }} />
      </div>

      {/* The verse — word by word */}
      <div
        className="font-quran"
        style={{
          display: "flex",
          flexWrap: "wrap",
          alignItems: "center",
          justifyContent: "center",
          gap: "0.35em",
          fontSize: "clamp(26px, 4.6vw, 42px)",
          color: "#e8eef5",
          lineHeight: 2,
          fontWeight: 400,
          maxWidth: 900,
          zIndex: 5,
        }}
      >
        <span style={{ color: G, opacity: 0.6, fontSize: "0.85em" }}>﴿</span>
        {WORDS.map((w, i) =>
          w.key ? (
            <KeyWord key={i} text={w.t} />
          ) : (
            <span
              key={i}
              style={{
                display: "inline-block",
                opacity: 0,
                animation: `word-fade-up 0.65s ${w.d}s cubic-bezier(.2,.7,.3,1) both`,
              }}
            >
              {w.t}
            </span>
          )
        )}
        <span style={{ color: G, opacity: 0.6, fontSize: "0.85em" }}>﴾</span>
      </div>

      {/* Bottom ornament */}
      <div
        style={{
          animation: `ornament-draw 0.9s ${T.ornamentBottom}s cubic-bezier(.2,.7,.3,1) both`,
          opacity: 0,
          transformOrigin: "center",
          zIndex: 5,
        }}
      >
        <Arabesque width={260} />
      </div>

      {/* Surah name */}
      <div
        className="font-headline"
        style={{
          color: "#7a8599",
          fontSize: 13,
          letterSpacing: "0.18em",
          animation: `chip-pop 0.7s ${T.surahName}s cubic-bezier(.2,.7,.3,1) both`,
          opacity: 0,
          zIndex: 5,
        }}
      >
        سُورَةُ الإِسْرَاء
      </div>

      {/* Tagline — final beat */}
      <div
        className="font-display"
        style={{
          color: GL,
          fontSize: "clamp(17px, 2.2vw, 21px)",
          fontWeight: 600,
          marginTop: 4,
          animation: `tagline-rise-soft 1s ${T.tagline}s cubic-bezier(.2,.7,.3,1) both`,
          opacity: 0,
          textShadow: `0 0 20px ${G}55`,
          zIndex: 5,
        }}
      >
        من الفجر إلى الغسق · رفيقك في كل صلاة
      </div>
    </div>
  );
}
