import '../entities/text_dhikr.dart';
import '../i_adhkar_text_repository.dart';

/// Retrieves all text adhkar for a given category.
class GetAdhkarByCategoryUseCase {
  final IAdhkarTextRepository _repository;

  const GetAdhkarByCategoryUseCase(this._repository);

  List<TextDhikr> call(String categoryId) {
    return _repository.getByCategory(categoryId);
  }
}
