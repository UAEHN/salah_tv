abstract class IAppUpdateRepository {
  Future<bool> isCurrentVersionSeen();
  Future<void> markCurrentVersionSeen();
}
