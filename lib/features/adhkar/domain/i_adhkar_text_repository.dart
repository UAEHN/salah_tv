import 'entities/adhkar_category.dart';
import 'entities/text_dhikr.dart';

/// Read-only repository for text-based adhkar. Feeds both the mobile counting
/// reader and the TV full-screen adhkar takeovers (after-prayer + morning/
/// evening session).
abstract class IAdhkarTextRepository {
  /// Returns all available adhkar categories.
  List<AdhkarCategory> getCategories();

  /// Returns all adhkar belonging to [categoryId].
  List<TextDhikr> getByCategory(String categoryId);
}
