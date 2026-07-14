import { Firestore } from "firebase-admin/firestore";

// Best-effort cap on a group's occurrences subcollection — keeps the newest
// [keep] pointers and deletes the rest. Called on an amortized schedule (not
// per event), and never fails the pipeline: trimming is pure housekeeping.
export async function trimOccurrences(
  db: Firestore,
  fingerprint: string,
  keep: number,
): Promise<void> {
  try {
    const stale = await db
      .collection("error_groups")
      .doc(fingerprint)
      .collection("occurrences")
      .orderBy("at", "desc")
      .offset(keep)
      .get();
    if (stale.empty) return;
    const batch = db.batch();
    stale.docs.forEach((doc) => batch.delete(doc.ref));
    await batch.commit();
  } catch {
    // Housekeeping only — swallow.
  }
}
