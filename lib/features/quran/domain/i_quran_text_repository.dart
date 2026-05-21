import 'package:dartz/dartz.dart';
import '../../../core/error/failures.dart';
import '../../../core/usecases/success.dart';
import 'entities/ayah.dart';
import 'entities/mushaf_page.dart';

/// Port to the bundled Mushaf text dataset.
///
/// Implementations are expected to be lazy: the JSON is large (~3-5MB) so
/// it should only be parsed on the first call to [ensureLoaded] or
/// [getPage]. Subsequent calls return cached pages in memory.
abstract class IQuranTextRepository {
  /// Force-load the dataset. Cheap to call repeatedly.
  Future<Either<Failure, Success>> ensureLoaded();

  /// Returns the rendered page or a [CacheFailure] if the asset is missing
  /// or malformed. Out-of-range pages return [CacheFailure].
  Future<Either<Failure, MushafPage>> getPage(int pageNumber);

  /// Returns the first Mushaf page on which [surahNumber] appears, or a
  /// failure if the dataset hasn't been loaded.
  Future<Either<Failure, int>> pageOfSurah(int surahNumber);

  /// Looks up the ayah that follows the given (surah, ayah) in Mushaf
  /// reading order. Returns null when called on the last ayah of the
  /// Quran (Surat An-Nas, ayah 6).
  Future<Ayah?> nextAyah(int surahNumber, int ayahNumber);
}
