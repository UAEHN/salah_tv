import { NAVY_L } from "../constants/colors";

/**
 * MeshGradient — Atmospheric blurred gradient blobs
 *
 * Two large soft-glowing circles drift slowly in background.
 * Adds depth without being distracting.
 */
export default function MeshGradient() {
  return (
    <>
      {/* Top-left navy glow */}
      <div
        style={{
          position: "absolute",
          width: "70vw",
          height: "70vw",
          top: "-20%",
          left: "-10%",
          background: `radial-gradient(circle, ${NAVY_L} 0%, transparent 60%)`,
          filter: "blur(60px)",
          animation: "mesh-1 14s ease-in-out infinite",
          pointerEvents: "none",
          zIndex: 0,
        }}
      />

      {/* Bottom-right gold glow */}
      <div
        style={{
          position: "absolute",
          width: "60vw",
          height: "60vw",
          bottom: "-15%",
          right: "-15%",
          background: "radial-gradient(circle, rgba(212, 168, 67, 0.08) 0%, transparent 70%)",
          filter: "blur(80px)",
          animation: "mesh-2 18s ease-in-out infinite",
          pointerEvents: "none",
          zIndex: 0,
        }}
      />
    </>
  );
}
