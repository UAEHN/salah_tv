import { GL, G } from "../../constants/colors";
import { T } from "./timing";
import Sun from "./celestial/Sun";
import Moon from "./celestial/Moon";
import RayBurst from "./celestial/RayBurst";

/**
 * PhaseCelestial — The poetic centerpiece.
 *
 * Sun (day) descends from upper-left, Moon (night) rises
 * from lower-right. They arrive at the SAME center point at
 * the SAME instant (T.meetMoment) — fading into a single
 * bright pinpoint that blooms into the meeting flash.
 *
 * Sun: warm → dimming as day ends
 * Moon: cool → brightening as night begins
 */
export default function PhaseCelestial() {
  return (
    <>
      {/* SUN — descends from top-left, dims as it arrives */}
      <div
        style={{
          position: "absolute",
          top: "50%",
          left: "50%",
          marginLeft: -40,
          marginTop: -40,
          animation: `sun-descend-meet ${T.arcDuration}s ${T.celestialStart}s cubic-bezier(.45,.05,.5,.95) both`,
        }}
      >
        <Sun />
      </div>

      {/* MOON — rises from bottom-right, brightens on arrival */}
      <div
        style={{
          position: "absolute",
          top: "50%",
          left: "50%",
          marginLeft: -35,
          marginTop: -35,
          animation: `moon-rise-meet ${T.arcDuration}s ${T.celestialStart}s cubic-bezier(.45,.05,.5,.95) both`,
        }}
      >
        <Moon />
      </div>

      {/* MEET FLASH — golden bloom at the moment of meeting */}
      <div
        style={{
          position: "absolute",
          top: "50%",
          left: "50%",
          width: 180,
          height: 180,
          marginLeft: -90,
          marginTop: -90,
          borderRadius: "50%",
          background: `radial-gradient(circle, #fff8d9 0%, ${GL} 25%, ${G}90 55%, transparent 75%)`,
          filter: "blur(2px)",
          animation: `meet-flash ${T.flashDuration}s ${T.flashStart}s cubic-bezier(.2,.7,.3,1) both`,
          opacity: 0,
          pointerEvents: "none",
        }}
      />

      {/* MEET RING — single shockwave that defines the moment */}
      <div
        style={{
          position: "absolute",
          top: "50%",
          left: "50%",
          width: 60,
          height: 60,
          marginLeft: -30,
          marginTop: -30,
          borderRadius: "50%",
          border: `3px solid ${GL}`,
          boxShadow: `0 0 20px ${G}80`,
          animation: `meet-ring 1.4s ${T.flashStart}s ease-out both`,
          opacity: 0,
          pointerEvents: "none",
        }}
      />

      {/* RAY BURST — gentle radial light from the meeting */}
      <div
        style={{
          position: "absolute",
          top: "50%",
          left: "50%",
          width: 4,
          height: 4,
          marginLeft: -2,
          marginTop: -2,
          animation: `ray-spread 1.6s ${T.flashStart + 0.05}s ease-out both`,
          opacity: 0,
          pointerEvents: "none",
        }}
      >
        <RayBurst />
      </div>
    </>
  );
}
