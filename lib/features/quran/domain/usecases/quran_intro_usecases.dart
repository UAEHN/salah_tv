import '../i_quran_intro_flag_repository.dart';

class HasSeenMushafIntroUseCase {
  final IQuranIntroFlagRepository _repo;
  HasSeenMushafIntroUseCase(this._repo);
  Future<bool> call() => _repo.hasSeenIntro();
}

class MarkMushafIntroSeenUseCase {
  final IQuranIntroFlagRepository _repo;
  MarkMushafIntroSeenUseCase(this._repo);
  Future<void> call() => _repo.markIntroSeen();
}
