import '../../../models/quran_reciter.dart';

abstract class IQuranApiRepository {
  Future<List<QuranApiReciter>> fetchReciters();
  Future<List<QuranApiReciter>> refreshReciters();
}
