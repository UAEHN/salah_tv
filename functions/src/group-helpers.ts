export const SEVERITY_RANK: Record<string, number> = {
  info: 0,
  warning: 1,
  error: 2,
  fatal: 3,
};
const SEVERITY_BY_RANK = ["info", "warning", "error", "fatal"];

export function maxSeverity(a: string, b: string): string {
  const rank = Math.max(SEVERITY_RANK[a] ?? 0, SEVERITY_RANK[b] ?? 0);
  return SEVERITY_BY_RANK[rank];
}

// UTC hour bucket key 'YYYYMMDDHH' — the counts_hourly map key.
export function hourBucket(ms: number): string {
  const d = new Date(ms);
  const p = (n: number) => String(n).padStart(2, "0");
  return (
    `${d.getUTCFullYear()}${p(d.getUTCMonth() + 1)}` +
    `${p(d.getUTCDate())}${p(d.getUTCHours())}`
  );
}

// Increments the current hour and keeps only the newest [cap] buckets (keys
// sort lexicographically == chronologically, so shift() drops the oldest).
export function bumpHourly(
  counts: Record<string, number>,
  hour: string,
  cap: number,
): Record<string, number> {
  const next: Record<string, number> = {
    ...counts,
    [hour]: (counts[hour] ?? 0) + 1,
  };
  const keys = Object.keys(next).sort();
  while (keys.length > cap) {
    const oldest = keys.shift();
    if (oldest) delete next[oldest];
  }
  return next;
}

// A spike = the current hour has ≥[minCount] events AND is ≥[avgMultiple]× the
// average of the other retained buckets (needs history to fire).
export function isSpike(
  counts: Record<string, number>,
  hour: string,
  minCount: number,
  avgMultiple: number,
): boolean {
  const current = counts[hour] ?? 0;
  if (current < minCount) return false;
  const others = Object.entries(counts)
    .filter(([k]) => k !== hour)
    .map(([, v]) => v);
  if (others.length === 0) return false;
  const avg = others.reduce((a, b) => a + b, 0) / others.length;
  return current >= avgMultiple * Math.max(avg, 1);
}

// Adds [value] to [existing] (dedup), keeping the newest [cap] entries.
export function unionCapped(
  existing: string[] | undefined,
  value: string,
  cap: number,
): string[] {
  const list = existing ?? [];
  if (!value || list.includes(value)) return list;
  const next = [...list, value];
  return next.length > cap ? next.slice(next.length - cap) : next;
}
