import 'entities/khatma_plan.dart';

/// Single-slot store for the active Khatma (Quran completion plan).
///
/// Only one Khatma is active at a time — creating a new one replaces the
/// previous, mirroring the single-slot bookmark. Persistence lives in `data/`.
abstract class IKhatmaRepository {
  Future<Khatma?> getActiveKhatma();
  Future<void> saveKhatma(Khatma khatma);
  Future<void> clearKhatma();
}
