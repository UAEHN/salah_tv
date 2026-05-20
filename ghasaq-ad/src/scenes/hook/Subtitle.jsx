import { GL } from "../../constants/colors";
import { T } from "./timing";

/**
 * Subtitle — "GHASAQ" Latin transliteration + Arabic tagline.
 * Anchored below the name (which is now centered vertically),
 * keeping the composition balanced without a hard bottom dock.
 */
export default function Subtitle() {
  return (
    <div
      style={{
        position: "absolute",
        top: "calc(50% + 110px)",
        left: 0,
        right: 0,
        textAlign: "center",
        zIndex: 10,
        pointerEvents: "none",
      }}
    >
      {/* Latin transliteration */}
      <div
        className="font-light"
        style={{
          fontSize: 12,
          color: "#a0adc0",
          letterSpacing: "0.8em",
          marginBottom: 14,
          paddingLeft: "0.8em",
          animation: `letter-spread 1.1s ${T.subtitleStart}s ease-out both`,
          opacity: 0,
          fontWeight: 300,
        }}
      >
        GHASAQ
      </div>

      {/* Arabic tagline — the meaning */}
      <div
        className="font-headline"
        style={{
          fontSize: "clamp(14px, 1.7vw, 17px)",
          color: GL,
          animation: `tagline-rise 0.9s ${T.taglineStart}s cubic-bezier(.2,.7,.3,1) both`,
          opacity: 0,
          fontWeight: 500,
        }}
      >
        حين يلتقي النهار بالليل
      </div>
    </div>
  );
}
