import '../../../models/app_settings.dart';

abstract class ISettingsRepository {
  Future<AppSettings> load();
  Future<void> save(AppSettings settings);
}
