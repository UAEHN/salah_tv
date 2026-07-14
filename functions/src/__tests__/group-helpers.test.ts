import {
  bumpHourly,
  hourBucket,
  isSpike,
  maxSeverity,
  unionCapped,
} from "../group-helpers";

describe("maxSeverity", () => {
  it("keeps the higher rank in either order", () => {
    expect(maxSeverity("info", "fatal")).toBe("fatal");
    expect(maxSeverity("error", "warning")).toBe("error");
    expect(maxSeverity("warning", "warning")).toBe("warning");
  });
});

describe("hourBucket", () => {
  it("formats a UTC YYYYMMDDHH key", () => {
    expect(hourBucket(Date.UTC(2026, 6, 3, 5, 30))).toBe("2026070305");
  });
});

describe("bumpHourly", () => {
  it("increments an existing hour", () => {
    expect(bumpHourly({ "2026070305": 2 }, "2026070305", 25)["2026070305"]).toBe(3);
  });
  it("adds a new hour at 1", () => {
    expect(bumpHourly({}, "2026070306", 25)["2026070306"]).toBe(1);
  });
  it("evicts the oldest bucket beyond the cap", () => {
    const counts: Record<string, number> = {};
    for (let h = 0; h < 25; h++) {
      counts[`20260703${String(h).padStart(2, "0")}`] = 1;
    }
    const next = bumpHourly(counts, "2026070400", 25);
    expect(Object.keys(next)).toHaveLength(25);
    expect(next["2026070300"]).toBeUndefined(); // oldest dropped
    expect(next["2026070400"]).toBe(1); // newest kept
  });
});

describe("isSpike", () => {
  it("flags an hour ≥ minCount and ≥ avgMultiple× the average", () => {
    expect(isSpike({ a: 2, b: 2, c: 2, now: 12 }, "now", 10, 5)).toBe(true);
  });
  it("does not flag below minCount", () => {
    expect(isSpike({ a: 1, now: 8 }, "now", 10, 5)).toBe(false);
  });
  it("does not flag when within the average multiple", () => {
    expect(isSpike({ a: 9, b: 9, now: 11 }, "now", 10, 5)).toBe(false);
  });
  it("needs history — a lone bucket is never a spike", () => {
    expect(isSpike({ now: 50 }, "now", 10, 5)).toBe(false);
  });
});

describe("unionCapped", () => {
  it("adds new values and dedups", () => {
    expect(unionCapped(["1.0.0"], "1.0.1", 15)).toEqual(["1.0.0", "1.0.1"]);
    expect(unionCapped(["1.0.0"], "1.0.0", 15)).toEqual(["1.0.0"]);
  });
  it("keeps the newest cap entries", () => {
    expect(unionCapped(["a", "b", "c"], "d", 3)).toEqual(["b", "c", "d"]);
  });
  it("ignores empty values", () => {
    expect(unionCapped(["a"], "", 3)).toEqual(["a"]);
  });
});
