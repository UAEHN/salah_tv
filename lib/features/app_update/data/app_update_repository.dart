import 'package:shared_preferences/shared_preferences.dart';

import '../domain/i_app_update_repository.dart';
import '../domain/whats_new_changelog.dart';

class AppUpdateRepository implements IAppUpdateRepository {
  static const _key = 'app_update_whats_new_seen_version';

  @override
  Future<bool> isCurrentVersionSeen() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_key) == kCurrentVersion;
  }

  @override
  Future<void> markCurrentVersionSeen() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, kCurrentVersion);
  }
}
