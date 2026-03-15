import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';
import 'package:dio/dio.dart';
import 'features/app_update/domain/repositories/update_repository.dart';
import 'features/app_update/domain/usecases/check_update_usecase.dart';
import 'features/app_update/domain/usecases/download_install_usecase.dart';
import 'injection.config.dart';

final getIt = GetIt.instance;

@InjectableInit(
  initializerName: 'init',
  preferRelativeImports: true,
  asExtension: true,
)
void configureDependencies() => getIt.init();

@module
abstract class RegisterModule {
  @lazySingleton
  Dio get dio => Dio();

  @injectable
  CheckUpdateUseCase checkUpdateUseCase(UpdateRepository repo) =>
      CheckUpdateUseCase(repo);

  @injectable
  DownloadInstallUseCase downloadInstallUseCase(UpdateRepository repo) =>
      DownloadInstallUseCase(repo);
}
