abstract interface class IAdhanPreviewPort {
  Future<void> preview(String soundKey);
  Future<void> stop();
  void dispose();
}
