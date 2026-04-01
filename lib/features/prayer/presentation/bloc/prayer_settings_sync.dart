import '../../../settings/domain/entities/app_settings.dart';
import '../../domain/i_prayer_times_repository.dart';

Future<void> syncPrayerRepositoryMode(
  IPrayerTimesRepository repo,
  AppSettings prev,
  AppSettings next,
) async {
  if (next.isCalculatedLocation &&
      next.selectedLatitude != null &&
      next.selectedLongitude != null) {
    repo.configureCalculatedMode(
      next.selectedLatitude!,
      next.selectedLongitude!,
      next.calculationMethod,
      madhabKey: next.madhab,
      cityLabel: next.selectedCity,
      utcOffsetHours: next.utcOffsetHours,
    );
    return;
  }

  final wasModeSwitch =
      next.isCalculatedLocation != prev.isCalculatedLocation;
  if (wasModeSwitch || next.selectedCountry != prev.selectedCountry) {
    repo.configureDatabaseMode();
    await repo.loadCountry(next.selectedCountry);
    return;
  }

  repo.configureDatabaseMode();
}
