import 'package:shared_preferences/shared_preferences.dart';
import '../domain/i_tasbih_repository.dart';

class TasbihRepository implements ITasbihRepository {
  static const _kCount = 'tasbih_count';
  static const _kPreset = 'tasbih_preset_index';

  @override
  Future<int> loadCount() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_kCount) ?? 0;
  }

  @override
  Future<void> saveCount(int count) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_kCount, count);
  }

  @override
  Future<int> loadPresetIndex() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_kPreset) ?? 0;
  }

  @override
  Future<void> savePresetIndex(int index) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_kPreset, index);
  }
}
