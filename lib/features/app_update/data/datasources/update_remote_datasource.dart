import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:path_provider/path_provider.dart';
import 'package:install_plugin_v2/install_plugin_v2.dart';
import 'package:package_info_plus/package_info_plus.dart';

abstract class UpdateRemoteDataSource {
  Future<Map<String, dynamic>> fetchLatestVersion();
  Future<String> downloadApk(String url, Function(int, int) onProgress);
  Future<void> installApk(String filePath);
}

@Injectable(as: UpdateRemoteDataSource)
class UpdateRemoteDataSourceImpl implements UpdateRemoteDataSource {
  final Dio dio;

  UpdateRemoteDataSourceImpl(this.dio);

  @override
  Future<Map<String, dynamic>> fetchLatestVersion() async {
    final response = await dio.get(
      'https://gist.githubusercontent.com/UAEHN/'
      '0f3dbd6d07c1217e97e414e777a28bd4/raw/app_version.json',
    );
    if (response.statusCode == 200) {
      if (response.data is String) {
        return jsonDecode(response.data) as Map<String, dynamic>;
      }
      return response.data as Map<String, dynamic>;
    } else {
      throw Exception('Server error');
    }
  }

  @override
  Future<String> downloadApk(
    String url,
    Function(int, int) onProgress,
  ) async {
    final dir = await getExternalStorageDirectory();
    if (dir == null) {
      throw Exception('External storage not available');
    }
    final savePath = '${dir.path}/update.apk';

    await dio.download(url, savePath, onReceiveProgress: onProgress);

    return savePath;
  }

  @override
  Future<void> installApk(String filePath) async {
    final packageInfo = await PackageInfo.fromPlatform();
    await InstallPlugin.installApk(filePath, packageInfo.packageName);
  }
}
