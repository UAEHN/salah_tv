import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/success.dart';
import '../../../settings/presentation/settings_provider.dart';
import '../../domain/i_appearance_writer_port.dart';

/// Bridges the customization domain (`IAppearanceWriterPort`) to the live
/// `SettingsProvider`. Lives in the presentation layer because the provider
/// is presentation-scoped (CLAUDE.md §3 + §8 — same pattern as
/// `INotificationOnboardingFlagPort`).
///
/// Persistence (and rollback on failure) is handled inside `SettingsProvider`
/// itself; here we only translate the API surface and surface a `Success`.
class SettingsAppearanceAdapter implements IAppearanceWriterPort {
  final SettingsProvider _provider;

  const SettingsAppearanceAdapter(this._provider);

  @override
  Future<Either<Failure, Success>> applyThemeKey(String key) async {
    try {
      await _provider.updateTheme(key);
      return const Right(Success());
    } on Object catch (e) {
      return Left(CacheFailure('apply theme failed: $e'));
    }
  }

  @override
  Future<Either<Failure, Success>> applyFontFamily(String family) async {
    try {
      await _provider.updateFontFamily(family);
      return const Right(Success());
    } on Object catch (e) {
      return Left(CacheFailure('apply font failed: $e'));
    }
  }
}
