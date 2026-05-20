import IslamicTile from "./ornaments/IslamicTile";

// Pre-compute tile grid positions (5 columns x 4 rows)
const TILES = [];
for (let x = 0; x < 5; x++) {
  for (let y = 0; y < 4; y++) {
    TILES.push({
      x: x * 25 - 5,
      y: y * 30 - 5,
      key: `${x}-${y}`,
    });
  }
}

/**
 * PatternLayer — Background of repeating Islamic 8-pointed star tiles
 *
 * Very low opacity, sits at the bottom of the visual stack.
 */
export default function PatternLayer() {
  return (
    <div
      style={{
        position: "absolute",
        inset: 0,
        overflow: "hidden",
        zIndex: 0,
        pointerEvents: "none",
      }}
    >
      {TILES.map((t) => (
        <div
          key={t.key}
          style={{
            position: "absolute",
            left: `${t.x}%`,
            top: `${t.y}%`,
          }}
        >
          <IslamicTile />
        </div>
      ))}
    </div>
  );
}
