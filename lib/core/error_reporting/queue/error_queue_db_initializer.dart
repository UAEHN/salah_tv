import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';

/// Opens (or creates) the durable offline error queue `error_queue.db`.
/// Separate from `prayer_cache.db` on purpose: a corrupt/locked prayer cache
/// must never take error reporting down with it (and vice versa).
class ErrorQueueDbInitializer {
  static const _dbFileName = 'error_queue.db';
  static const _dbVersion = 1;

  Future<Database> openOrCreate() async {
    final dir = await getDatabasesPath();
    final path = p.join(dir, _dbFileName);
    return openDatabase(path, version: _dbVersion, onCreate: _createSchema);
  }

  Future<void> createSchemaForTest(Database db) => _createSchema(db, 1);

  Future<void> _createSchema(Database db, int _) async {
    await db.execute('''
      CREATE TABLE error_queue (
        id         INTEGER PRIMARY KEY AUTOINCREMENT,
        payload    TEXT    NOT NULL,
        created_at INTEGER NOT NULL
      )
    ''');
  }
}
