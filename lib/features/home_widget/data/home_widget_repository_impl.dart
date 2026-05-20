import 'package:dartz/dartz.dart';

import '../../../core/error/failures.dart';
import '../domain/entities/widget_payload.dart';
import '../domain/i_home_widget_repository.dart';
import 'datasources/home_widget_data_source.dart';
import 'models/widget_payload_mapper.dart';

class HomeWidgetRepositoryImpl implements IHomeWidgetRepository {
  final HomeWidgetDataSource _ds;
  const HomeWidgetRepositoryImpl(this._ds);

  @override
  Future<Either<Failure, Unit>> publish(WidgetPayload payload) async {
    try {
      await _ds.writeAll(flattenWidgetPayload(payload));
      return const Right(unit);
    } on StorageException catch (e) {
      return Left(CacheFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, Unit>> clear() async {
    try {
      await _ds.clear();
      return const Right(unit);
    } on StorageException catch (e) {
      return Left(CacheFailure(e.message));
    }
  }
}
