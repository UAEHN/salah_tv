// Handles first-run copy of the bundled DB asset to writable app storage.
//
// Uses sqflite's getDatabasesPath() — the platform-standard directory for
// database files on Android (/data/.../databases/). This avoids permission
// issues that can occur with other app directories on some Android versions.
//
// After the first copy the asset is never read again — subsequent launches
// open the file directly from device storage.

import 'dart:io';
import 'package:flutter/services.dart';
import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';

class SqliteDbInitializer {
  static const _dbAssetPath = 'assets/prayer_times.db';
  static const _dbFileName  = 'prayer_times.db';

  // Increment this whenever you rebuild prayer_times.db with new data.
  // The app compares this against the stored version and re-copies if different.
  static const _dbVersion = 4;

  Future<String> get _dbPath async {
    final dir = await getDatabasesPath();
    return p.join(dir, _dbFileName);
  }

  String _versionPath(String dbPath) => '$dbPath.version';

  /// Copies the bundled DB from assets to device storage if not already
  /// present or if [_dbVersion] is newer than the stored version.
  /// Call once during app startup before [openDb].
  Future<void> copyIfNeeded() async {
    final path     = await _dbPath;
    final verFile  = File(_versionPath(path));
    final storedVer = verFile.existsSync()
        ? int.tryParse(verFile.readAsStringSync().trim()) ?? 0
        : 0;

    if (File(path).existsSync() && storedVer >= _dbVersion) return;

    // Load the asset as raw bytes and write to writable device storage.
    final data  = await rootBundle.load(_dbAssetPath);
    final bytes = data.buffer.asUint8List(
      data.offsetInBytes,
      data.lengthInBytes,
    );
    await File(path).writeAsBytes(bytes, flush: true);
    verFile.writeAsStringSync('$_dbVersion');
  }

  /// Opens and returns the SQLite database connection.
  /// Always call [copyIfNeeded] before this.
  Future<Database> openDb() async {
    final path = await _dbPath;
    // Open read-only — we never write to this DB from the app.
    return openDatabase(path, readOnly: true);
  }
}
