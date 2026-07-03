import '../entities/khatma_plan.dart';
import '../i_khatma_repository.dart';

class GetActiveKhatmaUseCase {
  final IKhatmaRepository _repo;
  const GetActiveKhatmaUseCase(this._repo);

  Future<Khatma?> call() => _repo.getActiveKhatma();
}

class SaveKhatmaUseCase {
  final IKhatmaRepository _repo;
  const SaveKhatmaUseCase(this._repo);

  Future<void> call(Khatma khatma) => _repo.saveKhatma(khatma);
}

class ClearKhatmaUseCase {
  final IKhatmaRepository _repo;
  const ClearKhatmaUseCase(this._repo);

  Future<void> call() => _repo.clearKhatma();
}
