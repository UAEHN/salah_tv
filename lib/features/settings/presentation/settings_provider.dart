import 'package:flutter/foundation.dart';
import '../domain/entities/app_settings.dart';
import '../domain/entities/app_settings_copy_with.dart';
import '../domain/i_settings_repository.dart';
import '../domain/usecases/save_settings_usecase.dart';

part 'settings_provider_appearance.dart';
part 'settings_provider_location.dart';
part 'settings_provider_quran.dart';
part 'settings_provider_notifications.dart';

class SettingsProvider extends ChangeNotifier {
  final SaveSettingsUseCase _save;
  AppSettings _settings;

  SettingsProvider(ISettingsRepository repo, this._settings)
    : _save = SaveSettingsUseCase(repo);

  AppSettings get settings => _settings;

  Future<void> _update(AppSettings s) async {
    final prev = _settings;
    _settings = s;
    notifyListeners();
    final result = await _save(_settings);
    result.fold((failure) {
      debugPrint('[Settings] persist failed: $failure — rolling back');
      _settings = prev;
      notifyListeners();
    }, (_) {});
  }
}
