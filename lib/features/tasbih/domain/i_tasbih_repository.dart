abstract interface class ITasbihRepository {
  Future<int> loadCount();
  Future<void> saveCount(int count);
  Future<int> loadPresetIndex();
  Future<void> savePresetIndex(int index);
}
