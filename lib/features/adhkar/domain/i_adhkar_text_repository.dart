import 'entities/adhkar_category.dart';
import 'entities/text_dhikr.dart';

/// Read-only repository for text-based adhkar (mobile reader feature).
/// Separate from [IAdhkarStateRepository] which handles TV audio sessions.
abstract class IAdhkarTextRepository {
  /// Returns all available adhkar categories.
  List<AdhkarCategory> getCategories();

  /// Returns all adhkar belonging to [categoryId].
  List<TextDhikr> getByCategory(String categoryId);
}
