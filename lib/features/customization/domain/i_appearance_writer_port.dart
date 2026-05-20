import 'package:dartz/dartz.dart';

import '../../../core/error/failures.dart';
import '../../../core/usecases/success.dart';

/// Port the customization feature uses to push theme/font selections back
/// into persistent settings — without depending on `SettingsProvider`
/// (presentation) directly.
///
/// The implementation lives at the presentation boundary and adapts the
/// existing `SettingsProvider` (or a plain `ISettingsRepository`-backed
/// variant). Mirrors the §8 cross-feature accepted-exception pattern used
/// by `INotificationOnboardingFlagPort`.
abstract class IAppearanceWriterPort {
  /// Persist the new theme palette key. Returns [Success] on persistence
  /// completion (rollback on failure is the adapter's responsibility).
  Future<Either<Failure, Success>> applyThemeKey(String key);

  /// Persist the new font family.
  Future<Either<Failure, Success>> applyFontFamily(String family);
}
