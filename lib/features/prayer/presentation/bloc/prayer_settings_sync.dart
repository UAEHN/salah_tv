import '../../../settings/domain/entities/app_settings.dart';
import '../../data/composite_prayer_repository.dart';
import '../../domain/i_prayer_times_repository.dart';

Future<void> syncPrayerRepositoryMode(
  IPrayerTimesRepository repo,
  AppSettings prev,
  AppSettings next,
) async {
  if (repo is CompositePrayerRepository) {
    final wasModeSwitch =
        next.isCalculatedLocation != prev.isCalculatedLocation;

    if (next.isCalculatedLocation &&
        next.selectedLatitude != null &&
        next.selectedLongitude != null) {
      repo.calcRepo.initializeWithCoordinates(
        next.selectedLatitude!,
        next.selectedLongitude!,
        next.calculationMethod,
        madhabKey: next.madhab,
        cityLabel: next.selectedCity,
        utcOffsetHours: next.utcOffsetHours,
      );
      repo.setMode(isCalculated: true);
      return;
    }

    if (wasModeSwitch || next.selectedCountry != prev.selectedCountry) {
      await repo.sqliteRepo.loadCountry(next.selectedCountry);
    }
    repo.setMode(isCalculated: false);
    return;
  }

  if (next.selectedCountry != prev.selectedCountry) {
    await repo.loadCountry(next.selectedCountry);
  }
}
