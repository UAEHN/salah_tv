import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/widget_payload.dart';
import '../i_home_widget_repository.dart';

/// Thin use-case so the presentation bridge never holds a repository directly.
class PublishWidgetPayloadUseCase {
  final IHomeWidgetRepository _repo;
  const PublishWidgetPayloadUseCase(this._repo);

  Future<Either<Failure, Unit>> call(WidgetPayload payload) =>
      _repo.publish(payload);
}
