import "./hook/animations.css";

import PhaseStarfield from "./hook/PhaseStarfield";
import SkyDusk from "./hook/SkyDusk";
import PhaseHorizon from "./hook/PhaseHorizon";
import PhaseCelestial from "./hook/PhaseCelestial";
import PhaseGhasaqName from "./hook/PhaseGhasaqName";
import Subtitle from "./hook/Subtitle";

/**
 * SceneHook — Cinematic opening (~6.5s)
 *
 * Single metaphor: sun (day) + moon (night) arc toward
 * the same point and meet at center. From their meeting
 * (the literal definition of "غسق" / Maghrib) the brand
 * name is born.
 *
 * Z-stack (back → front):
 *   1. PhaseStarfield  — calm distant stars
 *   2. PhaseHorizon    — subtle horizon glow line
 *   3. PhaseCelestial  — sun + moon meet → flash + rays
 *   4. PhaseGhasaqName — "غسق" reveal from the flash
 *   5. Subtitle        — GHASAQ + Arabic tagline
 */
export default function SceneHook() {
  return (
    <div
      style={{
        position: "relative",
        width: "100%",
        height: "100%",
        overflow: "hidden",
      }}
    >
      <PhaseStarfield />
      <SkyDusk />
      <PhaseHorizon />
      <PhaseCelestial />
      <PhaseGhasaqName />
      <Subtitle />
    </div>
  );
}
