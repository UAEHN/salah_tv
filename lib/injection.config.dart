// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format width=80

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:dio/dio.dart' as _i361;
import 'package:get_it/get_it.dart' as _i174;
import 'package:injectable/injectable.dart' as _i526;

import 'features/app_update/data/datasources/update_remote_datasource.dart'
    as _i393;
import 'features/app_update/data/repositories/update_repository_impl.dart'
    as _i589;
import 'features/app_update/domain/repositories/update_repository.dart'
    as _i1033;
import 'features/app_update/domain/usecases/check_update_usecase.dart' as _i746;
import 'features/app_update/domain/usecases/download_install_usecase.dart'
    as _i768;
import 'features/app_update/presentation/bloc/update_bloc.dart' as _i199;
import 'injection.dart' as _i464;

extension GetItInjectableX on _i174.GetIt {
  // initializes the registration of main-scope dependencies inside of GetIt
  _i174.GetIt init({
    String? environment,
    _i526.EnvironmentFilter? environmentFilter,
  }) {
    final gh = _i526.GetItHelper(this, environment, environmentFilter);
    final registerModule = _$RegisterModule();
    gh.lazySingleton<_i361.Dio>(() => registerModule.dio);
    gh.factory<_i393.UpdateRemoteDataSource>(
      () => _i393.UpdateRemoteDataSourceImpl(gh<_i361.Dio>()),
    );
    gh.factory<_i1033.UpdateRepository>(
      () => _i589.UpdateRepositoryImpl(gh<_i393.UpdateRemoteDataSource>()),
    );
    gh.factory<_i746.CheckUpdateUseCase>(
      () => _i746.CheckUpdateUseCase(gh<_i1033.UpdateRepository>()),
    );
    gh.factory<_i768.DownloadInstallUseCase>(
      () => _i768.DownloadInstallUseCase(gh<_i1033.UpdateRepository>()),
    );
    gh.factory<_i199.UpdateBloc>(
      () => _i199.UpdateBloc(
        gh<_i746.CheckUpdateUseCase>(),
        gh<_i768.DownloadInstallUseCase>(),
      ),
    );
    return this;
  }
}

class _$RegisterModule extends _i464.RegisterModule {}
