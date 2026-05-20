import { G, GL } from "../../constants/colors";

const GOLD_GRADIENT = `linear-gradient(180deg, ${GL} 0%, #fff8d9 35%, ${G} 75%)`;

const goldFillStyle = {
  background: GOLD_GRADIENT,
  WebkitBackgroundClip: "text",
  backgroundClip: "text",
  WebkitTextFillColor: "transparent",
  color: "transparent",
};

/**
 * SlotDigit — A single digit that rolls through 0-9 then lands.
 *
 * Self-contained: applies the gold gradient to each digit
 * directly so the text is always visible (background-clip:text
 * doesn't propagate through nested overflow/transform contexts).
 */
export default function SlotDigit({ value, delay = 0 }) {
  const CYCLES = 3;
  const total = CYCLES * 10 + value;
  return (
    <span
      style={{
        display: "inline-block",
        overflow: "hidden",
        height: "1em",
        lineHeight: 1,
        verticalAlign: "top",
      }}
    >
      <span
        style={{
          display: "flex",
          flexDirection: "column",
          animation: `slot-roll 1.6s ${delay}s cubic-bezier(.16,1,.3,1) both`,
          "--target": `-${total}em`,
        }}
      >
        {Array.from({ length: total + 1 }).map((_, i) => (
          <span
            key={i}
            style={{
              height: "1em",
              display: "block",
              ...goldFillStyle,
            }}
          >
            {i % 10}
          </span>
        ))}
      </span>
    </span>
  );
}

/* Renders a multi-digit number as a row of SlotDigits. */
export function SlotNumber({ value, startDelay = 0 }) {
  const digits = String(value).split("").map(Number);
  return (
    <>
      {digits.map((d, i) => (
        <SlotDigit key={i} value={d} delay={startDelay + i * 0.12} />
      ))}
    </>
  );
}

/* Static gold-filled glyph (used for non-numeric values like "∞" or "+") */
export function GoldGlyph({ children, style }) {
  return (
    <span style={{ ...goldFillStyle, ...style }}>
      {children}
    </span>
  );
}
